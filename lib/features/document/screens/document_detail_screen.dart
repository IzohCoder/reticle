import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/app_typography.dart';
import '../../../data/database.dart';
import '../../../data/providers/database_provider.dart';
import '../../../data/providers/service_providers.dart';
import '../../../services/image_processing_service.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';

/// Provider that watches a single document and its pages.
final documentProvider =
    FutureProvider.family<ScanDocument, int>((ref, id) async {
  final db = ref.watch(databaseProvider);
  return db.getDocument(id);
});

final documentPagesProvider =
    StreamProvider.family<List<ScanPage>, int>((ref, docId) {
  final db = ref.watch(databaseProvider);
  return db.watchPagesForDocument(docId);
});

class DocumentDetailScreen extends ConsumerStatefulWidget {
  const DocumentDetailScreen({super.key, required this.documentId});

  final int documentId;

  @override
  ConsumerState<DocumentDetailScreen> createState() =>
      _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  bool _isExporting = false;
  bool _isOcrRunning = false;

  Future<void> _runOcr() async {
    setState(() => _isOcrRunning = true);

    try {
      final ocrService = ref.read(ocrServiceProvider);

      // Check limit
      final limitReached = await ocrService.isOcrLimitReached();
      if (limitReached && mounted) {
        context.push('/paywall?reason=ocr_limit');
        return;
      }

      final pages = await ref.read(databaseProvider).getPagesForDocument(
            widget.documentId,
          );

      // Track OCR usage
      await ocrService.incrementOcrCount(pages.length);
      await ocrService.recognizeDocument(widget.documentId);

      if (mounted) {
        HapticFeedback.mediumImpact();
        // Refresh providers
        ref.invalidate(documentProvider(widget.documentId));
        ref.invalidate(documentPagesProvider(widget.documentId));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Text recognized successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OCR failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isOcrRunning = false);
    }
  }

