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
    );
  }

  /// Combined processing pipeline for grayscale, brightness, contrast, and blur.
  static Future<Uint8List> processImage({
    required Uint8List originalBytes,
    required bool grayscale,
    required double brightness,
    required double contrast,
    required double blurRadius,
  }) async {
    // Decode the image from bytes
    final img.Image? decodedImage = img.decodeImage(originalBytes);
    
    if (decodedImage == null) {
      throw Exception('Could not decode image. Ensure the file is a valid JPG or PNG.');
    }

    img.Image processedImage = decodedImage;

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

    // Encode the image back to JPG bytes
    final List<int> encodedBytes = img.encodeJpg(processedImage, quality: 95);

    return Uint8List.fromList(encodedBytes);
  }
}
