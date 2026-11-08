import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/scanner_service.dart';
import '../../services/ocr_service.dart';
import '../../services/export_service.dart';
import 'database_provider.dart';

final scannerServiceProvider = Provider<ScannerService>((ref) {
  return ScannerService(ref.watch(databaseProvider));
});

final ocrServiceProvider = Provider<OcrService>((ref) {
  return OcrService(ref.watch(databaseProvider));
});

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(ref.watch(databaseProvider));
});
