import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import '../../../core/design/tokens.dart';
import '../../../data/database.dart';
import '../../../data/providers/database_provider.dart';
import '../../../services/image_processing_service.dart';

/// Editor for adjusting captured pages: filters, rotate, reorder.
class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key, this.documentId});

  final int? documentId;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  String _selectedFilter = 'original';
  int _currentPageIndex = 0;
  List<ScanPage> _pages = [];
  bool _isProcessing = false;
  bool _isLoaded = false;

  final _filters = const [
    _FilterOption('original', 'Original'),
    _FilterOption('enhanced', 'Enhanced'),
    _FilterOption('bw', 'B&W'),
    _FilterOption('grayscale', 'Grayscale'),
    _FilterOption('blueprint', 'Blueprint'),
  ];

  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  Future<void> _loadPages() async {
    if (widget.documentId == null) return;
    final db = ref.read(databaseProvider);
    final pages = await db.getPagesForDocument(widget.documentId!);
    if (mounted) {
      setState(() {
        _pages = pages;
        _isLoaded = true;
        if (pages.isNotEmpty) {
          _selectedFilter = pages[_currentPageIndex].filterType;
        }
      });
    }
  }

  Future<void> _applyFilter(String filterType) async {
    if (_pages.isEmpty || _isProcessing) return;
    setState(() {
      _isProcessing = true;
      _selectedFilter = filterType;
    });

    try {
      final page = _pages[_currentPageIndex];
      final db = ref.read(databaseProvider);

      String? processedPath;
      if (filterType != 'original') {
        processedPath = await ImageProcessingService.applyFilter(
          page.originalImagePath,
          filterType,
          widget.documentId!,
          page.id,
        );
      }

      await (db.update(db.scanPages)..where((t) => t.id.equals(page.id)))
          .write(ScanPagesCompanion(
        filterType: Value(filterType),
        processedImagePath: Value(processedPath),
      ));

      // Regenerate thumbnail with filter applied
      final displayPath = processedPath ?? page.originalImagePath;
      final thumbPath = await ImageProcessingService.generateThumbnail(
        displayPath, widget.documentId!, page.id,
      );
      await (db.update(db.scanPages)..where((t) => t.id.equals(page.id)))
          .write(ScanPagesCompanion(thumbnailPath: Value(thumbPath)));

      await _loadPages();
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _rotatePage() async {
    if (_pages.isEmpty || _isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final page = _pages[_currentPageIndex];
      final db = ref.read(databaseProvider);
      final newRotation = (page.rotation + 90) % 360;

      final rotatedPath = await ImageProcessingService.rotateImage(
        page.originalImagePath,
        newRotation,
        widget.documentId!,
        page.id,
      );

      await (db.update(db.scanPages)..where((t) => t.id.equals(page.id)))
          .write(ScanPagesCompanion(
        rotation: Value(newRotation),
        processedImagePath: Value(rotatedPath),
      ));

      final thumbPath = await ImageProcessingService.generateThumbnail(
        rotatedPath, widget.documentId!, page.id,
      );
      await (db.update(db.scanPages)..where((t) => t.id.equals(page.id)))
          .write(ScanPagesCompanion(thumbnailPath: Value(thumbPath)));

      HapticFeedback.lightImpact();
      await _loadPages();
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _deletePage() async {
    if (_pages.isEmpty) return;
    if (_pages.length == 1) {
      // Can't delete the last page; delete the whole document instead
      _confirmDeleteDocument();
      return;
    }

    final page = _pages[_currentPageIndex];
    final db = ref.read(databaseProvider);

    await db.deletePage(page.id);

    // Re-order remaining pages
    final remaining = await db.getPagesForDocument(widget.documentId!);
    for (var i = 0; i < remaining.length; i++) {
      await db.updatePageOrder(remaining[i].id, i);
    }

    // Update document page count
    await (db.update(db.scanDocuments)
          ..where((t) => t.id.equals(widget.documentId!)))
        .write(ScanDocumentsCompanion(
      pageCount: Value(remaining.length),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));

    setState(() {
      if (_currentPageIndex >= remaining.length) {
        _currentPageIndex = remaining.length - 1;
      }
    });
    await _loadPages();
  }

  void _confirmDeleteDocument() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete document?'),
        content: const Text(
          'This is the last page. Deleting it will remove the entire document.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final db = ref.read(databaseProvider);
              await ImageProcessingService.deleteDocumentFiles(
                  widget.documentId!);
              await db.deleteDocument(widget.documentId!);
              if (mounted) {
                Navigator.pop(ctx);
                context.go('/library');
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _reorderPages() {
    if (_pages.length < 2) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (ctx) => _ReorderSheet(
        pages: _pages,
        docId: widget.documentId!,
        onDone: () {
          Navigator.pop(ctx);
          _loadPages();
        },
        db: ref.read(databaseProvider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          _pages.isEmpty
              ? 'Edit'
              : 'Page ${_currentPageIndex + 1} of ${_pages.length}',
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.x),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (widget.documentId != null) {
                context.go('/library/${widget.documentId}');
              } else {
                context.go('/library');
              }
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
            child: _isLoaded && _pages.isNotEmpty
                ? _buildPagePreview(theme)
                : _buildEmptyPreview(theme),
          ),

          // Processing indicator
          if (_isProcessing)
            const LinearProgressIndicator(
              color: Color(0xFFE23B3B),
              backgroundColor: Color(0xFF1A1A1A),
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
                  onTap: () => _applyFilter(filter.id),
                  child: Container(
                    width: 64,
                    margin: const EdgeInsets.only(right: Spacing.sm),
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
                          child: _isProcessing && _selectedFilter == filter.id
                              ? const Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Colors.white54,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          filter.label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white54,
                            fontSize: 10,
                            fontWeight:
                                isSelected ? FontWeight.w500 : FontWeight.w400,
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
                  onTap: _rotatePage,
                ),
                _ToolButton(
                  icon: PhosphorIconsRegular.arrowsDownUp,
                  label: 'Reorder',
                  onTap: _reorderPages,
                ),
                _ToolButton(
                  icon: PhosphorIconsRegular.trash,
                  label: 'Delete',
                  onTap: _deletePage,
                ),
              ],
            ),
          ),

          // Page thumbnails strip
          if (_pages.length > 1)
            SizedBox(
              height: 64,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  final isSelected = index == _currentPageIndex;
                  final thumbPath = page.thumbnailPath;

                  return GestureDetector(
                    onTap: () => setState(() {
                      _currentPageIndex = index;
                      _selectedFilter = page.filterType;
                    }),
                    child: Container(
                      width: 44,
                      height: 56,
                      margin: const EdgeInsets.only(right: Spacing.xs),
                      decoration: BoxDecoration(
                        borderRadius: Radii.documentAll,
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.white12,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: Radii.documentAll,
                        child: thumbPath != null && File(thumbPath).existsSync()
                            ? Image.file(
                                File(thumbPath),
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + Spacing.sm),
        ],
      ),
    );
  }

  Widget _buildPagePreview(ThemeData theme) {
    final page = _pages[_currentPageIndex];
    final displayPath = ImageProcessingService.getDisplayPath(
      page.processedImagePath,
      page.originalImagePath,
    );

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < -200 &&
            _currentPageIndex < _pages.length - 1) {
          setState(() {
            _currentPageIndex++;
            _selectedFilter = _pages[_currentPageIndex].filterType;
          });
        } else if (details.primaryVelocity! > 200 && _currentPageIndex > 0) {
          setState(() {
            _currentPageIndex--;
            _selectedFilter = _pages[_currentPageIndex].filterType;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: Radii.cardAll,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: ClipRRect(
          borderRadius: Radii.cardAll,
          child: File(displayPath).existsSync()
              ? Image.file(
                  File(displayPath),
                  fit: BoxFit.contain,
                )
              : Center(
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
                        'Page ${_currentPageIndex + 1}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyPreview(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: Radii.cardAll,
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
              _isLoaded ? 'No pages' : 'Loading…',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white54,
              ),
            ),
          ],
        ),
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

/// Bottom sheet for reordering pages via drag-and-drop.
class _ReorderSheet extends StatefulWidget {
  const _ReorderSheet({
    required this.pages,
    required this.docId,
    required this.onDone,
    required this.db,
  });

  final List<ScanPage> pages;
  final int docId;
  final VoidCallback onDone;
  final AppDatabase db;

  @override
  State<_ReorderSheet> createState() => _ReorderSheetState();
}

class _ReorderSheetState extends State<_ReorderSheet> {
  late List<ScanPage> _orderedPages;

  @override
  void initState() {
    super.initState();
    _orderedPages = List.from(widget.pages);
  }

  Future<void> _save() async {
    for (var i = 0; i < _orderedPages.length; i++) {
      await widget.db.updatePageOrder(_orderedPages[i].id, i);
    }
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        top: Spacing.md,
        bottom: MediaQuery.of(context).padding.bottom + Spacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reorder Pages', style: theme.textTheme.titleMedium),
                TextButton(
                  onPressed: _save,
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
          ),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            height: 120,
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              itemCount: _orderedPages.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final page = _orderedPages.removeAt(oldIndex);
                  _orderedPages.insert(newIndex, page);
                });
                HapticFeedback.lightImpact();
              },
              itemBuilder: (context, index) {
                final page = _orderedPages[index];
                final thumbPath = page.thumbnailPath;

                return Container(
                  key: ValueKey(page.id),
                  width: 80,
                  margin: const EdgeInsets.only(right: Spacing.sm),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: Radii.documentAll,
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: Radii.documentAll,
                            child: thumbPath != null &&
                                    File(thumbPath).existsSync()
                                ? Image.file(File(thumbPath),
                                    fit: BoxFit.cover)
                                : const Center(
                                    child: Icon(PhosphorIconsRegular.image,
                                        size: 24, color: Colors.white24)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${index + 1}',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
