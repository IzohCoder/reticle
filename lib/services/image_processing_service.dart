import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Handles all image processing: filters, thumbnails, resizing.
/// Heavy operations run in isolates to keep the UI thread free.
class ImageProcessingService {
  static const int thumbnailWidth = 200;
  static const int previewWidth = 800;

  /// Base directory for all Reticle files.
  static Future<String> get _baseDir async {
    final appDir = await getApplicationDocumentsDirectory();
    return p.join(appDir.path, 'reticle');
  }

  /// Ensures all storage directories exist.
  static Future<void> ensureDirectories(int docId) async {
    final base = await _baseDir;
    await Directory(p.join(base, 'originals', '$docId')).create(recursive: true);
    await Directory(p.join(base, 'processed', '$docId')).create(recursive: true);
    await Directory(p.join(base, 'thumbs', '$docId')).create(recursive: true);
  }

  /// Copies a scanned image to app-private storage and returns the new path.
  static Future<String> saveOriginal(String sourcePath, int docId, int pageId) async {
    final base = await _baseDir;
    final destDir = p.join(base, 'originals', '$docId');
    await Directory(destDir).create(recursive: true);
    final dest = p.join(destDir, '$pageId.jpg');
    await File(sourcePath).copy(dest);
    return dest;
  }

  /// Generates a thumbnail for a page image. Runs in an isolate.
  static Future<String> generateThumbnail(String imagePath, int docId, int pageId) async {
    final base = await _baseDir;
    final thumbDir = p.join(base, 'thumbs', '$docId');
    await Directory(thumbDir).create(recursive: true);
    final thumbPath = p.join(thumbDir, '$pageId.jpg');

    await compute(_generateThumbnailIsolate, _ThumbParams(imagePath, thumbPath, thumbnailWidth));
    return thumbPath;
  }

  static void _generateThumbnailIsolate(_ThumbParams params) {
    final bytes = File(params.sourcePath).readAsBytesSync();
    final image = img.decodeImage(bytes);
    if (image == null) return;

    final resized = img.copyResize(image, width: params.width);
    File(params.destPath).writeAsBytesSync(img.encodeJpg(resized, quality: 75));
  }

  /// Applies a filter to an image. Returns the path of the processed image.
  static Future<String> applyFilter(
    String imagePath,
    String filterType,
    int docId,
    int pageId,
  ) async {
    if (filterType == 'original') return imagePath;

    final base = await _baseDir;
    final processedDir = p.join(base, 'processed', '$docId');
    await Directory(processedDir).create(recursive: true);
    final outputPath = p.join(processedDir, '${pageId}_$filterType.jpg');

    await compute(
      _applyFilterIsolate,
      _FilterParams(imagePath, outputPath, filterType),
    );
    return outputPath;
  }

  static void _applyFilterIsolate(_FilterParams params) {
    final bytes = File(params.sourcePath).readAsBytesSync();
    final image = img.decodeImage(bytes);
    if (image == null) return;

    img.Image result;
    switch (params.filterType) {
      case 'enhanced':
        result = _enhancedFilter(image);
        break;
      case 'bw':
        result = _bwFilter(image);
        break;
      case 'grayscale':
        result = img.grayscale(image);
        break;
      case 'blueprint':
        result = _blueprintFilter(image);
        break;
      default:
        result = image;
    }

    File(params.destPath).writeAsBytesSync(img.encodeJpg(result, quality: 90));
  }

  /// Enhanced: boost contrast and sharpen for cleaner text.
  static img.Image _enhancedFilter(img.Image src) {
    var result = img.adjustColor(src, contrast: 1.3, brightness: 1.05);
    result = img.luminanceThreshold(result, threshold: 0.55);
    // Re-apply from src with lighter touch for readability
    result = img.adjustColor(src, contrast: 1.4);
    return result;
  }

  /// Black & White: high-contrast binary threshold.
  static img.Image _bwFilter(img.Image src) {
    final gray = img.grayscale(src);
    return img.luminanceThreshold(gray, threshold: 0.5);
  }

  /// Blueprint: cyan-tinted technical drawing look.
  static img.Image _blueprintFilter(img.Image src) {
    final gray = img.grayscale(src);
    // Invert and tint with deep cyan
    final inverted = img.invert(gray);
    final result = img.Image(width: src.width, height: src.height);
    for (var y = 0; y < src.height; y++) {
      for (var x = 0; x < src.width; x++) {
        final pixel = inverted.getPixel(x, y);
        final lum = pixel.r.toInt();
        // Deep cyan background with bright lines
        final r = (lum * 0.05).round().clamp(0, 255);
        final g = (lum * 0.45).round().clamp(0, 255);
        final b = (lum * 0.65).round().clamp(0, 255);
        result.setPixelRgba(x, y, r, g, b, 255);
      }
    }
    return result;
  }

