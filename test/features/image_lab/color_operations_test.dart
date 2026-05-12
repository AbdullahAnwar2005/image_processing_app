import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_processing_app/features/image_lab/data/image_algorithms.dart';

void main() {
  group('Color Operations Tests (Phase 8.6 Validation)', () {
    test('Negative: Correct inversion formula (255 - channel)', () {
      final image = img.Image(width: 1, height: 1);
      image.setPixelRgb(0, 0, 10, 20, 30);
      ImageAlgorithms.applyNegative(image);
      final p = image.getPixel(0, 0);
      expect(p.r, 245); // 255 - 10
      expect(p.g, 235); // 255 - 20
      expect(p.b, 225); // 255 - 30
    });

    test('Negative Identity: Double negative returns original values', () {
      final image = img.Image(width: 2, height: 2);
      // Fill with varied pixels
      image.setPixelRgb(0, 0, 10, 50, 100);
      image.setPixelRgb(1, 1, 200, 220, 250);
      
      ImageAlgorithms.applyNegative(image);
      ImageAlgorithms.applyNegative(image);
      
      expect(image.getPixel(0, 0).r, 10);
      expect(image.getPixel(0, 0).g, 50);
      expect(image.getPixel(0, 0).b, 100);
      expect(image.getPixel(1, 1).r, 200);
    });

    test('Sepia: Correct matrix transformation with rounding', () {
      final image = img.Image(width: 1, height: 1);
      image.setPixelRgb(0, 0, 100, 150, 200);
      ImageAlgorithms.applySepia(image);
      final p = image.getPixel(0, 0);
      
      // Calculations:
      // newR = 100*0.393 + 150*0.769 + 200*0.189 = 39.3 + 115.35 + 37.8 = 192.45 -> 192
      // newG = 100*0.349 + 150*0.686 + 200*0.168 = 34.9 + 102.9 + 33.6 = 171.4 -> 171
      // newB = 100*0.272 + 150*0.534 + 200*0.131 = 27.2 + 80.1 + 26.2 = 133.5 -> 134
      
      expect(p.r, closeTo(192, 1));
      expect(p.g, closeTo(171, 1));
      expect(p.b, closeTo(134, 1));
    });

    test('Sepia Clamping: White pixel remains clamped to 255', () {
      final image = img.Image(width: 1, height: 1);
      image.setPixelRgb(0, 0, 255, 255, 255);
      ImageAlgorithms.applySepia(image);
      final p = image.getPixel(0, 0);
      expect(p.r, 255);
      expect(p.g, 255);
      expect(p.b, 239); // 255 * (0.272 + 0.534 + 0.131) = 239
    });

    test('RGB Channel Manipulation: Correct factor application', () {
      final image = img.Image(width: 1, height: 1);
      image.setPixelRgb(0, 0, 100, 100, 100);
      ImageAlgorithms.applyRgbAdjustment(image, 1.5, 1.0, 0.5);
      final p = image.getPixel(0, 0);
      expect(p.r, 150);
      expect(p.g, 100);
      expect(p.b, 50);
    });

    test('RGB Channel Clamping: Prevents overflow (>255)', () {
      final image = img.Image(width: 1, height: 1);
      image.setPixelRgb(0, 0, 200, 200, 200);
      ImageAlgorithms.applyRgbAdjustment(image, 2.0, 1.0, 1.0);
      final p = image.getPixel(0, 0);
      expect(p.r, 255); // 400 clamped to 255
    });

    test('Posterization (Levels=2): All outputs are binary {0, 255}', () {
      final image = img.Image(width: 6, height: 1);
      image.setPixelRgb(0, 0, 0, 0, 0);
      image.setPixelRgb(1, 0, 64, 64, 64);
      image.setPixelRgb(2, 0, 127, 127, 127);
      image.setPixelRgb(3, 0, 128, 128, 128);
      image.setPixelRgb(4, 0, 200, 200, 200);
      image.setPixelRgb(5, 0, 255, 255, 255);
      
      ImageAlgorithms.applyPosterization(image, 2);
      
      for (final p in image) {
        expect([0, 255].contains(p.r.toInt()), isTrue);
        expect([0, 255].contains(p.g.toInt()), isTrue);
        expect([0, 255].contains(p.b.toInt()), isTrue);
      }
    });

    test('Posterization (Levels=4): Outputs strictly in {0, 85, 170, 255}', () {
      final image = img.Image(width: 4, height: 4);
      // Fill with many values
      for(int i=0; i<16; i++) {
        image.setPixelRgb(i%4, i~/4, i*16, i*16, i*16);
      }
      
      ImageAlgorithms.applyPosterization(image, 4);
      
      final allowed = {0, 85, 170, 255};
      for (final p in image) {
        expect(allowed.contains(p.r.toInt()), isTrue);
      }
    });
  });
}
