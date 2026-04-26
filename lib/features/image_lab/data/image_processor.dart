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
    );
  }

  /// Combined processing pipeline for grayscale, brightness, and contrast.
  static Future<Uint8List> processImage({
    required Uint8List originalBytes,
    required bool grayscale,
    required double brightness,
    required double contrast,
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
    // Mapping: 
    // UI Brightness -100..100 -> adjustColor brightness -1.0..1.0
    // UI Contrast 0..2 -> adjustColor contrast 0..2 (Neutral 1.0)
    if (brightness != 0 || contrast != 1.0) {
      processedImage = img.adjustColor(
        processedImage,
        brightness: brightness / 100.0,
        contrast: contrast,
      );
    }

    // Encode the image back to JPG bytes
    final List<int> encodedBytes = img.encodeJpg(processedImage, quality: 95);

    return Uint8List.fromList(encodedBytes);
  }
}
