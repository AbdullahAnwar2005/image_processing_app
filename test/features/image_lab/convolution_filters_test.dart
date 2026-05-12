import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_processing_app/features/image_lab/data/image_algorithms.dart';
import 'package:image_processing_app/features/image_lab/domain/image_filter_type.dart';

void main() {
  group('Convolution & Smoothing Tests', () {
    test('Averaging 3x3 Blur center pixel calculation', () {
      final image = img.Image(width: 3, height: 3);
      // All black except center white
      for (final p in image) p.setRgb(0, 0, 0);
      image.setPixelRgb(1, 1, 255, 255, 255);

      final result = ImageAlgorithms.applyBlur(image, 1.0, SmoothingType.averaging);
      
      // Center expected: 255 / 9 = 28.33 -> 28
      expect(result.getPixel(1, 1).r, 28);
    });

    test('Gaussian 3x3 Blur center pixel calculation', () {
      final image = img.Image(width: 3, height: 3);
      for (final p in image) p.setRgb(0, 0, 0);
      image.setPixelRgb(1, 1, 255, 255, 255);

      final result = ImageAlgorithms.applyBlur(image, 1.0, SmoothingType.gaussian);
      
      // Kernel center weight is 4. Total weight 16.
      // Expected: 255 * 4 / 16 = 63.75 -> 64
      expect(result.getPixel(1, 1).r, 64);
    });

    test('Median Filter removes salt-and-pepper noise', () {
      final image = img.Image(width: 3, height: 3);
      // Fill with 10s (noise base)
      for (final p in image) p.setRgb(10, 10, 10);
      // Add a single "white" salt pixel at center
      image.setPixelRgb(1, 1, 255, 255, 255);

      final result = ImageAlgorithms.applyBlur(image, 1.0, SmoothingType.median);
      
      // Median of nine 10s and one 255 is 10.
      expect(result.getPixel(1, 1).r, 10);
    });

    test('Min Filter picks lowest neighbor', () {
      final image = img.Image(width: 3, height: 3);
      for (final p in image) p.setRgb(255, 255, 255);
      image.setPixelRgb(0, 0, 10, 10, 10);

      final result = ImageAlgorithms.applyBlur(image, 1.0, SmoothingType.min);
      expect(result.getPixel(1, 1).r, 10);
    });

    test('Max Filter picks highest neighbor', () {
      final image = img.Image(width: 3, height: 3);
      for (final p in image) p.setRgb(0, 0, 0);
      image.setPixelRgb(0, 0, 200, 200, 200);

      final result = ImageAlgorithms.applyBlur(image, 1.0, SmoothingType.max);
      expect(result.getPixel(1, 1).r, 200);
    });
  });
}
