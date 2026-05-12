import 'dart:isolate';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../domain/image_filter_type.dart';
import '../domain/geometry_state.dart';
import 'image_algorithms.dart';

/// Result object for the processing pipeline including metadata
class ImageProcessResult {
  final Uint8List bytes;
  final int width;
  final int height;

  ImageProcessResult({
    required this.bytes,
    required this.width,
    required this.height,
  });
}

class ImageProcessor {
  static const int maxProcessingDimension = 1600;

  /// Combined processing pipeline for Phase 10: Product Corrections
  static Future<ImageProcessResult> processImage({
    required Uint8List originalBytes,
    required bool grayscale,
    required bool negative,
    required bool sepia,
    required bool rgbAdjustment, // New: Independent toggle
    required int posterizationLevels,
    required double redFactor,
    required double greenFactor,
    required double blueFactor,
    required double brightness,
    required double contrast,
    required double blurRadius,
    required bool edgeDetection,
    required EdgeDetectorType edgeType,
    required SmoothingType smoothingType,
    required double threshold,
    required bool useThreshold,
    required bool equalization,
    required GeometryState geometry,
  }) async {
    return Isolate.run(() {
      final img.Image decodedImage = _decodeImageOrThrow(originalBytes);
      
      // 1. Initial Optimization (Resize if too large to protect memory/performance)
      img.Image processedImage = _resizeIfNeeded(decodedImage);

      // 2. Geometric Transformations (Stateful)
      if (!geometry.isIdentity) {
        processedImage = ImageAlgorithms.applyGeometryState(processedImage, geometry);
      }

      // 3. Fundamental Intensity/Color Transform
      if (grayscale) {
        processedImage = ImageAlgorithms.applyManualGrayscale(processedImage);
      }
      if (equalization) {
        processedImage = ImageAlgorithms.applyHistogramEqualization(processedImage);
      }

      // 4. Point Operations (Color Manipulation)
      if (negative) {
        processedImage = ImageAlgorithms.applyNegative(processedImage);
      }
      if (sepia) {
        processedImage = ImageAlgorithms.applySepia(processedImage);
      }
      if (posterizationLevels > 0) {
        processedImage = ImageAlgorithms.applyPosterization(processedImage, posterizationLevels);
      }
      
      // RGB Adjustment is now independent from posterization
      if (rgbAdjustment && (redFactor != 1.0 || greenFactor != 1.0 || blueFactor != 1.0)) {
        processedImage = ImageAlgorithms.applyRgbAdjustment(processedImage, redFactor, greenFactor, blueFactor);
      }
      
      // Standard Brightness/Contrast
      processedImage = ImageAlgorithms.applyBrightnessContrast(
        processedImage,
        brightness,
        contrast,
      );

      // 5. Spatial Filtering (Smoothing / Noise Removal)
      processedImage = ImageAlgorithms.applyBlur(processedImage, blurRadius, smoothingType);

      // 6. Final Segmenting or Feature Extraction
      if (edgeDetection) {
        if (!grayscale && !equalization && !sepia && !negative) {
          processedImage = ImageAlgorithms.applyManualGrayscale(processedImage);
        }
        processedImage = ImageAlgorithms.applyEdgeDetection(processedImage, edgeType);
      } else if (useThreshold) {
        processedImage = ImageAlgorithms.applyThreshold(processedImage, threshold);
      }

      final encoded = _encodeJpg(processedImage);
      return ImageProcessResult(
        bytes: encoded,
        width: processedImage.width,
        height: processedImage.height,
      );
    });
  }

  static img.Image _decodeImageOrThrow(Uint8List bytes) {
    if (bytes.isEmpty) throw Exception('Image data is empty.');
    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Unsupported or corrupted image format.');
    }
    return decoded;
  }

  static img.Image _resizeIfNeeded(img.Image src) {
    if (src.width <= maxProcessingDimension && src.height <= maxProcessingDimension) {
      return img.copyResize(src, width: src.width); 
    }
    int targetWidth;
    int targetHeight;
    if (src.width >= src.height) {
      targetWidth = maxProcessingDimension;
      targetHeight = (src.height * (maxProcessingDimension / src.width)).toInt();
    } else {
      targetHeight = maxProcessingDimension;
      targetWidth = (src.width * (maxProcessingDimension / src.height)).toInt();
    }
    return img.copyResize(src, width: targetWidth, height: targetHeight);
  }

  static Uint8List _encodeJpg(img.Image image) {
    final List<int> encoded = img.encodeJpg(image, quality: 95);
    return Uint8List.fromList(encoded);
  }

  /// Utility to get dimensions without full processing
  static Future<(int, int)> getDimensions(Uint8List bytes) async {
    return Isolate.run(() {
      final img.Image? decoded = img.decodeImage(bytes);
      if (decoded == null) return (0, 0);
      return (decoded.width, decoded.height);
    });
  }
}
