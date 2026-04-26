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
        // Sobel works best on grayscale images
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

  /// Resizes the image if it exceeds the maximum dimension while maintaining aspect ratio.
  /// This prevents memory issues and UI jank during processing of high-resolution images.
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

    // Mapping: UI Brightness 0..100 (50 neutral) -> Pixel offset -255..255
    // Previous mapping (0.5 range) was too subtle to be visible.
    // We now use a full intensity range (-128 to 128 is usually enough for dramatic change)
    // but we'll go up to 255 for extreme ranges.
    final double offset = (brightness - 50) * 4.0; // +/- 200 intensity

    return img.adjustColor(
      src,
      brightness: offset,
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
  /// This implementation has been hardened to ensure visibility and compatibility with image 4.x.
  static img.Image _applySobelEdgeDetection(img.Image src) {
    final int width = src.width;
    final int height = src.height;

    // Sobel needs at least a 3x3 grid
    if (width < 3 || height < 3) {
      return img.Image(width: width, height: height)..clear(img.ColorRgb8(0, 0, 0));
    }

    // Create destination image with the same dimensions
    final img.Image dest = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // Set borders to black as kernels cannot be applied there
        if (x == 0 || x == width - 1 || y == 0 || y == height - 1) {
          dest.setPixelRgb(x, y, 0, 0, 0);
          continue;
        }

        // Get intensities of the 3x3 neighborhood
        // Using luminance ensures we get a consistent 0-255 scale regardless of channel format
        final p00 = src.getPixel(x - 1, y - 1).luminance;
        final p10 = src.getPixel(x, y - 1).luminance;
        final p20 = src.getPixel(x + 1, y - 1).luminance;

        final p01 = src.getPixel(x - 1, y).luminance;
        final p21 = src.getPixel(x + 1, y).luminance;

        final p02 = src.getPixel(x - 1, y + 1).luminance;
        final p12 = src.getPixel(x, y + 1).luminance;
        final p22 = src.getPixel(x + 1, y + 1).luminance;

        // Sobel kernels Gx/Gy:
        // These detect horizontal and vertical changes in intensity (gradients).
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

        // Calculate edge magnitude using Pythagorean theorem
        // We add a slight gain (1.5x) to make edges more visible on high-res screens
        final double magnitude = math.sqrt(gx * gx + gy * gy) * 1.5;
        final int finalVal = magnitude.clamp(0, 255).toInt();

        // Set the pixel in the destination image
        dest.setPixelRgb(x, y, finalVal, finalVal, finalVal);
      }
    }

    return dest;
  }
}
