import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/app_typography.dart';
import '../../../data/database.dart';
import '../../../data/providers/database_provider.dart';
import 'package:intl/intl.dart';

class DocumentDetailScreen extends ConsumerWidget {
  const DocumentDetailScreen({super.key, required this.documentId});

  final int documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(databaseProvider);

    return FutureBuilder<ScanDocument>(
      future: db.getDocument(documentId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final doc = snapshot.data!;
        final dateStr = DateFormat('d MMMM yyyy, HH:mm').format(
          DateTime.fromMillisecondsSinceEpoch(doc.updatedAt),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(doc.title),
            actions: [
              IconButton(
                icon: const Icon(PhosphorIconsRegular.pencilSimple),
                tooltip: 'Rename',
                onPressed: () => _showRenameDialog(context, ref, doc),
              ),
              PopupMenuButton<String>(
                icon: const Icon(PhosphorIconsRegular.dotsThreeVertical),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      context.push('/editor?docId=$documentId');
                      break;
                    case 'delete':
                      _confirmDelete(context, ref, doc);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit pages'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete document'),
                  ),
                ],
              ),
            ],
          ),
          body: FutureBuilder<List<ScanPage>>(
            future: db.getPagesForDocument(documentId),
            builder: (context, pagesSnapshot) {
              final pages = pagesSnapshot.data ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Document info header
                    Container(
                      padding: const EdgeInsets.all(Spacing.md),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: Radii.cardAll,
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIconsRegular.fileText,
                            size: 32,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: Spacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${doc.pageCount} pages',
                                  style: theme.textTheme.titleSmall
                                      ?.tabular,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateStr,
                                  style: theme.textTheme.bodySmall
                                      ?.tabular,
                                ),
                              ],
                            ),
                          ),
                          // OCR status
                          _OcrBadge(status: doc.ocrStatus),
                        ],
                      ),
                    ),

                    const SizedBox(height: Spacing.lg),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: PhosphorIconsRegular.textAa,
                            label: 'Recognize Text',
                            onTap: () =>
                                context.push('/library/$documentId/ocr'),
                          ),
                        ),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: _ActionButton(
                            icon: PhosphorIconsRegular.export,
                            label: 'Export',
                            onTap: () {
                              // M2: open export sheet
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: Spacing.lg),

                    // Page thumbnails grid
                    Text(
                      'Pages',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: Spacing.sm),

                    if (pages.isEmpty)
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: theme.colorScheme
                              .surfaceContainerHighest,
                          borderRadius: Radii.cardAll,
                        ),
                        child: Center(
                          child: Text(
                            'No pages',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: Spacing.sm,
                          crossAxisSpacing: Spacing.sm,
                          childAspectRatio: 0.707,
                        ),
                        itemCount: pages.length,
                        itemBuilder: (context, index) {
                          // page data used in M2 for image display
                          final _ = pages[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: Radii.documentAll,
                              border: Border.all(
                                color:
                                    theme.colorScheme.outlineVariant,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: theme.textTheme.titleSmall
                                    ?.tabular
                                    .copyWith(
                                  color: theme.colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showRenameDialog(
      BuildContext context, WidgetRef ref, ScanDocument doc) {
    final controller = TextEditingController(text: doc.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration:
              const InputDecoration(hintText: 'Document name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                final db = ref.read(databaseProvider);
                await db.setSetting('_rename_placeholder', '');
                // M2: implement proper update
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, ScanDocument doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete document?'),
        content: Text(
          'This will permanently remove "${doc.title}" and all its pages.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final db = ref.read(databaseProvider);
              await db.deleteDocument(doc.id);
              if (context.mounted) {
                Navigator.pop(ctx);
                context.pop();
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _OcrBadge extends StatelessWidget {
  const _OcrBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (status == 'none') return const SizedBox.shrink();

    final isComplete = status == 'complete';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isComplete
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: Radii.chipAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIconsRegular.textAa,
            size: 12,
            color: isComplete
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            isComplete ? 'OCR done' : 'Partial',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isComplete
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      borderRadius: Radii.cardAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.cardAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: Spacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: Radii.cardAll,
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 22,
                  color: theme.colorScheme.primary),
              const SizedBox(height: Spacing.xs),
              Text(label, style: theme.textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}