  /// Adjusts brightness and contrast of an image.
  static Future<String> adjustBrightnessContrast(
    String imagePath,
    double brightness,
    double contrast,
    int docId,
    int pageId,
  ) async {
    final base = await _baseDir;
    final processedDir = p.join(base, 'processed', '$docId');
    await Directory(processedDir).create(recursive: true);
    final outputPath = p.join(processedDir, '${pageId}_adjusted.jpg');

    await compute(
      _adjustIsolate,
      _AdjustParams(imagePath, outputPath, brightness, contrast),
    );
    return outputPath;
  }

  static void _adjustIsolate(_AdjustParams params) {
    final bytes = File(params.sourcePath).readAsBytesSync();
    final image = img.decodeImage(bytes);
    if (image == null) return;

    final result = img.adjustColor(
      image,
      brightness: params.brightness,
      contrast: params.contrast,
    );
    File(params.destPath).writeAsBytesSync(img.encodeJpg(result, quality: 90));
  }

  /// Rotates an image by 90-degree increments.
  static Future<String> rotateImage(
    String imagePath,
    int degrees,
    int docId,
    int pageId,
  ) async {
    if (degrees == 0) return imagePath;

    final base = await _baseDir;
    final processedDir = p.join(base, 'processed', '$docId');
    await Directory(processedDir).create(recursive: true);
    final outputPath = p.join(processedDir, '${pageId}_rot$degrees.jpg');

    await compute(
      _rotateIsolate,
      _RotateParams(imagePath, outputPath, degrees),
    );
    return outputPath;
  }

  static void _rotateIsolate(_RotateParams params) {
    final bytes = File(params.sourcePath).readAsBytesSync();
    final image = img.decodeImage(bytes);
    if (image == null) return;

    final rotated = img.copyRotate(image, angle: params.degrees.toDouble());
    File(params.destPath).writeAsBytesSync(img.encodeJpg(rotated, quality: 90));
  }

  /// Gets the display image for a page (processed if exists, else original).
  static String getDisplayPath(String? processedPath, String originalPath) {
    if (processedPath != null && File(processedPath).existsSync()) {
      return processedPath;
    }
    return originalPath;
  }

  /// Resizes an image for export with given quality level.
  static Future<Uint8List> resizeForExport(
    String imagePath,
    String quality,
  ) async {
    return compute(_resizeForExportIsolate, _ExportParams(imagePath, quality));
  }

  static Uint8List _resizeForExportIsolate(_ExportParams params) {
    final bytes = File(params.sourcePath).readAsBytesSync();
    final image = img.decodeImage(bytes);
    if (image == null) return Uint8List(0);

    int targetWidth;
    int jpgQuality;
    switch (params.quality) {
      case 'small':
        targetWidth = 1024;
        jpgQuality = 60;
        break;
      case 'high':
        targetWidth = 3000;
        jpgQuality = 95;
        break;
      default: // balanced
        targetWidth = 1800;
        jpgQuality = 80;
    }

    final resized = image.width > targetWidth
        ? img.copyResize(image, width: targetWidth)
        : image;
    return Uint8List.fromList(img.encodeJpg(resized, quality: jpgQuality));
  }

  /// Cleans up all files for a document.
  static Future<void> deleteDocumentFiles(int docId) async {
    final base = await _baseDir;
    for (final sub in ['originals', 'processed', 'thumbs']) {
      final dir = Directory(p.join(base, sub, '$docId'));
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    }
  }

  /// Cleans orphaned files not referenced by any document.
  static Future<void> cleanOrphans(Set<int> validDocIds) async {
    final base = await _baseDir;
    for (final sub in ['originals', 'processed', 'thumbs']) {
      final dir = Directory(p.join(base, sub));
      if (!await dir.exists()) continue;
      await for (final entity in dir.list()) {
        if (entity is Directory) {
          final docId = int.tryParse(p.basename(entity.path));
          if (docId != null && !validDocIds.contains(docId)) {
            await entity.delete(recursive: true);
          }
        }
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Isolate parameter classes (must be top-level for compute())
// ---------------------------------------------------------------------------

class _ThumbParams {
  final String sourcePath;
  final String destPath;
  final int width;
  _ThumbParams(this.sourcePath, this.destPath, this.width);
}

class _FilterParams {
  final String sourcePath;
  final String destPath;
  final String filterType;
  _FilterParams(this.sourcePath, this.destPath, this.filterType);
}

class _AdjustParams {
  final String sourcePath;
  final String destPath;
  final double brightness;
  final double contrast;
  _AdjustParams(this.sourcePath, this.destPath, this.brightness, this.contrast);
}

class _RotateParams {
  final String sourcePath;
  final String destPath;
  final int degrees;
  _RotateParams(this.sourcePath, this.destPath, this.degrees);
}

class _ExportParams {
  final String sourcePath;
  final String quality;
  _ExportParams(this.sourcePath, this.quality);
}
