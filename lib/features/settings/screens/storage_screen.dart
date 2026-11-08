import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/app_typography.dart';

/// Shows storage breakdown and offers cleanup.
class StorageScreen extends ConsumerStatefulWidget {
  const StorageScreen({super.key});

  @override
  ConsumerState<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends ConsumerState<StorageScreen> {
  bool _loading = true;
  int _originals = 0;
  int _processed = 0;
  int _thumbnails = 0;

  @override
  void initState() {
    super.initState();
    _computeUsage();
  }

  Future<void> _computeUsage() async {
    final base = await getApplicationDocumentsDirectory();
    final reticleDir = Directory('${base.path}/reticle');
    if (!reticleDir.existsSync()) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    int originals = 0, processed = 0, thumbnails = 0;
    for (final entity in reticleDir.listSync(recursive: true)) {
      if (entity is File) {
        final size = entity.lengthSync();
        final path = entity.path.replaceAll('\\', '/');
        if (path.contains('/originals/')) {
          originals += size;
        } else if (path.contains('/processed/')) {
          processed += size;
        } else if (path.contains('/thumbs/')) {
          thumbnails += size;
        }
      }
    }

    if (mounted) {
      setState(() {
        _originals = originals;
        _processed = processed;
        _thumbnails = thumbnails;
        _loading = false;
      });
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  int get _total => _originals + _processed + _thumbnails;

  Future<void> _cleanProcessed() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/reticle/processed');
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
    final thumbDir = Directory('${base.path}/reticle/thumbs');
    if (thumbDir.existsSync()) {
      thumbDir.deleteSync(recursive: true);
    }
    await _computeUsage();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processed images and thumbnails cleared')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Storage',
          style: theme.textTheme.titleLarge?.copyWith(
            fontFamily: AppFonts.display,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(Spacing.lg),
              children: [
                // Total usage circle
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: 8,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Text(
                              _formatBytes(_total),
                              style: theme.textTheme.titleSmall?.tabular,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.sm),
                      Text('Total storage used',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),

                const SizedBox(height: Spacing.xl),

                _StorageRow(
                  icon: PhosphorIconsRegular.image,
                  label: 'Original scans',
                  size: _formatBytes(_originals),
                  color: theme.colorScheme.primary,
                ),
                _StorageRow(
                  icon: PhosphorIconsRegular.funnel,
                  label: 'Processed images',
                  size: _formatBytes(_processed),
                  color: const Color(0xFF1B8A4A),
                ),
                _StorageRow(
                  icon: PhosphorIconsRegular.squareHalf,
                  label: 'Thumbnails',
                  size: _formatBytes(_thumbnails),
                  color: const Color(0xFFC06800),
                ),

                const SizedBox(height: Spacing.xl),

                if (_processed + _thumbnails > 0)
                  OutlinedButton.icon(
                    onPressed: _cleanProcessed,
                    icon:
                        const Icon(PhosphorIconsRegular.broom, size: 18),
                    label: const Text('Clear processed & thumbnails'),
                  ),

                const SizedBox(height: Spacing.lg),

                Text(
                  'Processed images and thumbnails are regenerated '
                  'automatically when needed. Clearing them is safe and '
                  'frees up storage.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
    );
  }
}

class _StorageRow extends StatelessWidget {
  const _StorageRow({
    required this.icon,
    required this.label,
    required this.size,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: Spacing.md),
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: Spacing.sm),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(size, style: theme.textTheme.bodyMedium?.tabular),
        ],
      ),
    );
  }
}
