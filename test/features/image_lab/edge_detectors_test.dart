import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_processing_app/features/image_lab/data/image_algorithms.dart';
import 'package:image_processing_app/features/image_lab/domain/image_filter_type.dart';

void main() {
  group('Edge Detector Tests', () {
    test('Sobel detects vertical edge', () {
      final image = img.Image(width: 5, height: 5);
      // Half black, half white
      for (int y = 0; y < 5; y++) {
        for (int x = 0; x < 5; x++) {
          final val = x >= 2 ? 255 : 0;
          image.setPixelRgb(x, y, val, val, val);
        }
      }

      final result = ImageAlgorithms.applyEdgeDetection(image, EdgeDetectorType.sobel);
      
      // Center pixel (2,2) is exactly on the transition. Magnitude should be high.
      expect(result.getPixel(2, 2).r, greaterThan(128));
      // Top-left pixel (0,0) is in flat black. Magnitude should be 0.
      expect(result.getPixel(0, 0).r, 0);
    });

    test('Laplacian on flat image returns zero', () {
      final image = img.Image(width: 3, height: 3);
      for (final p in image) p.setRgb(100, 100, 100);

      final result = ImageAlgorithms.applyEdgeDetection(image, EdgeDetectorType.laplacian);
      
      for (final p in result) {
        expect(p.r, 0);
      }
    });

    test('Roberts cross detected diagonal transition', () {
      final image = img.Image(width: 3, height: 3);
      // Diagonal step
      image.setPixelRgb(0, 0, 0, 0, 0);
      image.setPixelRgb(1, 1, 255, 255, 255);
      
      final result = ImageAlgorithms.applyEdgeDetection(image, EdgeDetectorType.roberts);
      expect(result.getPixel(0, 0).r, greaterThan(0));
    });
  });
}