  void _showExportSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _ExportSheet(
        documentId: widget.documentId,
        exportService: ref.read(exportServiceProvider),
        db: ref.read(databaseProvider),
        onExportStart: () {
          if (mounted) setState(() => _isExporting = true);
        },
        onExportEnd: () {
          if (mounted) setState(() => _isExporting = false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = ref.watch(databaseProvider);

    return FutureBuilder<ScanDocument>(
      future: db.getDocument(widget.documentId),
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
                      context.push('/editor?docId=${widget.documentId}');
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
          body: ref.watch(documentPagesProvider(widget.documentId)).when(
                data: (pages) => _buildBody(theme, doc, pages, dateStr),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
        );
      },
    );
  }

  Widget _buildBody(
    ThemeData theme,
    ScanDocument doc,
    List<ScanPage> pages,
    String dateStr,
  ) {
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
              border: Border.all(color: theme.colorScheme.outlineVariant),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${doc.pageCount} pages',
                        style: theme.textTheme.titleSmall?.tabular,
                      ),
                      const SizedBox(height: 2),
                      Text(dateStr, style: theme.textTheme.bodySmall?.tabular),
                    ],
                  ),
                ),
                _OcrBadge(status: doc.ocrStatus),
              ],
            ),
          ),

          const SizedBox(height: Spacing.lg),

          // Progress indicators
          if (_isOcrRunning)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: Column(
                children: [
                  const LinearProgressIndicator(color: Color(0xFFE23B3B)),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    'Recognizing text…',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),

          if (_isExporting)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: Column(
                children: [
                  const LinearProgressIndicator(color: Color(0xFFE23B3B)),
                  const SizedBox(height: Spacing.sm),
                  Text('Exporting…', style: theme.textTheme.bodySmall),
                ],
              ),
            ),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: PhosphorIconsRegular.textAa,
                  label: doc.ocrStatus == 'complete'
                      ? 'View Text'
                      : 'Recognize Text',
                  isLoading: _isOcrRunning,
                  onTap: () {
                    if (doc.ocrStatus == 'complete') {
                      context.push('/library/${widget.documentId}/ocr');
                    } else {
                      _runOcr();
                    }
                  },
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: _ActionButton(
                  icon: PhosphorIconsRegular.export,
                  label: 'Export',
                  isLoading: _isExporting,
                  onTap: _showExportSheet,
                ),
              ),
            ],
          ),

          const SizedBox(height: Spacing.lg),

          // Page thumbnails grid
          Text('Pages', style: theme.textTheme.titleSmall),
          const SizedBox(height: Spacing.sm),

          if (pages.isEmpty)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: Radii.cardAll,
              ),
              child: Center(
                child: Text('No pages', style: theme.textTheme.bodySmall),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: Spacing.sm,
                crossAxisSpacing: Spacing.sm,
                childAspectRatio: 0.707,
              ),
              itemCount: pages.length,
              itemBuilder: (context, index) {
                final page = pages[index];
                final thumbPath = page.thumbnailPath;

                return GestureDetector(
                  onTap: () => _showPageViewer(context, pages, index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: Radii.documentAll,
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: Radii.documentAll,
                      child: thumbPath != null && File(thumbPath).existsSync()
                          ? Image.file(File(thumbPath), fit: BoxFit.cover)
                          : Center(
                              child: Text(
                                '${index + 1}',
                                style: theme.textTheme.titleSmall?.tabular
                                    .copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showPageViewer(
      BuildContext context, List<ScanPage> pages, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PageViewerScreen(
          pages: pages,
          initialIndex: initialIndex,
        ),
      ),
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
          decoration: const InputDecoration(hintText: 'Document name'),
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
                await (db.update(db.scanDocuments)
                      ..where(
                          (t) => t.id.equals(widget.documentId)))
                    .write(ScanDocumentsCompanion(
                  title: Value(newTitle),
                  updatedAt:
                      Value(DateTime.now().millisecondsSinceEpoch),
                ));
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) setState(() {});
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
              await ImageProcessingService.deleteDocumentFiles(doc.id);
              await db.deleteDocument(doc.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) context.go('/library');
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
}

// ---------------------------------------------------------------------------
// Export Sheet
// ---------------------------------------------------------------------------
class _ExportSheet extends StatefulWidget {
  const _ExportSheet({
    required this.documentId,
    required this.exportService,
    required this.db,
    required this.onExportStart,
    required this.onExportEnd,
  });

  final int documentId;
  final dynamic exportService; // ExportService
  final AppDatabase db;
  final VoidCallback onExportStart;
  final VoidCallback onExportEnd;

  @override
  State<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<_ExportSheet> {
  String _format = 'pdf';
  String _quality = 'balanced';
  bool _searchable = true;
  bool _isExporting = false;

  Future<void> _export() async {
    setState(() => _isExporting = true);
    widget.onExportStart();
    Navigator.pop(context);

    try {
      if (_format == 'pdf') {
        final path = await widget.exportService.exportPdf(
          widget.documentId,
          quality: _quality,
          searchable: _searchable,
        );
        await widget.exportService.sharePdf(path);
      } else {
        final paths = await widget.exportService.exportAllJpgs(
          widget.documentId,
          quality: _quality,
        );
        await widget.exportService.shareJpgs(paths);
      }
    } catch (e) {
      // Error handled silently — share sheet dismissed
    } finally {
      widget.onExportEnd();
    }
  }

  Future<void> _print() async {
    Navigator.pop(context);
    widget.onExportStart();
    try {
      final path = await widget.exportService.exportPdf(
        widget.documentId,
        quality: 'high',
      );
      await widget.exportService.printPdf(path);
    } finally {
      widget.onExportEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: Spacing.lg,
        right: Spacing.lg,
        top: Spacing.md,
        bottom: MediaQuery.of(context).padding.bottom + Spacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          Text('Export', style: theme.textTheme.titleMedium),
          const SizedBox(height: Spacing.lg),

          // Format selector
          Text('Format', style: theme.textTheme.labelMedium),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              _ChipButton(
                label: 'PDF',
                isSelected: _format == 'pdf',
                onTap: () => setState(() => _format = 'pdf'),
              ),
              const SizedBox(width: Spacing.sm),
              _ChipButton(
                label: 'JPG',
                isSelected: _format == 'jpg',
                onTap: () => setState(() => _format = 'jpg'),
              ),
            ],
          ),

          const SizedBox(height: Spacing.md),

          // Quality selector
          Text('Quality', style: theme.textTheme.labelMedium),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              _ChipButton(
                label: 'Small',
                isSelected: _quality == 'small',
                onTap: () => setState(() => _quality = 'small'),
              ),
              const SizedBox(width: Spacing.sm),
              _ChipButton(
                label: 'Balanced',
                isSelected: _quality == 'balanced',
                onTap: () => setState(() => _quality = 'balanced'),
              ),
              const SizedBox(width: Spacing.sm),
              _ChipButton(
                label: 'High',
                isSelected: _quality == 'high',
                onTap: () => setState(() => _quality = 'high'),
              ),
            ],
          ),

          // Searchable PDF option
          if (_format == 'pdf') ...[
            const SizedBox(height: Spacing.md),
            SwitchListTile(
              title: const Text('Searchable PDF'),
              subtitle: const Text('Overlay invisible OCR text'),
              value: _searchable,
              onChanged: (v) => setState(() => _searchable = v),
              activeThumbColor: theme.colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ],

          const SizedBox(height: Spacing.lg),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _print,
                  icon: const Icon(PhosphorIconsRegular.printer, size: 18),
                  label: const Text('Print'),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _isExporting ? null : _export,
                  icon: const Icon(PhosphorIconsRegular.shareFat, size: 18),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: Radii.chipAll,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page Viewer (full screen swipeable)
// ---------------------------------------------------------------------------
class _PageViewerScreen extends StatelessWidget {
  const _PageViewerScreen({
    required this.pages,
    required this.initialIndex,
  });

  final List<ScanPage> pages;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final page = pages[index];
          final path = ImageProcessingService.getDisplayPath(
            page.processedImagePath,
            page.originalImagePath,
          );

          return InteractiveViewer(
            child: Center(
              child: File(path).existsSync()
                  ? Image.file(File(path))
                  : Center(
                      child: Text(
                        'Page ${index + 1}',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable widgets
// ---------------------------------------------------------------------------

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
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      borderRadius: Radii.cardAll,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: Radii.cardAll,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: Spacing.md),
          decoration: BoxDecoration(
            borderRadius: Radii.cardAll,
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Icon(icon, size: 22, color: theme.colorScheme.primary),
              const SizedBox(height: Spacing.xs),
              Text(label, style: theme.textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}
