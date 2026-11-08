import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../data/database.dart';

/// On-device OCR using ML Kit text recognition (Latin script).
class OcrService {
  final AppDatabase db;

  OcrService(this.db);

  /// Runs OCR on a single page. Returns recognized text.
  Future<String> recognizePage(ScanPage page) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final imagePath = page.processedImagePath ?? page.originalImagePath;
      if (!File(imagePath).existsSync()) return '';

      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);

      // Extract text blocks with bounding boxes for searchable PDF
      final blocks = <Map<String, dynamic>>[];
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          blocks.add({
            'text': line.text,
            'rect': {
              'left': line.boundingBox.left,
              'top': line.boundingBox.top,
              'right': line.boundingBox.right,
              'bottom': line.boundingBox.bottom,
            },
            'confidence': line.confidence,
          });
        }
      }

      // Update page in database
      await db.updatePageOcr(
        page.id,
        recognizedText.text,
        jsonEncode(blocks),
      );

      return recognizedText.text;
    } finally {
      textRecognizer.close();
    }
  }

  /// Runs OCR on all pages of a document. Returns total text.
  Future<String> recognizeDocument(int documentId) async {
    final pages = await db.getPagesForDocument(documentId);
    final allText = StringBuffer();

    int recognized = 0;
    for (final page in pages) {
      final text = await recognizePage(page);
      if (text.isNotEmpty) {
        allText.writeln('--- Page ${page.sortOrder + 1} ---');
        allText.writeln(text);
        allText.writeln();
        recognized++;
      }
    }

    // Update document OCR status
    final status = recognized == pages.length
        ? 'complete'
        : recognized > 0
            ? 'partial'
            : 'none';

    await (db.update(db.scanDocuments)
          ..where((t) => t.id.equals(documentId)))
        .write(ScanDocumentsCompanion(
      ocrStatus: Value(status),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));

    return allText.toString();
  }

  /// Checks if the user has hit the free OCR limit (5 pages/day).
  Future<bool> isOcrLimitReached() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final countStr = await db.getSetting('ocr_count_$today');
    final count = int.tryParse(countStr ?? '0') ?? 0;
    return count >= 5;
  }

  /// Increments the daily OCR page count.
  Future<void> incrementOcrCount(int pages) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final countStr = await db.getSetting('ocr_count_$today');
    final count = int.tryParse(countStr ?? '0') ?? 0;
    await db.setSetting('ocr_count_$today', '${count + pages}');
  }

  /// Gets remaining free OCR pages today.
  Future<int> remainingFreeOcr() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final countStr = await db.getSetting('ocr_count_$today');
    final count = int.tryParse(countStr ?? '0') ?? 0;
    return (5 - count).clamp(0, 5);
  }
}
