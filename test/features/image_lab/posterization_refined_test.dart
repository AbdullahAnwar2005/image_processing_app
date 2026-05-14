import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_processing_app/features/image_lab/data/image_algorithms.dart';

void main() {
  group('Posterization Refinement Tests', () {
    test('Test 1 — levels = 2: All output values are binary {0, 255}', () {
      final image = img.Image(width: 6, height: 1);
      final inputs = [0, 64, 127, 128, 200, 255];
      for (int i = 0; i < inputs.length; i++) {
        image.setPixelRgb(i, 0, inputs[i], inputs[i], inputs[i]);
      }

      ImageAlgorithms.applyPosterization(image, 2);

      for (int i = 0; i < inputs.length; i++) {
        final p = image.getPixel(i, 0);
        expect([0, 255].contains(p.r.toInt()), isTrue, reason: 'Value ${inputs[i]} mapped to ${p.r}');
        expect([0, 255].contains(p.g.toInt()), isTrue);
        expect([0, 255].contains(p.b.toInt()), isTrue);
      }
    });

    test('Test 2 — levels = 4: Outputs strictly in {0, 85, 170, 255}', () {
      final image = img.Image(width: 7, height: 1);
      final inputs = [0, 40, 85, 120, 170, 220, 255];
      for (int i = 0; i < inputs.length; i++) {
        image.setPixelRgb(i, 0, inputs[i], inputs[i], inputs[i]);
      }

      ImageAlgorithms.applyPosterization(image, 4);

      final allowed = {0, 85, 170, 255};
      for (int i = 0; i < inputs.length; i++) {
        final p = image.getPixel(i, 0);
        expect(allowed.contains(p.r.toInt()), isTrue, reason: 'Value ${inputs[i]} mapped to ${p.r}');
      }
    });

    test('Test 3 — exact mapping examples for levels = 4', () {
      final image = img.Image(width: 4, height: 1);
      final inputs = [0, 85, 170, 255];
      for (int i = 0; i < inputs.length; i++) {
        image.setPixelRgb(i, 0, inputs[i], inputs[i], inputs[i]);
      }

      ImageAlgorithms.applyPosterization(image, 4);

      expect(image.getPixel(0, 0).r, 0);
      expect(image.getPixel(1, 0).r, 85);
      expect(image.getPixel(2, 0).r, 170);
      expect(image.getPixel(3, 0).r, 255);
    });

    test('Test 4 — RGB independence with levels = 4', () {
      final image = img.Image(width: 1, height: 1);
      image.setPixelRgb(0, 0, 40, 120, 220);

      ImageAlgorithms.applyPosterization(image, 4);

      final p = image.getPixel(0, 0);
      // 40 -> 0
      // 120 -> 85 (120/255 * 3 = 1.41 -> 1. 1*255/3 = 85)
      // 220 -> 255 (220/255 * 3 = 2.58 -> 3. 3*255/3 = 255)
      expect(p.r, 0);
      expect(p.g, 85);
      expect(p.b, 255);
    });

    test('Test 5 — invalid levels safety: levels = 1 behaves as levels = 2', () {
      final image = img.Image(width: 2, height: 1);
      image.setPixelRgb(0, 0, 10, 10, 10);
      image.setPixelRgb(1, 0, 240, 240, 240);

      ImageAlgorithms.applyPosterization(image, 1);

      expect(image.getPixel(0, 0).r, 0);
      expect(image.getPixel(1, 0).r, 255);
    });
  });
}
