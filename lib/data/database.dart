import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

// ---------------------------------------------------------------------------
// Tables
// ---------------------------------------------------------------------------

/// A scanned document containing one or more pages.
class ScanDocuments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get folderId => integer().nullable().references(ScanFolders, #id)();
  IntColumn get pageCount => integer().withDefault(const Constant(0))();
  /// 'none' | 'partial' | 'complete'
  TextColumn get ocrStatus => text().withDefault(const Constant('none'))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
}

/// An individual page within a document.
class ScanPages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get documentId => integer().references(ScanDocuments, #id)();
  IntColumn get sortOrder => integer()();
  TextColumn get originalImagePath => text()();
  TextColumn get processedImagePath => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();
  /// 'original' | 'enhanced' | 'bw' | 'grayscale' | 'blueprint'
  TextColumn get filterType =>
      text().withDefault(const Constant('original'))();
  /// JSON array of 4 corner points [{x,y}, ...]
  TextColumn get cornerPointsJson => text().nullable()();
  /// 0, 90, 180, 270
  IntColumn get rotation => integer().withDefault(const Constant(0))();
  TextColumn get recognizedText => text().withDefault(const Constant(''))();
  /// JSON bounding boxes for searchable PDF overlay
  TextColumn get textBlocksJson =>
      text().withDefault(const Constant('[]'))();
  IntColumn get createdAt => integer()();
}

