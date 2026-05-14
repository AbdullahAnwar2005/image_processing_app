import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_processing_app/features/image_lab/data/image_algorithms.dart';

void main() {
  group('Pixel Operations Tests', () {
    test('clampChannel handles out-of-bounds values', () {
      expect(ImageAlgorithms.clampChannel(-10), 0);
      expect(ImageAlgorithms.clampChannel(0), 0);
      expect(ImageAlgorithms.clampChannel(128), 128);
      expect(ImageAlgorithms.clampChannel(255), 255);
      expect(ImageAlgorithms.clampChannel(300), 255);
    });

    test('applyManualGrayscale (Luminance) matches expected value', () {
      // Create a 1x1 red image
      final image = img.Image(width: 1, height: 1);
      image.setPixelRgb(0, 0, 255, 0, 0);

      ImageAlgorithms.applyManualGrayscale(image);
      
      final pixel = image.getPixel(0, 0);
      // gray = round(0.299 * 255 + 0.587 * 0 + 0.114 * 0) = round(76.245) = 76
      expect(pixel.r, 76);
      expect(pixel.g, 76);
      expect(pixel.b, 76);
    });

    test('applyBrightness adds offset correctly', () {
      final image = img.Image(width: 1, height: 1);
      image.setPixelRgb(0, 0, 100, 120, 140);

      // brightness = 10 (default is 0), so offset = 10 * 2.0 = 20
      ImageAlgorithms.applyBrightnessContrast(image, 10, 1.0);
      
      final pixel = image.getPixel(0, 0);
      expect(pixel.r, 120);
      expect(pixel.g, 140);
      expect(pixel.b, 160);
    });

    test('applyContrast scales around 128 midpoint', () {
      final image = img.Image(width: 1, height: 1);
      image.setPixelRgb(0, 0, 138, 138, 138);

      // contrast factor = 2.0, brightness = 0 (neutral)
      ImageAlgorithms.applyBrightnessContrast(image, 0, 2.0);
      
      final pixel = image.getPixel(0, 0);
      // (138 - 128) * 2 + 128 = 10 * 2 + 128 = 148
      expect(pixel.r, 148);
    });

    test('applyThreshold produces binary output', () {
      final image = img.Image(width: 2, height: 1);
      image.setPixelRgb(0, 0, 127, 127, 127); // Intensity 127
      image.setPixelRgb(1, 0, 128, 128, 128); // Intensity 128

      ImageAlgorithms.applyThreshold(image, 128);
      
      expect(image.getPixel(0, 0).r, 0);
      expect(image.getPixel(1, 0).r, 255);
    });
  });
}
