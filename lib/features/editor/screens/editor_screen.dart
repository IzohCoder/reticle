import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import '../../../core/design/tokens.dart';

/// Editor for adjusting captured pages: corners, filters, rotate, reorder.
/// M1: styled shell with filter strip and toolbar. Real editing in M2.
class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key, this.documentId});

  final int? documentId;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  String _selectedFilter = 'original';
  int _currentPage = 0; // ignore: prefer_final_fields

  final _filters = const [
    _FilterOption('original', 'Original'),
    _FilterOption('enhanced', 'Enhanced'),
    _FilterOption('bw', 'B&W'),
    _FilterOption('grayscale', 'Grayscale'),
    _FilterOption('blueprint', 'Blueprint'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Edit',
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.x),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // M2: save and navigate to document detail
              Navigator.of(context).pop();
            },
            child: Text(
              'Done',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Page preview area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(Spacing.lg),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: Radii.cardAll,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIconsRegular.image,
                      size: 48,
                      color: Colors.white24,
                    ),
                    const SizedBox(height: Spacing.md),
                    Text(
                      'Page ${_currentPage + 1}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter strip
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter.id;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedFilter = filter.id),
                  child: Container(
                    width: 64,
                    margin:
                        const EdgeInsets.only(right: Spacing.sm),
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: _filterPreviewColor(filter.id),
                            borderRadius: Radii.documentAll,
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.white12,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          filter.label,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white54,
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Toolbar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ToolButton(
                  icon: PhosphorIconsRegular.arrowsClockwise,
                  label: 'Rotate',
                  onTap: () {},
                ),
                _ToolButton(
                  icon: PhosphorIconsRegular.crop,
                  label: 'Crop',
                  onTap: () {},
                ),
                _ToolButton(
                  icon: PhosphorIconsRegular.sun,
                  label: 'Adjust',
                  onTap: () {},
                ),
                _ToolButton(
                  icon: PhosphorIconsRegular.arrowsDownUp,
                  label: 'Reorder',
                  onTap: () {},
                ),
              ],
            ),
          ),

          // Page thumbnails strip
          Container(
            height: 64,
            padding: const EdgeInsets.only(bottom: Spacing.md),
            child: Center(
              child: Text(
                'No pages yet',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _filterPreviewColor(String id) {
    switch (id) {
      case 'bw':
        return Colors.white;
      case 'grayscale':
        return Colors.grey;
      case 'blueprint':
        return const Color(0xFF0A3D5C);
      case 'enhanced':
        return const Color(0xFFF5F0E8);
      default:
        return const Color(0xFF3A3A3A);
    }
  }
}

class _FilterOption {
  const _FilterOption(this.id, this.label);
  final String id;
  final String label;
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
