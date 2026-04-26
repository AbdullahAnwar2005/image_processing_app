import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageProcessor {
  /// Applies a grayscale filter to the provided image bytes.
  static Future<Uint8List> applyGrayscale(Uint8List originalBytes) async {
    // Decode the image from bytes
    final img.Image? decodedImage = img.decodeImage(originalBytes);
    
    if (decodedImage == null) {
      throw Exception('Could not decode image. Ensure the file is a valid JPG or PNG.');
    }

    // Apply grayscale filter
    final img.Image grayscaleImage = img.grayscale(decodedImage);

    // Encode the image back to JPG bytes
    final List<int> encodedBytes = img.encodeJpg(grayscaleImage, quality: 95);

    return Uint8List.fromList(encodedBytes);
  }
}
