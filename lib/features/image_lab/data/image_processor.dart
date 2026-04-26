import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageProcessor {
  /// Applies a grayscale filter to the provided image bytes.
  static Future<Uint8List> applyGrayscale(Uint8List originalBytes) async {
    return processImage(
      originalBytes: originalBytes,
      grayscale: true,
      brightness: 0,
      contrast: 1.0,
      blurRadius: 0,
      edgeDetection: false,
    );
  }

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
      // Decode the image from bytes
      final img.Image? decodedImage = img.decodeImage(originalBytes);
      
      if (decodedImage == null) {
        throw Exception('Could not decode image. Ensure the file is a valid JPG or PNG.');
      }

      img.Image processedImage = decodedImage;

      // 1. Check for Edge Detection override
      if (edgeDetection) {
        // Edge detection requires grayscale
        processedImage = img.grayscale(processedImage);
        processedImage = _applySobelEdgeDetection(processedImage);
      } else {
        // Standard Pipeline
        // 1. Apply grayscale if requested
        if (grayscale) {
          processedImage = img.grayscale(processedImage);
        }

        // 2. Apply brightness and contrast
        if (brightness != 0 || contrast != 1.0) {
          processedImage = img.adjustColor(
            processedImage,
            brightness: brightness / 100.0,
            contrast: contrast,
          );
        }

        // 3. Apply Gaussian blur if requested
        if (blurRadius > 0) {
          processedImage = img.gaussianBlur(processedImage, radius: blurRadius.toInt());
        }
      }

      // Encode the image back to JPG bytes
      final List<int> encodedBytes = img.encodeJpg(processedImage, quality: 95);

      return Uint8List.fromList(encodedBytes);
    });
  }

  /// Manual implementation of Sobel Edge Detection
  static img.Image _applySobelEdgeDetection(img.Image src) {
    final int width = src.width;
    final int height = src.height;
    final img.Image dest = img.Image(width: width, height: height);

    // Sobel Kernels
    // Gx:
    // -1  0  1
    // -2  0  2
    // -1  0  1
    //
    // Gy:
    // -1 -2 -1
    //  0  0  0
    //  1  2  1

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // Handle borders: set to black
        if (x == 0 || x == width - 1 || y == 0 || y == height - 1) {
          dest.setPixelRgb(x, y, 0, 0, 0);
          continue;
        }

        // Neighborhood
        // [x-1, y-1] [x, y-1] [x+1, y-1]
        // [x-1, y]   [x, y]   [x+1, y]
        // [x-1, y+1] [x, y+1] [x+1, y+1]

        final p00 = src.getPixel(x - 1, y - 1).r;
        final p10 = src.getPixel(x, y - 1).r;
        final p20 = src.getPixel(x + 1, y - 1).r;

        final p01 = src.getPixel(x - 1, y).r;
        // final p11 = src.getPixel(x, y).r; // Not needed for Sobel
        final p21 = src.getPixel(x + 1, y).r;

        final p02 = src.getPixel(x - 1, y + 1).r;
        final p12 = src.getPixel(x, y + 1).r;
        final p22 = src.getPixel(x + 1, y + 1).r;

        // Calculate Gx
        final double gx = (
          -1 * p00 + 0 * p10 + 1 * p20 +
          -2 * p01 +           2 * p21 +
          -1 * p02 + 0 * p12 + 1 * p22
        ).toDouble();

        // Calculate Gy
        final double gy = (
          -1 * p00 + -2 * p10 + -1 * p20 +
           0 * p01 +             0 * p21 +
           1 * p02 +  2 * p12 +  1 * p22
        ).toDouble();

        // Magnitude
        final double magnitude = math.sqrt(gx * gx + gy * gy);
        final int finalVal = magnitude.clamp(0, 255).toInt();

        dest.setPixelRgb(x, y, finalVal, finalVal, finalVal);
      }
    }

    return dest;
  }
}
