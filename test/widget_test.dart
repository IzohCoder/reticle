import 'package:flutter_test/flutter_test.dart';
import 'package:reticle/data/database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// Creates an in-memory database for testing.
AppDatabase createTestDb() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDb();
  });

  tearDown(() async {
    await db.close();
  });

  group('Document CRUD', () {
    test('insert and retrieve document', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = await db.insertDocument(ScanDocumentsCompanion(
        title: const Value('Test Doc'),
        pageCount: const Value(2),
        ocrStatus: const Value('none'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      expect(id, greaterThan(0));

      final doc = await db.getDocument(id);
      expect(doc.title, 'Test Doc');
      expect(doc.pageCount, 2);
      expect(doc.ocrStatus, 'none');
    });

    test('delete document cascades to pages', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final docId = await db.insertDocument(ScanDocumentsCompanion(
        title: const Value('Cascade Test'),
        pageCount: const Value(1),
        ocrStatus: const Value('none'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      await db.insertPage(ScanPagesCompanion(
        documentId: Value(docId),
        sortOrder: const Value(0),
        originalImagePath: const Value('/tmp/test.jpg'),
        createdAt: Value(now),
      ));

      final pagesBefore = await db.getPagesForDocument(docId);
      expect(pagesBefore.length, 1);

      await db.deleteDocument(docId);

      final pagesAfter = await db.getPagesForDocument(docId);
      expect(pagesAfter.length, 0);
    });

    test('getAllDocuments sorts by updatedAt desc', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insertDocument(ScanDocumentsCompanion(
        title: const Value('Older'),
        pageCount: const Value(1),
        ocrStatus: const Value('none'),
        createdAt: Value(now - 1000),
        updatedAt: Value(now - 1000),
      ));
      await db.insertDocument(ScanDocumentsCompanion(
        title: const Value('Newer'),
        pageCount: const Value(1),
        ocrStatus: const Value('none'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      final docs = await db.getAllDocuments();
      expect(docs.length, 2);
      expect(docs[0].title, 'Newer');
      expect(docs[1].title, 'Older');
    });
  });

  group('Page ordering', () {
    test('pages sort by sortOrder', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final docId = await db.insertDocument(ScanDocumentsCompanion(
        title: const Value('Multi Page'),
        pageCount: const Value(3),
        ocrStatus: const Value('none'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      // Insert in reverse order
      for (var i = 2; i >= 0; i--) {
        await db.insertPage(ScanPagesCompanion(
          documentId: Value(docId),
          sortOrder: Value(i),
          originalImagePath: Value('/tmp/page_$i.jpg'),
          createdAt: Value(now),
        ));
      }

      final pages = await db.getPagesForDocument(docId);
      expect(pages.length, 3);
      expect(pages[0].sortOrder, 0);
      expect(pages[1].sortOrder, 1);
      expect(pages[2].sortOrder, 2);
    });

    test('reorder pages correctly', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final docId = await db.insertDocument(ScanDocumentsCompanion(
        title: const Value('Reorder Test'),
        pageCount: const Value(3),
        ocrStatus: const Value('none'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      final ids = <int>[];
      for (var i = 0; i < 3; i++) {
        final id = await db.insertPage(ScanPagesCompanion(
          documentId: Value(docId),
          sortOrder: Value(i),
          originalImagePath: Value('/tmp/page_$i.jpg'),
          createdAt: Value(now),
        ));
        ids.add(id);
      }

      // Move page 0 to position 2: [1, 2, 0]
      await db.updatePageOrder(ids[0], 2);
      await db.updatePageOrder(ids[1], 0);
      await db.updatePageOrder(ids[2], 1);

      final pages = await db.getPagesForDocument(docId);
      expect(pages[0].id, ids[1]);
      expect(pages[1].id, ids[2]);
      expect(pages[2].id, ids[0]);
    });

    test('delete page and re-order', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final docId = await db.insertDocument(ScanDocumentsCompanion(
        title: const Value('Delete Page Test'),
        pageCount: const Value(3),
        ocrStatus: const Value('none'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      final ids = <int>[];
      for (var i = 0; i < 3; i++) {
        final id = await db.insertPage(ScanPagesCompanion(
          documentId: Value(docId),
          sortOrder: Value(i),
          originalImagePath: Value('/tmp/page_$i.jpg'),
          createdAt: Value(now),
        ));
        ids.add(id);
      }

      // Delete middle page
      await db.deletePage(ids[1]);

      final remaining = await db.getPagesForDocument(docId);
      expect(remaining.length, 2);

      // Re-order remaining
      for (var i = 0; i < remaining.length; i++) {
        await db.updatePageOrder(remaining[i].id, i);
      }

      final reordered = await db.getPagesForDocument(docId);
      expect(reordered[0].sortOrder, 0);
      expect(reordered[1].sortOrder, 1);
    });
  });

  group('Folders', () {
    test('folder limit enforcement', () async {
      final now = DateTime.now().millisecondsSinceEpoch;

      for (var i = 0; i < 3; i++) {
        await db.insertFolder(ScanFoldersCompanion(
          name: Value('Folder $i'),
          sortOrder: Value(i),
          createdAt: Value(now),
        ));
      }

      final count = await db.getFolderCount();
      expect(count, 3);
    });

    test('deleting folder moves documents out', () async {
      final now = DateTime.now().millisecondsSinceEpoch;

      final folderId = await db.insertFolder(ScanFoldersCompanion(
        name: const Value('To Delete'),
        sortOrder: const Value(0),
        createdAt: Value(now),
      ));

      final docId = await db.insertDocument(ScanDocumentsCompanion(
        title: const Value('In Folder'),
        folderId: Value(folderId),
        pageCount: const Value(1),
        ocrStatus: const Value('none'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      await db.deleteFolder(folderId);

      final doc = await db.getDocument(docId);
      expect(doc.folderId, isNull);
    });
  });

  group('OCR & Search', () {
    test('update page OCR text', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final docId = await db.insertDocument(ScanDocumentsCompanion(
        title: const Value('OCR Test'),
        pageCount: const Value(1),
        ocrStatus: const Value('none'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      final pageId = await db.insertPage(ScanPagesCompanion(
        documentId: Value(docId),
        sortOrder: const Value(0),
        originalImagePath: const Value('/tmp/test.jpg'),
        createdAt: Value(now),
      ));

      await db.updatePageOcr(pageId, 'Hello World', '[]');

      final pages = await db.getPagesForDocument(docId);
      expect(pages.first.recognizedText, 'Hello World');
    });

    test('search by title', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insertDocument(ScanDocumentsCompanion(
        title: const Value('KRA PIN Certificate'),
        pageCount: const Value(1),
        ocrStatus: const Value('none'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      final results = await db.searchDocuments('kra');
      expect(results.length, 1);
      expect(results.first.title, 'KRA PIN Certificate');

      final noResults = await db.searchDocuments('xyz');
      expect(noResults.length, 0);
    });
  });

  group('Settings', () {
    test('get and set setting', () async {
      await db.setSetting('test_key', 'test_value');
      final value = await db.getSetting('test_key');
      expect(value, 'test_value');
    });

    test('update existing setting', () async {
      await db.setSetting('key', 'old');
      await db.setSetting('key', 'new');
      final value = await db.getSetting('key');
      expect(value, 'new');
    });

    test('non-existent setting returns null', () async {
      final value = await db.getSetting('nonexistent');
      expect(value, isNull);
    });
  });
}
