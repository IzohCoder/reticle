import 'package:drift/drift.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../data/database.dart';
import 'image_processing_service.dart';

/// Orchestrates document scanning: camera → save files → create DB records.
class ScannerService {
  final AppDatabase db;

  ScannerService(this.db);

  /// Launches the native document scanner and returns the document ID,
  /// or null if the user cancelled.
  Future<int?> scanDocument({int? existingDocId, String mode = 'document'}) async {
    try {
      final paths = await CunningDocumentScanner.getPictures(
        noOfPages: mode == 'idcard' ? 2 : 100,
        scannerSource: ScannerSource.camera,
        androidScannerMode: AndroidScannerMode.full,
      );

      if (paths == null || paths.isEmpty) return null;

      // Create or reuse document
      final now = DateTime.now().millisecondsSinceEpoch;
      final docId = existingDocId ?? await db.insertDocument(
        ScanDocumentsCompanion(
          title: Value(_generateTitle(mode)),
          pageCount: Value(paths.length),
          ocrStatus: const Value('none'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await ImageProcessingService.ensureDirectories(docId);

      // Get existing page count for sort order
      final existingPages = await db.getPagesForDocument(docId);
      int sortOrder = existingPages.length;

      // Save each scanned page
      for (final path in paths) {
        final pageId = await db.insertPage(ScanPagesCompanion(
          documentId: Value(docId),
          sortOrder: Value(sortOrder),
          originalImagePath: Value(path), // Temporary — will be updated
          createdAt: Value(now),
        ));

        // Copy to app storage
        final savedPath = await ImageProcessingService.saveOriginal(
          path, docId, pageId,
        );

        // Generate thumbnail
        final thumbPath = await ImageProcessingService.generateThumbnail(
          savedPath, docId, pageId,
        );

        // Update with permanent paths
        await (db.update(db.scanPages)..where((t) => t.id.equals(pageId)))
            .write(ScanPagesCompanion(
          originalImagePath: Value(savedPath),
          thumbnailPath: Value(thumbPath),
        ));

        sortOrder++;
      }

      // Update document page count
      final totalPages = await db.getPagesForDocument(docId);
      await (db.update(db.scanDocuments)..where((t) => t.id.equals(docId)))
          .write(ScanDocumentsCompanion(
        pageCount: Value(totalPages.length),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ));

      // Clean scanner cache
      await CunningDocumentScanner.cleanCache();

      return docId;
    } on CunningDocumentScannerException catch (e) {
      if (e.code == 'permission_denied') {
        rethrow;
      }
      return null;
    }
  }

  /// Imports an image from gallery and adds it to a document.
  Future<int?> importFromGallery({int? existingDocId}) async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      imageQuality: 90,
      maxWidth: 3000,
    );

    if (images.isEmpty) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    final docId = existingDocId ?? await db.insertDocument(
      ScanDocumentsCompanion(
        title: Value(_generateTitle('gallery')),
        pageCount: Value(images.length),
        ocrStatus: const Value('none'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    await ImageProcessingService.ensureDirectories(docId);

    final existingPages = await db.getPagesForDocument(docId);
    int sortOrder = existingPages.length;

    for (final xfile in images) {
      final pageId = await db.insertPage(ScanPagesCompanion(
        documentId: Value(docId),
        sortOrder: Value(sortOrder),
        originalImagePath: Value(xfile.path),
        createdAt: Value(now),
      ));

      final savedPath = await ImageProcessingService.saveOriginal(
        xfile.path, docId, pageId,
      );
      final thumbPath = await ImageProcessingService.generateThumbnail(
        savedPath, docId, pageId,
      );

      await (db.update(db.scanPages)..where((t) => t.id.equals(pageId)))
          .write(ScanPagesCompanion(
        originalImagePath: Value(savedPath),
        thumbnailPath: Value(thumbPath),
      ));

      sortOrder++;
    }

    final totalPages = await db.getPagesForDocument(docId);
    await (db.update(db.scanDocuments)..where((t) => t.id.equals(docId)))
        .write(ScanDocumentsCompanion(
      pageCount: Value(totalPages.length),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));

    return docId;
  }

  /// Scans an ID card (front + back) and places both on one A4 page.
  Future<int?> scanIdCard() async {
    return scanDocument(mode: 'idcard');
  }

  /// Generates a default title based on mode and timestamp.
  String _generateTitle(String mode) {
    final now = DateTime.now();
    final date = '${now.day}/${now.month}/${now.year}';
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    switch (mode) {
      case 'idcard':
        return 'ID Card $date';
      case 'gallery':
        return 'Import $date $time';
      default:
        return 'Scan $date $time';
    }
  }
}
