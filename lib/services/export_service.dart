import 'dart:convert';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../data/database.dart';
import 'image_processing_service.dart';

/// Handles PDF/JPG export, sharing, and printing.
class ExportService {
  final AppDatabase db;

  ExportService(this.db);

  /// Exports a document as PDF. Returns the file path.
  /// If [searchable] is true, overlays invisible OCR text.
  Future<String> exportPdf(
    int documentId, {
    String quality = 'balanced',
    bool searchable = false,
  }) async {
    final doc = await db.getDocument(documentId);
    final pages = await db.getPagesForDocument(documentId);
    final pdfDoc = pw.Document();

    for (final page in pages) {
      final imagePath = page.processedImagePath ?? page.originalImagePath;
      final imageBytes = await ImageProcessingService.resizeForExport(
        imagePath, quality,
      );
      if (imageBytes.isEmpty) continue;

      final pdfImage = pw.MemoryImage(imageBytes);

      if (searchable && page.recognizedText.isNotEmpty) {
        // Searchable PDF: image + invisible text overlay
        pdfDoc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.zero,
            build: (context) {
              return pw.Stack(
                children: [
                  pw.Positioned.fill(
                    child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
                  ),
                  // Invisible text layer for searchability
                  ..._buildTextOverlay(page, context.page.pageFormat),
                ],
              );
            },
          ),
        );
      } else {
        // Simple image PDF
        pdfDoc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.zero,
            build: (context) {
              return pw.Center(
                child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
              );
            },
          ),
        );
      }
    }

    // Save PDF
    final outputDir = await getTemporaryDirectory();
    final sanitizedTitle = doc.title
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    final outputPath = p.join(outputDir.path, '$sanitizedTitle.pdf');
    final file = File(outputPath);
    await file.writeAsBytes(await pdfDoc.save());

    return outputPath;
  }

  /// Builds invisible text widgets positioned over OCR bounding boxes.
  List<pw.Widget> _buildTextOverlay(ScanPage page, PdfPageFormat pageFormat) {
    if (page.textBlocksJson.isEmpty || page.textBlocksJson == '[]') return [];

    try {
      final blocks = jsonDecode(page.textBlocksJson) as List;
      final widgets = <pw.Widget>[];

      for (final block in blocks) {
        final text = block['text'] as String? ?? '';
        final rect = block['rect'] as Map<String, dynamic>?;
        if (text.isEmpty || rect == null) continue;

        // Scale bounding box coordinates to PDF page coordinates
        // OCR coordinates are in image pixels; we need to scale to page format
        final left = (rect['left'] as num).toDouble();
        final top = (rect['top'] as num).toDouble();

        widgets.add(
          pw.Positioned(
            left: left * pageFormat.width / 1800, // approximate scale
            top: top * pageFormat.height / 2400,
            child: pw.Text(
              text,
              style: pw.TextStyle(
                fontSize: 1,
                color: PdfColor.fromInt(0x00000000), // Fully transparent
              ),
            ),
          ),
        );
      }

      return widgets;
    } catch (_) {
      return [];
    }
  }

  /// Exports a single page as JPG. Returns the file path.
  Future<String> exportJpg(
    ScanPage page, {
    String quality = 'balanced',
  }) async {
    final imagePath = page.processedImagePath ?? page.originalImagePath;
    final imageBytes = await ImageProcessingService.resizeForExport(
      imagePath, quality,
    );

    final outputDir = await getTemporaryDirectory();
    final outputPath = p.join(outputDir.path, 'page_${page.sortOrder + 1}.jpg');
    await File(outputPath).writeAsBytes(imageBytes);

    return outputPath;
  }

  /// Exports all pages as individual JPGs. Returns list of file paths.
  Future<List<String>> exportAllJpgs(
    int documentId, {
    String quality = 'balanced',
  }) async {
    final pages = await db.getPagesForDocument(documentId);
    final paths = <String>[];
    for (final page in pages) {
      final path = await exportJpg(page, quality: quality);
      paths.add(path);
    }
    return paths;
  }

  /// Shares a PDF via the system share sheet.
  Future<void> sharePdf(String pdfPath) async {
    await Share.shareXFiles(
      [XFile(pdfPath)],
      subject: p.basenameWithoutExtension(pdfPath),
    );
  }

  /// Shares JPGs via the system share sheet.
  Future<void> shareJpgs(List<String> paths) async {
    await Share.shareXFiles(
      paths.map((p) => XFile(p)).toList(),
    );
  }

  /// Shares text (OCR results).
  Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }

  /// Prints a PDF.
  Future<void> printPdf(String pdfPath) async {
    final bytes = await File(pdfPath).readAsBytes();
    await Printing.layoutPdf(
      onLayout: (_) => bytes,
      name: p.basenameWithoutExtension(pdfPath),
    );
  }
}
