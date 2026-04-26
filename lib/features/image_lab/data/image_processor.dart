import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageProcessor {
  static const int maxProcessingDimension = 1600;

  /// Combined processing pipeline for grayscale, brightness, contrast, blur, and edge detection.
  static Future<Uint8List> processImage({
    required Uint8List originalBytes,
    required bool grayscale,
    required double brightness,
    required double contrast,
    required double blurRadius,
    required bool edgeDetection,
  }) async {
    return Isolate.run(() {
      final img.Image decodedImage = _decodeImageOrThrow(originalBytes);
      
      // 1. Resize if image is too large for efficient processing
      img.Image processedImage = _resizeIfNeeded(decodedImage);

      // 2. High-priority Edge Detection branch
      if (edgeDetection) {
        processedImage = img.grayscale(processedImage);
        processedImage = _applySobelEdgeDetection(processedImage);
      } else {
        // Standard non-destructive pipeline
        if (grayscale) {
          processedImage = img.grayscale(processedImage);
        }

        // Apply adjustments only if they are not neutral
        processedImage = _applyBrightnessContrastIfNeeded(
          processedImage,
          brightness,
          contrast,
        );

        processedImage = _applyBlurIfNeeded(processedImage, blurRadius);
      }

      return _encodeJpg(processedImage);
    });
  }

  static img.Image _decodeImageOrThrow(Uint8List bytes) {
    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Unsupported or corrupted image.');
    }
    return decoded;
  }

  static img.Image _resizeIfNeeded(img.Image src) {
    if (src.width <= maxProcessingDimension && src.height <= maxProcessingDimension) {
      return src;
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

  static img.Image _applyBrightnessContrastIfNeeded(
    img.Image src,
    double brightness,
    double contrast,
  ) {
    // Brightness neutral is 50, Contrast default 1.0
    if (brightness == 50 && contrast == 1.0) {
      return src;
    }

    // Mapping: UI Brightness 0..100 (50 neutral) -> adjustColor -0.5..0.5
    return img.adjustColor(
      src,
      brightness: (brightness - 50) / 100.0,
      contrast: contrast,
    );
  }

  static img.Image _applyBlurIfNeeded(img.Image src, double radius) {
    if (radius <= 0) {
      return src;
    }
    return img.gaussianBlur(src, radius: radius.toInt());
  }

  static Uint8List _encodeJpg(img.Image image) {
    final List<int> encoded = img.encodeJpg(image, quality: 95);
    return Uint8List.fromList(encoded);
  }

  /// Manual implementation of Sobel Edge Detection
  static img.Image _applySobelEdgeDetection(img.Image src) {
    final int width = src.width;
    final int height = src.height;

    // Sobel needs at least a 3x3 grid
    if (width < 3 || height < 3) {
      return img.Image(width: width, height: height)..clear(img.ColorRgb8(0, 0, 0));
    }

    final img.Image dest = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // Borders are set to black
        if (x == 0 || x == width - 1 || y == 0 || y == height - 1) {
          dest.setPixelRgb(x, y, 0, 0, 0);
          continue;
        }

        final p00 = src.getPixel(x - 1, y - 1).r;
        final p10 = src.getPixel(x, y - 1).r;
        final p20 = src.getPixel(x + 1, y - 1).r;

        final p01 = src.getPixel(x - 1, y).r;
        final p21 = src.getPixel(x + 1, y).r;

        final p02 = src.getPixel(x - 1, y + 1).r;
        final p12 = src.getPixel(x, y + 1).r;
        final p22 = src.getPixel(x + 1, y + 1).r;

        // Sobel kernels Gx/Gy
        final double gx = (
          -1 * p00 + 0 * p10 + 1 * p20 +
          -2 * p01 +           2 * p21 +
          -1 * p02 + 0 * p12 + 1 * p22
        ).toDouble();

        final double gy = (
          -1 * p00 + -2 * p10 + -1 * p20 +
           0 * p01 +             0 * p21 +
           1 * p02 +  2 * p12 +  1 * p22
        ).toDouble();

        final double magnitude = math.sqrt(gx * gx + gy * gy);
        final int finalVal = magnitude.clamp(0, 255).toInt();

        dest.setPixelRgb(x, y, finalVal, finalVal, finalVal);
      }
    }

    return dest;
  }
}
