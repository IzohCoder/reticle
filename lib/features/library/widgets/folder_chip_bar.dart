import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import '../../../core/design/tokens.dart';
import '../../../data/database.dart';

/// Horizontal scrollable row of folder filter chips.
class FolderChipBar extends StatelessWidget {
  const FolderChipBar({
    super.key,
    required this.folders,
    required this.selectedId,
    required this.onSelected,
  });

  final List<ScanFolder> folders;
  final int? selectedId;
  final ValueChanged<int?> onSelected;

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
              )),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }
}
