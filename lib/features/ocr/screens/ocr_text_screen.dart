import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/design/tokens.dart';
import '../../../data/database.dart';
import '../../../data/providers/database_provider.dart';
import '../../../data/providers/service_providers.dart';

/// Shows recognized text from OCR with copy/share actions.
class OcrTextScreen extends ConsumerStatefulWidget {
  const OcrTextScreen({super.key, required this.documentId});

  final int documentId;

  @override
  ConsumerState<OcrTextScreen> createState() => _OcrTextScreenState();
}

class _OcrTextScreenState extends ConsumerState<OcrTextScreen>
    with SingleTickerProviderStateMixin {
  String _fullText = '';
  bool _isLoading = true;
  bool _isRunningOcr = false;
  List<ScanPage> _pages = [];

  late final AnimationController _revealController;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadText();
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  Future<void> _loadText() async {
    final db = ref.read(databaseProvider);
    final pages = await db.getPagesForDocument(widget.documentId);
    final buffer = StringBuffer();

    for (final page in pages) {
      if (page.recognizedText.isNotEmpty) {
        buffer.writeln('— Page ${page.sortOrder + 1} —');
        buffer.writeln(page.recognizedText);
        buffer.writeln();
      }
    }

    if (mounted) {
      setState(() {
        _pages = pages;
        _fullText = buffer.toString().trim();
        _isLoading = false;
      });

      if (_fullText.isNotEmpty) {
        _revealController.forward();
      }
    }
  }

  Future<void> _runOcr() async {
    setState(() => _isRunningOcr = true);

    try {
      final ocrService = ref.read(ocrServiceProvider);

      final limitReached = await ocrService.isOcrLimitReached();
      if (limitReached && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily OCR limit reached. Upgrade to Pro for unlimited OCR.'),
          ),
        );
        return;
      }

      await ocrService.incrementOcrCount(_pages.length);
      await ocrService.recognizeDocument(widget.documentId);

      HapticFeedback.mediumImpact();
      await _loadText();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OCR failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRunningOcr = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recognized Text'),
        actions: [
          if (_fullText.isNotEmpty) ...[
            IconButton(
              icon: const Icon(PhosphorIconsRegular.copy),
              tooltip: 'Copy all',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _fullText));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
            ),
            IconButton(
              icon: const Icon(PhosphorIconsRegular.shareFat),
              tooltip: 'Share',
              onPressed: () {
                Share.share(_fullText, subject: 'Recognized Text');
              },
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // OCR progress
                  if (_isRunningOcr)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.md),
                      child: Column(
                        children: [
                          const LinearProgressIndicator(
                            color: Color(0xFFE23B3B),
                          ),
                          const SizedBox(height: Spacing.sm),
                          Text(
                            'Recognizing text…',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),

                  if (_fullText.isEmpty && !_isRunningOcr) ...[
                    // No OCR yet — prompt to run
                    Container(
                      padding: const EdgeInsets.all(Spacing.lg),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: Radii.cardAll,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            PhosphorIconsRegular.textAa,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: Spacing.md),
                          Text(
                            'No text recognized yet',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: Spacing.sm),
                          Text(
                            'Tap below to extract text from your document using on-device OCR.',
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: Spacing.lg),
                          FilledButton.icon(
                            onPressed: _runOcr,
                            icon: const Icon(PhosphorIconsRegular.scan,
                                size: 18),
                            label: const Text('Recognize Text'),
                          ),
                        ],
                      ),
                    ),
                  ] else if (_fullText.isNotEmpty) ...[
                    // OCR Reveal animation — the signature moment
                    FadeTransition(
                      opacity: _revealController,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.05),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _revealController,
                          curve: Curves.easeOut,
                        )),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Success banner
                            Container(
                              padding: const EdgeInsets.all(Spacing.md),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: Radii.cardAll,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    PhosphorIconsFill.checkCircle,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: Spacing.sm),
                                  Expanded(
                                    child: Text(
                                      'Text recognized from ${_pages.length} page${_pages.length == 1 ? '' : 's'}',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: Spacing.lg),

                            // Recognized text
                            SelectableText(
                              _fullText,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.7,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
