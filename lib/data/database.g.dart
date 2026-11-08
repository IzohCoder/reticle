// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ScanDocumentsTable extends ScanDocuments
    with TableInfo<$ScanDocumentsTable, ScanDocument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _folderIdMeta =
      const VerificationMeta('folderId');
  @override
  late final GeneratedColumn<int> folderId = GeneratedColumn<int>(
      'folder_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _pageCountMeta =
      const VerificationMeta('pageCount');
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
      'page_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _ocrStatusMeta =
      const VerificationMeta('ocrStatus');
  @override
  late final GeneratedColumn<String> ocrStatus = GeneratedColumn<String>(
      'ocr_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('none'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, folderId, pageCount, ocrStatus, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_documents';
  @override
  VerificationContext validateIntegrity(Insertable<ScanDocument> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(_folderIdMeta,
          folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta));
    }
    if (data.containsKey('page_count')) {
      context.handle(_pageCountMeta,
          pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta));
    }
    if (data.containsKey('ocr_status')) {
      context.handle(_ocrStatusMeta,
          ocrStatus.isAcceptableOrUnknown(data['ocr_status']!, _ocrStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanDocument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanDocument(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      folderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}folder_id']),
      pageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_count'])!,
      ocrStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ocr_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ScanDocumentsTable createAlias(String alias) {
    return $ScanDocumentsTable(attachedDatabase, alias);
  }
}

class ScanDocument extends DataClass implements Insertable<ScanDocument> {
  final int id;
  final String title;
  final int? folderId;
  final int pageCount;

  /// 'none' | 'partial' | 'complete'
  final String ocrStatus;
  final int createdAt;
  final int updatedAt;
  const ScanDocument(
      {required this.id,
      required this.title,
      this.folderId,
      required this.pageCount,
      required this.ocrStatus,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<int>(folderId);
    }
    map['page_count'] = Variable<int>(pageCount);
    map['ocr_status'] = Variable<String>(ocrStatus);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ScanDocumentsCompanion toCompanion(bool nullToAbsent) {
    return ScanDocumentsCompanion(
      id: Value(id),
      title: Value(title),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
      pageCount: Value(pageCount),
      ocrStatus: Value(ocrStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ScanDocument.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanDocument(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      folderId: serializer.fromJson<int?>(json['folderId']),
      pageCount: serializer.fromJson<int>(json['pageCount']),
      ocrStatus: serializer.fromJson<String>(json['ocrStatus']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'folderId': serializer.toJson<int?>(folderId),
      'pageCount': serializer.toJson<int>(pageCount),
      'ocrStatus': serializer.toJson<String>(ocrStatus),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ScanDocument copyWith(
          {int? id,
          String? title,
          Value<int?> folderId = const Value.absent(),
          int? pageCount,
          String? ocrStatus,
          int? createdAt,
          int? updatedAt}) =>
      ScanDocument(
        id: id ?? this.id,
        title: title ?? this.title,
        folderId: folderId.present ? folderId.value : this.folderId,
        pageCount: pageCount ?? this.pageCount,
        ocrStatus: ocrStatus ?? this.ocrStatus,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ScanDocument copyWithCompanion(ScanDocumentsCompanion data) {
    return ScanDocument(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      ocrStatus: data.ocrStatus.present ? data.ocrStatus.value : this.ocrStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanDocument(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('folderId: $folderId, ')
          ..write('pageCount: $pageCount, ')
          ..write('ocrStatus: $ocrStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, title, folderId, pageCount, ocrStatus, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanDocument &&
          other.id == this.id &&
          other.title == this.title &&
          other.folderId == this.folderId &&
          other.pageCount == this.pageCount &&
          other.ocrStatus == this.ocrStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ScanDocumentsCompanion extends UpdateCompanion<ScanDocument> {
  final Value<int> id;
  final Value<String> title;
  final Value<int?> folderId;
  final Value<int> pageCount;
  final Value<String> ocrStatus;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const ScanDocumentsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.folderId = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.ocrStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ScanDocumentsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.folderId = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.ocrStatus = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  })  : title = Value(title),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ScanDocument> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? folderId,
    Expression<int>? pageCount,
    Expression<String>? ocrStatus,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (folderId != null) 'folder_id': folderId,
      if (pageCount != null) 'page_count': pageCount,
      if (ocrStatus != null) 'ocr_status': ocrStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ScanDocumentsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<int?>? folderId,
      Value<int>? pageCount,
      Value<String>? ocrStatus,
      Value<int>? createdAt,
      Value<int>? updatedAt}) {
    return ScanDocumentsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      folderId: folderId ?? this.folderId,
      pageCount: pageCount ?? this.pageCount,
      ocrStatus: ocrStatus ?? this.ocrStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<int>(folderId.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (ocrStatus.present) {
      map['ocr_status'] = Variable<String>(ocrStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanDocumentsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('folderId: $folderId, ')
          ..write('pageCount: $pageCount, ')
          ..write('ocrStatus: $ocrStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ScanPagesTable extends ScanPages
    with TableInfo<$ScanPagesTable, ScanPage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanPagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _documentIdMeta =
      const VerificationMeta('documentId');
  @override
  late final GeneratedColumn<int> documentId = GeneratedColumn<int>(
      'document_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _originalImagePathMeta =
      const VerificationMeta('originalImagePath');
  @override
  late final GeneratedColumn<String> originalImagePath =
      GeneratedColumn<String>('original_image_path', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _processedImagePathMeta =
      const VerificationMeta('processedImagePath');
  @override
  late final GeneratedColumn<String> processedImagePath =
      GeneratedColumn<String>('processed_image_path', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailPathMeta =
      const VerificationMeta('thumbnailPath');
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
      'thumbnail_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _filterTypeMeta =
      const VerificationMeta('filterType');
  @override
  late final GeneratedColumn<String> filterType = GeneratedColumn<String>(
      'filter_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('original'));
  static const VerificationMeta _cornerPointsJsonMeta =
      const VerificationMeta('cornerPointsJson');
  @override
  late final GeneratedColumn<String> cornerPointsJson = GeneratedColumn<String>(
      'corner_points_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rotationMeta =
      const VerificationMeta('rotation');
  @override
  late final GeneratedColumn<int> rotation = GeneratedColumn<int>(
      'rotation', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _recognizedTextMeta =
      const VerificationMeta('recognizedText');
  @override
  late final GeneratedColumn<String> recognizedText = GeneratedColumn<String>(
      'recognized_text', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _textBlocksJsonMeta =
      const VerificationMeta('textBlocksJson');
  @override
  late final GeneratedColumn<String> textBlocksJson = GeneratedColumn<String>(
      'text_blocks_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        documentId,
        sortOrder,
        originalImagePath,
        processedImagePath,
        thumbnailPath,
        filterType,
        cornerPointsJson,
        rotation,
        recognizedText,
        textBlocksJson,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_pages';
  @override
  VerificationContext validateIntegrity(Insertable<ScanPage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('document_id')) {
      context.handle(
          _documentIdMeta,
          documentId.isAcceptableOrUnknown(
              data['document_id']!, _documentIdMeta));
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('original_image_path')) {
      context.handle(
          _originalImagePathMeta,
          originalImagePath.isAcceptableOrUnknown(
              data['original_image_path']!, _originalImagePathMeta));
    } else if (isInserting) {
      context.missing(_originalImagePathMeta);
    }
    if (data.containsKey('processed_image_path')) {
      context.handle(
          _processedImagePathMeta,
          processedImagePath.isAcceptableOrUnknown(
              data['processed_image_path']!, _processedImagePathMeta));
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
          _thumbnailPathMeta,
          thumbnailPath.isAcceptableOrUnknown(
              data['thumbnail_path']!, _thumbnailPathMeta));
    }
    if (data.containsKey('filter_type')) {
      context.handle(
          _filterTypeMeta,
          filterType.isAcceptableOrUnknown(
              data['filter_type']!, _filterTypeMeta));
    }
    if (data.containsKey('corner_points_json')) {
      context.handle(
          _cornerPointsJsonMeta,
          cornerPointsJson.isAcceptableOrUnknown(
              data['corner_points_json']!, _cornerPointsJsonMeta));
    }
    if (data.containsKey('rotation')) {
      context.handle(_rotationMeta,
          rotation.isAcceptableOrUnknown(data['rotation']!, _rotationMeta));
    }
    if (data.containsKey('recognized_text')) {
      context.handle(
          _recognizedTextMeta,
          recognizedText.isAcceptableOrUnknown(
              data['recognized_text']!, _recognizedTextMeta));
    }
    if (data.containsKey('text_blocks_json')) {
      context.handle(
          _textBlocksJsonMeta,
          textBlocksJson.isAcceptableOrUnknown(
              data['text_blocks_json']!, _textBlocksJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanPage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanPage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      documentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}document_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      originalImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}original_image_path'])!,
      processedImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}processed_image_path']),
      thumbnailPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_path']),
      filterType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}filter_type'])!,
      cornerPointsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}corner_points_json']),
      rotation: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rotation'])!,
      recognizedText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recognized_text'])!,
      textBlocksJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}text_blocks_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ScanPagesTable createAlias(String alias) {
    return $ScanPagesTable(attachedDatabase, alias);
  }
}

class ScanPage extends DataClass implements Insertable<ScanPage> {
  final int id;
  final int documentId;
  final int sortOrder;
  final String originalImagePath;
  final String? processedImagePath;
  final String? thumbnailPath;

  /// 'original' | 'enhanced' | 'bw' | 'grayscale' | 'blueprint'
  final String filterType;

  /// JSON array of 4 corner points [{x,y}, ...]
  final String? cornerPointsJson;

  /// 0, 90, 180, 270
  final int rotation;
  final String recognizedText;

  /// JSON bounding boxes for searchable PDF overlay
  final String textBlocksJson;
  final int createdAt;
  const ScanPage(
      {required this.id,
      required this.documentId,
      required this.sortOrder,
      required this.originalImagePath,
      this.processedImagePath,
      this.thumbnailPath,
      required this.filterType,
      this.cornerPointsJson,
      required this.rotation,
      required this.recognizedText,
      required this.textBlocksJson,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['document_id'] = Variable<int>(documentId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['original_image_path'] = Variable<String>(originalImagePath);
    if (!nullToAbsent || processedImagePath != null) {
      map['processed_image_path'] = Variable<String>(processedImagePath);
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    map['filter_type'] = Variable<String>(filterType);
    if (!nullToAbsent || cornerPointsJson != null) {
      map['corner_points_json'] = Variable<String>(cornerPointsJson);
    }
    map['rotation'] = Variable<int>(rotation);
    map['recognized_text'] = Variable<String>(recognizedText);
    map['text_blocks_json'] = Variable<String>(textBlocksJson);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ScanPagesCompanion toCompanion(bool nullToAbsent) {
    return ScanPagesCompanion(
      id: Value(id),
      documentId: Value(documentId),
      sortOrder: Value(sortOrder),
      originalImagePath: Value(originalImagePath),
      processedImagePath: processedImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(processedImagePath),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      filterType: Value(filterType),
      cornerPointsJson: cornerPointsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(cornerPointsJson),
      rotation: Value(rotation),
      recognizedText: Value(recognizedText),
      textBlocksJson: Value(textBlocksJson),
      createdAt: Value(createdAt),
    );
  }

  factory ScanPage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanPage(
      id: serializer.fromJson<int>(json['id']),
      documentId: serializer.fromJson<int>(json['documentId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      originalImagePath: serializer.fromJson<String>(json['originalImagePath']),
      processedImagePath:
          serializer.fromJson<String?>(json['processedImagePath']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      filterType: serializer.fromJson<String>(json['filterType']),
      cornerPointsJson: serializer.fromJson<String?>(json['cornerPointsJson']),
      rotation: serializer.fromJson<int>(json['rotation']),
      recognizedText: serializer.fromJson<String>(json['recognizedText']),
      textBlocksJson: serializer.fromJson<String>(json['textBlocksJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'documentId': serializer.toJson<int>(documentId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'originalImagePath': serializer.toJson<String>(originalImagePath),
      'processedImagePath': serializer.toJson<String?>(processedImagePath),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'filterType': serializer.toJson<String>(filterType),
      'cornerPointsJson': serializer.toJson<String?>(cornerPointsJson),
      'rotation': serializer.toJson<int>(rotation),
      'recognizedText': serializer.toJson<String>(recognizedText),
      'textBlocksJson': serializer.toJson<String>(textBlocksJson),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ScanPage copyWith(
          {int? id,
          int? documentId,
          int? sortOrder,
          String? originalImagePath,
          Value<String?> processedImagePath = const Value.absent(),
          Value<String?> thumbnailPath = const Value.absent(),
          String? filterType,
          Value<String?> cornerPointsJson = const Value.absent(),
          int? rotation,
          String? recognizedText,
          String? textBlocksJson,
          int? createdAt}) =>
      ScanPage(
        id: id ?? this.id,
        documentId: documentId ?? this.documentId,
        sortOrder: sortOrder ?? this.sortOrder,
        originalImagePath: originalImagePath ?? this.originalImagePath,
        processedImagePath: processedImagePath.present
            ? processedImagePath.value
            : this.processedImagePath,
        thumbnailPath:
            thumbnailPath.present ? thumbnailPath.value : this.thumbnailPath,
        filterType: filterType ?? this.filterType,
        cornerPointsJson: cornerPointsJson.present
            ? cornerPointsJson.value
            : this.cornerPointsJson,
        rotation: rotation ?? this.rotation,
        recognizedText: recognizedText ?? this.recognizedText,
        textBlocksJson: textBlocksJson ?? this.textBlocksJson,
        createdAt: createdAt ?? this.createdAt,
      );
  ScanPage copyWithCompanion(ScanPagesCompanion data) {
    return ScanPage(
      id: data.id.present ? data.id.value : this.id,
      documentId:
          data.documentId.present ? data.documentId.value : this.documentId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      originalImagePath: data.originalImagePath.present
          ? data.originalImagePath.value
          : this.originalImagePath,
      processedImagePath: data.processedImagePath.present
          ? data.processedImagePath.value
          : this.processedImagePath,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      filterType:
          data.filterType.present ? data.filterType.value : this.filterType,
      cornerPointsJson: data.cornerPointsJson.present
          ? data.cornerPointsJson.value
          : this.cornerPointsJson,
      rotation: data.rotation.present ? data.rotation.value : this.rotation,
      recognizedText: data.recognizedText.present
          ? data.recognizedText.value
          : this.recognizedText,
      textBlocksJson: data.textBlocksJson.present
          ? data.textBlocksJson.value
          : this.textBlocksJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanPage(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('originalImagePath: $originalImagePath, ')
          ..write('processedImagePath: $processedImagePath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('filterType: $filterType, ')
          ..write('cornerPointsJson: $cornerPointsJson, ')
          ..write('rotation: $rotation, ')
          ..write('recognizedText: $recognizedText, ')
          ..write('textBlocksJson: $textBlocksJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      documentId,
      sortOrder,
      originalImagePath,
      processedImagePath,
      thumbnailPath,
      filterType,
      cornerPointsJson,
      rotation,
      recognizedText,
      textBlocksJson,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanPage &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.sortOrder == this.sortOrder &&
          other.originalImagePath == this.originalImagePath &&
          other.processedImagePath == this.processedImagePath &&
          other.thumbnailPath == this.thumbnailPath &&
          other.filterType == this.filterType &&
          other.cornerPointsJson == this.cornerPointsJson &&
          other.rotation == this.rotation &&
          other.recognizedText == this.recognizedText &&
          other.textBlocksJson == this.textBlocksJson &&
          other.createdAt == this.createdAt);
}

class ScanPagesCompanion extends UpdateCompanion<ScanPage> {
  final Value<int> id;
  final Value<int> documentId;
  final Value<int> sortOrder;
  final Value<String> originalImagePath;
  final Value<String?> processedImagePath;
  final Value<String?> thumbnailPath;
  final Value<String> filterType;
  final Value<String?> cornerPointsJson;
  final Value<int> rotation;
  final Value<String> recognizedText;
  final Value<String> textBlocksJson;
  final Value<int> createdAt;
  const ScanPagesCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.originalImagePath = const Value.absent(),
    this.processedImagePath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.filterType = const Value.absent(),
    this.cornerPointsJson = const Value.absent(),
    this.rotation = const Value.absent(),
    this.recognizedText = const Value.absent(),
    this.textBlocksJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ScanPagesCompanion.insert({
    this.id = const Value.absent(),
    required int documentId,
    required int sortOrder,
    required String originalImagePath,
    this.processedImagePath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.filterType = const Value.absent(),
    this.cornerPointsJson = const Value.absent(),
    this.rotation = const Value.absent(),
    this.recognizedText = const Value.absent(),
    this.textBlocksJson = const Value.absent(),
    required int createdAt,
  })  : documentId = Value(documentId),
        sortOrder = Value(sortOrder),
        originalImagePath = Value(originalImagePath),
        createdAt = Value(createdAt);
  static Insertable<ScanPage> custom({
    Expression<int>? id,
    Expression<int>? documentId,
    Expression<int>? sortOrder,
    Expression<String>? originalImagePath,
    Expression<String>? processedImagePath,
    Expression<String>? thumbnailPath,
    Expression<String>? filterType,
    Expression<String>? cornerPointsJson,
    Expression<int>? rotation,
    Expression<String>? recognizedText,
    Expression<String>? textBlocksJson,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (originalImagePath != null) 'original_image_path': originalImagePath,
      if (processedImagePath != null)
        'processed_image_path': processedImagePath,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (filterType != null) 'filter_type': filterType,
      if (cornerPointsJson != null) 'corner_points_json': cornerPointsJson,
      if (rotation != null) 'rotation': rotation,
      if (recognizedText != null) 'recognized_text': recognizedText,
      if (textBlocksJson != null) 'text_blocks_json': textBlocksJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ScanPagesCompanion copyWith(
      {Value<int>? id,
      Value<int>? documentId,
      Value<int>? sortOrder,
      Value<String>? originalImagePath,
      Value<String?>? processedImagePath,
      Value<String?>? thumbnailPath,
      Value<String>? filterType,
      Value<String?>? cornerPointsJson,
      Value<int>? rotation,
      Value<String>? recognizedText,
      Value<String>? textBlocksJson,
      Value<int>? createdAt}) {
    return ScanPagesCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      sortOrder: sortOrder ?? this.sortOrder,
      originalImagePath: originalImagePath ?? this.originalImagePath,
      processedImagePath: processedImagePath ?? this.processedImagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      filterType: filterType ?? this.filterType,
      cornerPointsJson: cornerPointsJson ?? this.cornerPointsJson,
      rotation: rotation ?? this.rotation,
      recognizedText: recognizedText ?? this.recognizedText,
      textBlocksJson: textBlocksJson ?? this.textBlocksJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<int>(documentId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (originalImagePath.present) {
      map['original_image_path'] = Variable<String>(originalImagePath.value);
    }
    if (processedImagePath.present) {
      map['processed_image_path'] = Variable<String>(processedImagePath.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (filterType.present) {
      map['filter_type'] = Variable<String>(filterType.value);
    }
    if (cornerPointsJson.present) {
      map['corner_points_json'] = Variable<String>(cornerPointsJson.value);
    }
    if (rotation.present) {
      map['rotation'] = Variable<int>(rotation.value);
    }
    if (recognizedText.present) {
      map['recognized_text'] = Variable<String>(recognizedText.value);
    }
    if (textBlocksJson.present) {
      map['text_blocks_json'] = Variable<String>(textBlocksJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanPagesCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('originalImagePath: $originalImagePath, ')
          ..write('processedImagePath: $processedImagePath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('filterType: $filterType, ')
          ..write('cornerPointsJson: $cornerPointsJson, ')
          ..write('rotation: $rotation, ')
          ..write('recognizedText: $recognizedText, ')
          ..write('textBlocksJson: $textBlocksJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ScanFoldersTable extends ScanFolders
    with TableInfo<$ScanFoldersTable, ScanFolder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanFoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorHexMeta =
      const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
      'color_hex', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#6B6B6B'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, colorHex, sortOrder, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_folders';
  @override
  VerificationContext validateIntegrity(Insertable<ScanFolder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanFolder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanFolder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_hex'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ScanFoldersTable createAlias(String alias) {
    return $ScanFoldersTable(attachedDatabase, alias);
  }
}

class ScanFolder extends DataClass implements Insertable<ScanFolder> {
  final int id;
  final String name;
  final String colorHex;
  final int sortOrder;
  final int createdAt;
  const ScanFolder(
      {required this.id,
      required this.name,
      required this.colorHex,
      required this.sortOrder,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color_hex'] = Variable<String>(colorHex);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ScanFoldersCompanion toCompanion(bool nullToAbsent) {
    return ScanFoldersCompanion(
      id: Value(id),
      name: Value(name),
      colorHex: Value(colorHex),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory ScanFolder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanFolder(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'colorHex': serializer.toJson<String>(colorHex),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ScanFolder copyWith(
          {int? id,
          String? name,
          String? colorHex,
          int? sortOrder,
          int? createdAt}) =>
      ScanFolder(
        id: id ?? this.id,
        name: name ?? this.name,
        colorHex: colorHex ?? this.colorHex,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
      );
  ScanFolder copyWithCompanion(ScanFoldersCompanion data) {
    return ScanFolder(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanFolder(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, colorHex, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanFolder &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorHex == this.colorHex &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class ScanFoldersCompanion extends UpdateCompanion<ScanFolder> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> colorHex;
  final Value<int> sortOrder;
  final Value<int> createdAt;
  const ScanFoldersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ScanFoldersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required int createdAt,
  })  : name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<ScanFolder> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? colorHex,
    Expression<int>? sortOrder,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorHex != null) 'color_hex': colorHex,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ScanFoldersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? colorHex,
      Value<int>? sortOrder,
      Value<int>? createdAt}) {
    return ScanFoldersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanFoldersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) => AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ScanDocumentsTable scanDocuments = $ScanDocumentsTable(this);
  late final $ScanPagesTable scanPages = $ScanPagesTable(this);
  late final $ScanFoldersTable scanFolders = $ScanFoldersTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [scanDocuments, scanPages, scanFolders, appSettings];
}

typedef $$ScanDocumentsTableCreateCompanionBuilder = ScanDocumentsCompanion
    Function({
  Value<int> id,
  required String title,
  Value<int?> folderId,
  Value<int> pageCount,
  Value<String> ocrStatus,
  required int createdAt,
  required int updatedAt,
});
typedef $$ScanDocumentsTableUpdateCompanionBuilder = ScanDocumentsCompanion
    Function({
  Value<int> id,
  Value<String> title,
  Value<int?> folderId,
  Value<int> pageCount,
  Value<String> ocrStatus,
  Value<int> createdAt,
  Value<int> updatedAt,
});

class $$ScanDocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $ScanDocumentsTable> {
  $$ScanDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get folderId => $composableBuilder(
      column: $table.folderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageCount => $composableBuilder(
      column: $table.pageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ocrStatus => $composableBuilder(
      column: $table.ocrStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ScanDocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanDocumentsTable> {
  $$ScanDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get folderId => $composableBuilder(
      column: $table.folderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageCount => $composableBuilder(
      column: $table.pageCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ocrStatus => $composableBuilder(
      column: $table.ocrStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ScanDocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanDocumentsTable> {
  $$ScanDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<String> get ocrStatus =>
      $composableBuilder(column: $table.ocrStatus, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ScanDocumentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScanDocumentsTable,
    ScanDocument,
    $$ScanDocumentsTableFilterComposer,
    $$ScanDocumentsTableOrderingComposer,
    $$ScanDocumentsTableAnnotationComposer,
    $$ScanDocumentsTableCreateCompanionBuilder,
    $$ScanDocumentsTableUpdateCompanionBuilder,
    (
      ScanDocument,
      BaseReferences<_$AppDatabase, $ScanDocumentsTable, ScanDocument>
    ),
    ScanDocument,
    PrefetchHooks Function()> {
  $$ScanDocumentsTableTableManager(_$AppDatabase db, $ScanDocumentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<int?> folderId = const Value.absent(),
            Value<int> pageCount = const Value.absent(),
            Value<String> ocrStatus = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
          }) =>
              ScanDocumentsCompanion(
            id: id,
            title: title,
            folderId: folderId,
            pageCount: pageCount,
            ocrStatus: ocrStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<int?> folderId = const Value.absent(),
            Value<int> pageCount = const Value.absent(),
            Value<String> ocrStatus = const Value.absent(),
            required int createdAt,
            required int updatedAt,
          }) =>
              ScanDocumentsCompanion.insert(
            id: id,
            title: title,
            folderId: folderId,
            pageCount: pageCount,
            ocrStatus: ocrStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ScanDocumentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScanDocumentsTable,
    ScanDocument,
    $$ScanDocumentsTableFilterComposer,
    $$ScanDocumentsTableOrderingComposer,
    $$ScanDocumentsTableAnnotationComposer,
    $$ScanDocumentsTableCreateCompanionBuilder,
    $$ScanDocumentsTableUpdateCompanionBuilder,
    (
      ScanDocument,
      BaseReferences<_$AppDatabase, $ScanDocumentsTable, ScanDocument>
    ),
    ScanDocument,
    PrefetchHooks Function()>;
typedef $$ScanPagesTableCreateCompanionBuilder = ScanPagesCompanion Function({
  Value<int> id,
  required int documentId,
  required int sortOrder,
  required String originalImagePath,
  Value<String?> processedImagePath,
  Value<String?> thumbnailPath,
  Value<String> filterType,
  Value<String?> cornerPointsJson,
  Value<int> rotation,
  Value<String> recognizedText,
  Value<String> textBlocksJson,
  required int createdAt,
});
typedef $$ScanPagesTableUpdateCompanionBuilder = ScanPagesCompanion Function({
  Value<int> id,
  Value<int> documentId,
  Value<int> sortOrder,
  Value<String> originalImagePath,
  Value<String?> processedImagePath,
  Value<String?> thumbnailPath,
  Value<String> filterType,
  Value<String?> cornerPointsJson,
  Value<int> rotation,
  Value<String> recognizedText,
  Value<String> textBlocksJson,
  Value<int> createdAt,
});

class $$ScanPagesTableFilterComposer
    extends Composer<_$AppDatabase, $ScanPagesTable> {
  $$ScanPagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get documentId => $composableBuilder(
      column: $table.documentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalImagePath => $composableBuilder(
      column: $table.originalImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get processedImagePath => $composableBuilder(
      column: $table.processedImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filterType => $composableBuilder(
      column: $table.filterType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cornerPointsJson => $composableBuilder(
      column: $table.cornerPointsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rotation => $composableBuilder(
      column: $table.rotation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recognizedText => $composableBuilder(
      column: $table.recognizedText,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textBlocksJson => $composableBuilder(
      column: $table.textBlocksJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ScanPagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanPagesTable> {
  $$ScanPagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get documentId => $composableBuilder(
      column: $table.documentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalImagePath => $composableBuilder(
      column: $table.originalImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get processedImagePath => $composableBuilder(
      column: $table.processedImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filterType => $composableBuilder(
      column: $table.filterType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cornerPointsJson => $composableBuilder(
      column: $table.cornerPointsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rotation => $composableBuilder(
      column: $table.rotation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recognizedText => $composableBuilder(
      column: $table.recognizedText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textBlocksJson => $composableBuilder(
      column: $table.textBlocksJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ScanPagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanPagesTable> {
  $$ScanPagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get documentId => $composableBuilder(
      column: $table.documentId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get originalImagePath => $composableBuilder(
      column: $table.originalImagePath, builder: (column) => column);

  GeneratedColumn<String> get processedImagePath => $composableBuilder(
      column: $table.processedImagePath, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => column);

  GeneratedColumn<String> get filterType => $composableBuilder(
      column: $table.filterType, builder: (column) => column);

  GeneratedColumn<String> get cornerPointsJson => $composableBuilder(
      column: $table.cornerPointsJson, builder: (column) => column);

  GeneratedColumn<int> get rotation =>
      $composableBuilder(column: $table.rotation, builder: (column) => column);

  GeneratedColumn<String> get recognizedText => $composableBuilder(
      column: $table.recognizedText, builder: (column) => column);

  GeneratedColumn<String> get textBlocksJson => $composableBuilder(
      column: $table.textBlocksJson, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ScanPagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScanPagesTable,
    ScanPage,
    $$ScanPagesTableFilterComposer,
    $$ScanPagesTableOrderingComposer,
    $$ScanPagesTableAnnotationComposer,
    $$ScanPagesTableCreateCompanionBuilder,
    $$ScanPagesTableUpdateCompanionBuilder,
    (ScanPage, BaseReferences<_$AppDatabase, $ScanPagesTable, ScanPage>),
    ScanPage,
    PrefetchHooks Function()> {
  $$ScanPagesTableTableManager(_$AppDatabase db, $ScanPagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanPagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanPagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanPagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> documentId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String> originalImagePath = const Value.absent(),
            Value<String?> processedImagePath = const Value.absent(),
            Value<String?> thumbnailPath = const Value.absent(),
            Value<String> filterType = const Value.absent(),
            Value<String?> cornerPointsJson = const Value.absent(),
            Value<int> rotation = const Value.absent(),
            Value<String> recognizedText = const Value.absent(),
            Value<String> textBlocksJson = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              ScanPagesCompanion(
            id: id,
            documentId: documentId,
            sortOrder: sortOrder,
            originalImagePath: originalImagePath,
            processedImagePath: processedImagePath,
            thumbnailPath: thumbnailPath,
            filterType: filterType,
            cornerPointsJson: cornerPointsJson,
            rotation: rotation,
            recognizedText: recognizedText,
            textBlocksJson: textBlocksJson,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int documentId,
            required int sortOrder,
            required String originalImagePath,
            Value<String?> processedImagePath = const Value.absent(),
            Value<String?> thumbnailPath = const Value.absent(),
            Value<String> filterType = const Value.absent(),
            Value<String?> cornerPointsJson = const Value.absent(),
            Value<int> rotation = const Value.absent(),
            Value<String> recognizedText = const Value.absent(),
            Value<String> textBlocksJson = const Value.absent(),
            required int createdAt,
          }) =>
              ScanPagesCompanion.insert(
            id: id,
            documentId: documentId,
            sortOrder: sortOrder,
            originalImagePath: originalImagePath,
            processedImagePath: processedImagePath,
            thumbnailPath: thumbnailPath,
            filterType: filterType,
            cornerPointsJson: cornerPointsJson,
            rotation: rotation,
            recognizedText: recognizedText,
            textBlocksJson: textBlocksJson,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ScanPagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScanPagesTable,
    ScanPage,
    $$ScanPagesTableFilterComposer,
    $$ScanPagesTableOrderingComposer,
    $$ScanPagesTableAnnotationComposer,
    $$ScanPagesTableCreateCompanionBuilder,
    $$ScanPagesTableUpdateCompanionBuilder,
    (ScanPage, BaseReferences<_$AppDatabase, $ScanPagesTable, ScanPage>),
    ScanPage,
    PrefetchHooks Function()>;
typedef $$ScanFoldersTableCreateCompanionBuilder = ScanFoldersCompanion
    Function({
  Value<int> id,
  required String name,
  Value<String> colorHex,
  Value<int> sortOrder,
  required int createdAt,
});
typedef $$ScanFoldersTableUpdateCompanionBuilder = ScanFoldersCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> colorHex,
  Value<int> sortOrder,
  Value<int> createdAt,
});

class $$ScanFoldersTableFilterComposer
    extends Composer<_$AppDatabase, $ScanFoldersTable> {
  $$ScanFoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ScanFoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanFoldersTable> {
  $$ScanFoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ScanFoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanFoldersTable> {
  $$ScanFoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ScanFoldersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScanFoldersTable,
    ScanFolder,
    $$ScanFoldersTableFilterComposer,
    $$ScanFoldersTableOrderingComposer,
    $$ScanFoldersTableAnnotationComposer,
    $$ScanFoldersTableCreateCompanionBuilder,
    $$ScanFoldersTableUpdateCompanionBuilder,
    (ScanFolder, BaseReferences<_$AppDatabase, $ScanFoldersTable, ScanFolder>),
    ScanFolder,
    PrefetchHooks Function()> {
  $$ScanFoldersTableTableManager(_$AppDatabase db, $ScanFoldersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanFoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> colorHex = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              ScanFoldersCompanion(
            id: id,
            name: name,
            colorHex: colorHex,
            sortOrder: sortOrder,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> colorHex = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required int createdAt,
          }) =>
              ScanFoldersCompanion.insert(
            id: id,
            name: name,
            colorHex: colorHex,
            sortOrder: sortOrder,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ScanFoldersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScanFoldersTable,
    ScanFolder,
    $$ScanFoldersTableFilterComposer,
    $$ScanFoldersTableOrderingComposer,
    $$ScanFoldersTableAnnotationComposer,
    $$ScanFoldersTableCreateCompanionBuilder,
    $$ScanFoldersTableUpdateCompanionBuilder,
    (ScanFolder, BaseReferences<_$AppDatabase, $ScanFoldersTable, ScanFolder>),
    ScanFolder,
    PrefetchHooks Function()>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ScanDocumentsTableTableManager get scanDocuments =>
      $$ScanDocumentsTableTableManager(_db, _db.scanDocuments);
  $$ScanPagesTableTableManager get scanPages =>
      $$ScanPagesTableTableManager(_db, _db.scanPages);
  $$ScanFoldersTableTableManager get scanFolders =>
      $$ScanFoldersTableTableManager(_db, _db.scanFolders);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
