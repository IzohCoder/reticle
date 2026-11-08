import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/app_typography.dart';
import '../../../data/database.dart';
import 'package:intl/intl.dart';

/// Document thumbnail card with crop-mark corners motif.
class DocumentCard extends StatelessWidget {
  const DocumentCard({
    super.key,
    required this.document,
    required this.isGrid,
    required this.onTap,
  });

  final ScanDocument document;
  final bool isGrid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return isGrid ? _buildGridCard(context) : _buildListTile(context);
  }

  Widget _buildGridCard(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('d MMM').format(
      DateTime.fromMillisecondsSinceEpoch(document.updatedAt),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: Radii.cardAll,
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail area with crop-mark corners
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Radii.card),
                  topRight: Radius.circular(Radii.card),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Placeholder thumbnail
                    Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          PhosphorIconsRegular.fileText,
                          size: 40,
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                    // Crop-mark corners overlay
                    CustomPaint(
                      painter: _CropMarkPainter(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    // Page count badge
                    Positioned(
                      bottom: Spacing.sm,
                      right: Spacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(alpha: 0.85),
                          borderRadius: Radii.chipAll,
                        ),
                        child: Text(
                          '${document.pageCount} pg',
                          style: theme.textTheme.labelSmall?.tabular,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Title and date
            Padding(
              padding: const EdgeInsets.all(Spacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        dateStr,
                        style: theme.textTheme.bodySmall?.tabular,
                      ),
                      if (document.ocrStatus != 'none') ...[
                        const SizedBox(width: Spacing.xs),
                        Icon(
                          PhosphorIconsRegular.textAa,
                          size: 12,
                          color: document.ocrStatus == 'complete'
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('d MMM yyyy').format(
      DateTime.fromMillisecondsSinceEpoch(document.updatedAt),
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 56,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: Radii.documentAll,
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 0.5,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      PhosphorIconsRegular.fileText,
                      size: 24,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  CustomPaint(
                    size: const Size(56, 72),
                    painter: _CropMarkPainter(
                      color: theme.colorScheme.primary.withValues(alpha: 0.25),
                      length: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.md),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$dateStr · ${document.pageCount} pages',
                    style: theme.textTheme.bodySmall?.tabular,
                  ),
                ],
              ),
            ),
            if (document.ocrStatus != 'none')
              Padding(
                padding: const EdgeInsets.only(left: Spacing.sm),
                child: Icon(
                  PhosphorIconsRegular.textAa,
                  size: 16,
                  color: document.ocrStatus == 'complete'
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Paints four crop-mark L-shapes at the corners of a rectangle.
class _CropMarkPainter extends CustomPainter {
  _CropMarkPainter({required this.color, this.length = 16});

  final Color color;
  final double length;
  final double strokeWidth = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final w = size.width;
    final h = size.height;
    final l = length;

    // Top-left
    canvas.drawLine(const Offset(0, 0), Offset(l, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, l), paint);

    // Top-right
    canvas.drawLine(Offset(w, 0), Offset(w - l, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, l), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, h), Offset(l, h), paint);
    canvas.drawLine(Offset(0, h), Offset(0, h - l), paint);

    // Bottom-right
    canvas.drawLine(Offset(w, h), Offset(w - l, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - l), paint);
  }

  @override
  bool shouldRepaint(covariant _CropMarkPainter old) =>
      old.color != color || old.length != length;
}
