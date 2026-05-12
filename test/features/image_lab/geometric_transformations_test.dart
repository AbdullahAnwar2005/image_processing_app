import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_processing_app/features/image_lab/data/image_algorithms.dart';
import 'package:image_processing_app/features/image_lab/domain/geometry_state.dart';

void main() {
  group('Geometric Transformations Tests', () {
    test('Flip Horizontal: Swaps pixels on X axis', () {
      final image = img.Image(width: 2, height: 1);
      image.setPixelRgb(0, 0, 255, 0, 0); // A (Red)
      image.setPixelRgb(1, 0, 0, 255, 0); // B (Green)
      
      final result = ImageAlgorithms.flipHorizontal(image);
      expect(result.getPixel(0, 0).r, 0);   // B
      expect(result.getPixel(1, 0).r, 255); // A
    });

    test('Flip Horizontal Twice: Returns to original orientation', () {
      final image = img.Image(width: 2, height: 1);
      image.setPixelRgb(0, 0, 255, 0, 0);
      
      final res1 = ImageAlgorithms.flipHorizontal(image);
      final res2 = ImageAlgorithms.flipHorizontal(res1);
      
      expect(res2.getPixel(0, 0).r, 255);
    });

    test('Flip Vertical: Swaps pixels on Y axis', () {
      final image = img.Image(width: 1, height: 2);
      image.setPixelRgb(0, 0, 255, 0, 0); // Top (Red)
      image.setPixelRgb(0, 1, 0, 255, 0); // Bottom (Green)
      
      final result = ImageAlgorithms.flipVertical(image);
      expect(result.getPixel(0, 0).r, 0);   // Top is now Green
      expect(result.getPixel(0, 1).r, 255); // Bottom is now Red
    });

    test('Rotate Clockwise 90: Correct coordinate mapping for 2x3 image', () {
      // Row 0: R(255,0,0) G(0,255,0)
      // Row 1: B(0,0,255) W(255,255,255)
      // Row 2: Y(255,255,0) C(0,255,255)
      final image = img.Image(width: 2, height: 3);
      image.setPixelRgb(0, 0, 255, 0, 0); // A
      image.setPixelRgb(1, 0, 0, 255, 0); // B
      image.setPixelRgb(0, 1, 0, 0, 255); // C
      image.setPixelRgb(1, 1, 255, 255, 255); // D
      image.setPixelRgb(0, 2, 255, 255, 0); // E
      image.setPixelRgb(1, 2, 0, 255, 255); // F

      final result = ImageAlgorithms.rotate90CW(image);
      
      expect(result.width, 3);
      expect(result.height, 2);
      
      // Expected Row 0: E C A
      expect(result.getPixel(0, 0).r, 255); // E
      expect(result.getPixel(0, 0).g, 255); 
      expect(result.getPixel(1, 0).b, 255); // C
      expect(result.getPixel(2, 0).r, 255); // A
      
      // Expected Row 1: F D B
      expect(result.getPixel(0, 1).g, 255); // F
      expect(result.getPixel(0, 1).b, 255);
      expect(result.getPixel(1, 1).r, 255); // D (White)
      expect(result.getPixel(2, 1).g, 255); // B
    });

    test('Rotate Counter-Clockwise 90: Correct coordinate mapping', () {
      final image = img.Image(width: 2, height: 2);
      image.setPixelRgb(0, 0, 255, 0, 0); // Top-Left
      image.setPixelRgb(1, 0, 0, 255, 0); // Top-Right
      
      final result = ImageAlgorithms.rotate90CCW(image);
      expect(result.getPixel(0, 1).r, 255); // Original Top-Left moves to Bottom-Left
    });

    test('Rotate 180: Double rotation logic', () {
      final image = img.Image(width: 2, height: 2);
      image.setPixelRgb(0, 0, 255, 0, 0); // Top-Left
      
      final state = const GeometryState(rotationQuarterTurns: 2);
      final result = ImageAlgorithms.applyGeometryState(image, state);
      
      expect(result.getPixel(1, 1).r, 255); // Top-Left moves to Bottom-Right
    });

    test('Rotate 360: Identity rotation', () {
      final image = img.Image(width: 2, height: 2);
      image.setPixelRgb(0, 0, 255, 0, 0);
      
      final state = const GeometryState(rotationQuarterTurns: 4); // 4 turns = 0 turns
      final result = ImageAlgorithms.applyGeometryState(image, state);
      
      expect(result.getPixel(0, 0).r, 255);
    });

    test('Scale 2x Nearest Neighbor: Doubles dimensions and repeats pixels', () {
      final image = img.Image(width: 1, height: 1);
      image.setPixelRgb(0, 0, 255, 0, 0);
      
      final result = ImageAlgorithms.scaleNearestNeighbor(image, 2.0);
      expect(result.width, 2);
      expect(result.height, 2);
      expect(result.getPixel(0, 0).r, 255);
      expect(result.getPixel(1, 1).r, 255);
    });

    test('Scale Down 0.5x: Correct sampling', () {
      final image = img.Image(width: 4, height: 4);
      // Formula used: sx = (x / factor).toInt()
      // x=0 -> sx=0
      // x=1 -> sx=2
      image.setPixelRgb(0, 0, 255, 0, 0);
      image.setPixelRgb(2, 0, 0, 255, 0);
      
      final result = ImageAlgorithms.scaleNearestNeighbor(image, 0.5);
      expect(result.width, 2);
      expect(result.getPixel(0, 0).r, 255);
      expect(result.getPixel(1, 0).g, 255);
    });
  });
}