/// Organizational folders for documents.
class ScanFolders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get colorHex =>
      text().withDefault(const Constant('#6B6B6B'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
}

/// Key-value settings store.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [
  ScanDocuments,
  ScanPages,
  ScanFolders,
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructor for testing with a custom executor.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Create FTS5 virtual table for full-text search on recognized text
          await customStatement('''
            CREATE VIRTUAL TABLE IF NOT EXISTS scan_pages_fts
            USING fts5(recognized_text, content='scan_pages', content_rowid='id')
          ''');
          // Triggers to keep FTS in sync
          await customStatement('''
            CREATE TRIGGER IF NOT EXISTS scan_pages_ai AFTER INSERT ON scan_pages BEGIN
              INSERT INTO scan_pages_fts(rowid, recognized_text) VALUES (new.id, new.recognized_text);
            END
          ''');
          await customStatement('''
            CREATE TRIGGER IF NOT EXISTS scan_pages_ad AFTER DELETE ON scan_pages BEGIN
              INSERT INTO scan_pages_fts(scan_pages_fts, rowid, recognized_text) VALUES('delete', old.id, old.recognized_text);
            END
          ''');
          await customStatement('''
            CREATE TRIGGER IF NOT EXISTS scan_pages_au AFTER UPDATE ON scan_pages BEGIN
              INSERT INTO scan_pages_fts(scan_pages_fts, rowid, recognized_text) VALUES('delete', old.id, old.recognized_text);
              INSERT INTO scan_pages_fts(rowid, recognized_text) VALUES (new.id, new.recognized_text);
            END
          ''');
        },
        onUpgrade: (m, from, to) async {
          // Future migrations
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'reticle_db');
  }

  // ---------------------------------------------------------------------------
  // Document queries
  // ---------------------------------------------------------------------------

  Future<List<ScanDocument>> getAllDocuments({String? sortBy}) async {
    final query = select(scanDocuments);
    if (sortBy == 'name') {
      query.orderBy([(t) => OrderingTerm.asc(t.title)]);
    } else if (sortBy == 'size') {
      query.orderBy([(t) => OrderingTerm.desc(t.pageCount)]);
    } else {
      query.orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    }
    return query.get();
  }

  Future<List<ScanDocument>> getDocumentsInFolder(int folderId) {
    return (select(scanDocuments)
          ..where((t) => t.folderId.equals(folderId))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  Future<List<ScanDocument>> getRecentDocuments({int limit = 10}) {
    return (select(scanDocuments)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
          ..limit(limit))
        .get();
  }

  Stream<List<ScanDocument>> watchAllDocuments() {
    return (select(scanDocuments)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  Future<ScanDocument> getDocument(int id) {
    return (select(scanDocuments)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<int> insertDocument(ScanDocumentsCompanion doc) {
    return into(scanDocuments).insert(doc);
  }

  Future<bool> updateDocument(ScanDocumentsCompanion doc) {
    return update(scanDocuments).replace(doc.toColumns(false).containsKey('id')
        ? ScanDocument(
            id: doc.id.value,
            title: doc.title.value,
            folderId: doc.folderId.present ? doc.folderId.value : null,
            pageCount: doc.pageCount.value,
            ocrStatus: doc.ocrStatus.value,
            createdAt: doc.createdAt.value,
            updatedAt: doc.updatedAt.value,
          )
        : throw StateError('Document must have an id'));
  }

  Future<void> deleteDocument(int id) async {
    await (delete(scanPages)..where((t) => t.documentId.equals(id))).go();
    await (delete(scanDocuments)..where((t) => t.id.equals(id))).go();
  }

  // ---------------------------------------------------------------------------
  // Page queries
  // ---------------------------------------------------------------------------

  Future<List<ScanPage>> getPagesForDocument(int documentId) {
    return (select(scanPages)
          ..where((t) => t.documentId.equals(documentId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Stream<List<ScanPage>> watchPagesForDocument(int documentId) {
    return (select(scanPages)
          ..where((t) => t.documentId.equals(documentId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Future<int> insertPage(ScanPagesCompanion page) {
    return into(scanPages).insert(page);
  }

  Future<void> deletePage(int id) {
    return (delete(scanPages)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updatePageOrder(int pageId, int newOrder) {
    return (update(scanPages)..where((t) => t.id.equals(pageId)))
        .write(ScanPagesCompanion(sortOrder: Value(newOrder)));
  }

  Future<void> updatePageOcr(
      int pageId, String text, String blocksJson) {
    return (update(scanPages)..where((t) => t.id.equals(pageId))).write(
      ScanPagesCompanion(
        recognizedText: Value(text),
        textBlocksJson: Value(blocksJson),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Folder queries
  // ---------------------------------------------------------------------------

  Future<List<ScanFolder>> getAllFolders() {
    return (select(scanFolders)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Stream<List<ScanFolder>> watchAllFolders() {
    return (select(scanFolders)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Future<int> getFolderCount() async {
    final count = countAll();
    final query = selectOnly(scanFolders)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<int> insertFolder(ScanFoldersCompanion folder) {
    return into(scanFolders).insert(folder);
  }

  Future<void> deleteFolder(int id) async {
    // Move documents out of folder before deleting
    await (update(scanDocuments)..where((t) => t.folderId.equals(id)))
        .write(const ScanDocumentsCompanion(folderId: Value(null)));
    await (delete(scanFolders)..where((t) => t.id.equals(id))).go();
  }

  // ---------------------------------------------------------------------------
  // Full-text search
  // ---------------------------------------------------------------------------

  /// Search documents by title or OCR text content.
  Future<List<ScanDocument>> searchDocuments(String query) async {
    if (query.trim().isEmpty) return [];

    final titleQuery = '%${query.toLowerCase()}%';

    // Search by title
    final titleResults = await (select(scanDocuments)
          ..where((t) => t.title.lower().like(titleQuery)))
        .get();

    // Search by OCR text using FTS5
    final ftsResults = await customSelect(
      'SELECT document_id FROM scan_pages WHERE id IN '
      '(SELECT rowid FROM scan_pages_fts WHERE scan_pages_fts MATCH ?)',
      variables: [Variable.withString(query)],
    ).get();

    final ocrDocIds =
        ftsResults.map((r) => r.read<int>('document_id')).toSet();

    // Merge results
    final allIds = <int>{...titleResults.map((d) => d.id), ...ocrDocIds};

    if (allIds.isEmpty) return [];

    return (select(scanDocuments)
          ..where((t) => t.id.isIn(allIds))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------

  Future<String?> getSetting(String key) async {
    final result = await (select(appSettings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return result?.value;
  }

  Future<void> setSetting(String key, String value) {
    return into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(
        key: Value(key),
        value: Value(value),
      ),
    );
  }
}
