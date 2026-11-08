import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import '../../../core/design/tokens.dart';

/// Shows recognized text from OCR. M1: styled shell. Real OCR in M2.
class OcrTextScreen extends ConsumerWidget {
  const OcrTextScreen({super.key, required this.documentId});

  final int documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // M1: placeholder text. M2: real OCR results from database.
    const placeholderText =
        'Text recognition will appear here after scanning.\n\n'
        'Tap "Recognize Text" on a document to extract text using on-device OCR. '
        'Recognized text becomes searchable and can be copied or shared.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recognized Text'),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.copy),
            tooltip: 'Copy all',
            onPressed: () {
              Clipboard.setData(
                  const ClipboardData(text: placeholderText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
          ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.shareFat),
            tooltip: 'Share',
            onPressed: () {
              // M2: share_plus
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status banner
            Container(
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: Radii.cardAll,
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.info,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      'OCR not yet run on this document',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.lg),

            // Text content
            SelectableText(
              placeholderText,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
