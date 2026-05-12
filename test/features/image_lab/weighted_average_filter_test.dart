import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_processing_app/features/image_lab/data/image_algorithms.dart';
import 'package:image_processing_app/features/image_lab/domain/image_filter_type.dart';

void main() {
  group('Weighted Average Filter Tests', () {
    test('Impulse Response: Center weight 4/16 produces value 64 for 255 input', () {
      final image = img.Image(width: 3, height: 3);
      for(final p in image) p.setRgb(0, 0, 0);
      image.setPixelRgb(1, 1, 255, 255, 255);
      
      final result = ImageAlgorithms.applyBlur(image, 1.0, SmoothingType.weightedAverage);
      
      // Kernel: [1 2 1; 2 4 2; 1 2 1] / 16
      // Center: round(255 * 4 / 16) = round(63.75) = 64
      expect(result.getPixel(1, 1).r, 64);
      // Neighbors: round(255 * 2 / 16) = 32
      expect(result.getPixel(1, 0).r, 32);
      // Corners: round(255 * 1 / 16) = 16
      expect(result.getPixel(0, 0).r, 16);
    });

    test('Flat Image Preservation: Uniform regions remain unchanged', () {
      final image = img.Image(width: 5, height: 5);
      for(final p in image) p.setRgb(100, 100, 100);
      
      final result = ImageAlgorithms.applyBlur(image, 2.0, SmoothingType.weightedAverage);
      
      for(final p in result) {
        expect(p.r, 100);
      }
    });

    test('Comparison: Weighted Average center (64) vs Box Average center (28)', () {
      final image = img.Image(width: 3, height: 3);
      for(final p in image) p.setRgb(0, 0, 0);
      image.setPixelRgb(1, 1, 255, 255, 255);
      
      final weightedResult = ImageAlgorithms.applyBlur(image, 1.0, SmoothingType.weightedAverage);
      final boxResult = ImageAlgorithms.applyBlur(image, 1.0, SmoothingType.averaging);
      
      // Box kernel: [1 1 1; 1 1 1; 1 1 1] / 9
      // Box center: round(255 / 9) = 28
      
      expect(weightedResult.getPixel(1, 1).r, 64);
      expect(boxResult.getPixel(1, 1).r, 28);
      expect(weightedResult.getPixel(1, 1).r, greaterThan(boxResult.getPixel(1, 1).r));
    });
  });
}
