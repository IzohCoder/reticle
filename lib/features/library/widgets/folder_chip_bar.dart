import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../config/app_config.dart';
import '../../../core/design/tokens.dart';
import '../../../data/database.dart';

/// Horizontal scrollable row of folder filter chips with a "+" button.
class FolderChipBar extends StatelessWidget {
  const FolderChipBar({
    super.key,
    required this.folders,
    required this.selectedId,
    required this.onSelected,
    required this.db,
  });

  final List<ScanFolder> folders;
  final int? selectedId;
  final ValueChanged<int?> onSelected;
  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: Spacing.sm),
            child: FilterChip(
              label: const Text('All'),
              selected: selectedId == null,
              onSelected: (_) => onSelected(null),
              showCheckmark: false,
              avatar: selectedId == null
                  ? null
                  : Icon(PhosphorIconsRegular.folders,
                      size: 16, color: theme.colorScheme.onSurfaceVariant),
              selectedColor: theme.colorScheme.primaryContainer,
            ),
          ),
          // Folder chips
          ...folders.map((folder) => Padding(
                padding: const EdgeInsets.only(right: Spacing.sm),
                child: GestureDetector(
                  onLongPress: () =>
                      _showFolderOptionsSheet(context, folder),
                  child: FilterChip(
                    label: Text(folder.name),
                    selected: selectedId == folder.id,
                    onSelected: (_) => onSelected(
                        selectedId == folder.id ? null : folder.id),
                    showCheckmark: false,
                    avatar: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _parseColor(folder.colorHex),
                        shape: BoxShape.circle,
                      ),
                    ),
                    selectedColor: theme.colorScheme.primaryContainer,
                  ),
                ),
              )),
          // "+" create folder chip
          Padding(
            padding: const EdgeInsets.only(right: Spacing.sm),
            child: ActionChip(
              avatar: Icon(PhosphorIconsRegular.plus,
                  size: 16, color: theme.colorScheme.onSurfaceVariant),
              label: const Text('New'),
              onPressed: () => _createFolder(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createFolder(BuildContext context) async {
    // Check folder limit
    final folderCount = await db.getFolderCount();
    if (folderCount >= freeFolderLimit && enablePaywall) {
      if (context.mounted) {
        context.push(
            '/paywall?reason=Free+tier+allows+up+to+$freeFolderLimit+folders');
      }
      return;
    }

    if (!context.mounted) return;
    _showCreateFolderDialog(context);
  }

  void _showCreateFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    final colors = [
      '#E23B3B', '#1B8A4A', '#2563EB', '#C06800', '#7C3AED',
      '#0891B2', '#DB2777', '#6B6B6B',
    ];
    String selectedColor = colors[0];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final theme = Theme.of(ctx);
          return AlertDialog(
            title: const Text('New folder'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration:
                      const InputDecoration(hintText: 'Folder name'),
                ),
                const SizedBox(height: Spacing.md),
                Text('Color', style: theme.textTheme.labelMedium),
                const SizedBox(height: Spacing.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors
                      .map((c) => GestureDetector(
                            onTap: () =>
                                setDialogState(() => selectedColor = c),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: _parseColor(c),
                                shape: BoxShape.circle,
                                border: selectedColor == c
                                    ? Border.all(
                                        color: theme
                                            .colorScheme.onSurface,
                                        width: 2)
                                    : null,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final name = controller.text.trim();
                  if (name.isEmpty) return;
                  final order = folders.length;
                  await db.insertFolder(ScanFoldersCompanion(
                    name: Value(name),
                    colorHex: Value(selectedColor),
                    sortOrder: Value(order),
                    createdAt: Value(
                        DateTime.now().millisecondsSinceEpoch),
                  ));
                  HapticFeedback.lightImpact();
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFolderOptionsSheet(BuildContext context, ScanFolder folder) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: Spacing.lg,
          right: Spacing.lg,
          top: Spacing.md,
          bottom: MediaQuery.of(ctx).padding.bottom + Spacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 32, height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),
            Text(folder.name, style: theme.textTheme.titleMedium),
            const SizedBox(height: Spacing.md),
            ListTile(
              leading: const Icon(PhosphorIconsRegular.pencilSimple),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(ctx);
                _showRenameFolderDialog(context, folder);
              },
            ),
            ListTile(
              leading: Icon(PhosphorIconsRegular.trash,
                  color: theme.colorScheme.error),
              title: Text('Delete',
                  style: TextStyle(color: theme.colorScheme.error)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteFolder(context, folder);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameFolderDialog(BuildContext context, ScanFolder folder) {
    final controller = TextEditingController(text: folder.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Folder name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              await (db.update(db.scanFolders)
                    ..where((t) => t.id.equals(folder.id)))
                  .write(ScanFoldersCompanion(name: Value(name)));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFolder(BuildContext context, ScanFolder folder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete folder?'),
        content: Text(
          'Documents in "${folder.name}" will be moved out of the folder, not deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await db.deleteFolder(folder.id);
              if (ctx.mounted) Navigator.pop(ctx);
              // Deselect if this folder was selected
              onSelected(null);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }
}
