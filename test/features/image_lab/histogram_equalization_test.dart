import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_processing_app/features/image_lab/data/image_algorithms.dart';

void main() {
  group('Histogram & Equalization Tests', () {
    test('buildGrayscaleHistogram256 counts correctly', () {
      final image = img.Image(width: 2, height: 2);
      image.setPixelRgb(0, 0, 0, 0, 0);
      image.setPixelRgb(1, 0, 0, 0, 0);
      image.setPixelRgb(0, 1, 255, 255, 255);
      image.setPixelRgb(1, 1, 255, 255, 255);

      final hist = ImageAlgorithms.buildGrayscaleHistogram256(image);
      
      expect(hist[0], 2);
      expect(hist[255], 2);
      expect(hist[128], 0);
    });

    test('Histogram Equalization handles uniform image without crash', () {
      final image = img.Image(width: 3, height: 3);
      for (final p in image) p.setRgb(100, 100, 100);

      // Should not throw division by zero
      final result = ImageAlgorithms.applyHistogramEqualization(image);
      
      expect(result.width, 3);
      expect(result.getPixel(1, 1).r, 100);
    });

    test('CDF calculation is cumulative', () {
      final hist = List<int>.filled(256, 0);
      hist[10] = 5;
      hist[20] = 10;
      
      final cdf = ImageAlgorithms.buildCdf(hist);
      
      expect(cdf[10], 5);
      expect(cdf[20], 15);
      expect(cdf[255], 15);
    });
  });
}
