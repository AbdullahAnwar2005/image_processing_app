import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_processing_app/features/image_lab/data/image_processor.dart';
import 'package:image_processing_app/features/image_lab/domain/geometry_state.dart';
import 'package:image_processing_app/features/image_lab/domain/image_filter_type.dart';
import 'package:image_processing_app/features/image_lab/domain/filter_defaults.dart';

void main() {
  group('Phase 10 Corrections Tests', () {
    test('RGB Adjustment is independent from Posterization', () async {
      final image = img.Image(width: 16, height: 16, numChannels: 3);
      for (int y = 0; y < 16; y++) {
        for (int x = 0; x < 16; x++) {
          image.setPixelRgb(x, y, 100, 100, 100);
        }
      }
      final bytes = Uint8List.fromList(img.encodePng(image));

      final result = await ImageProcessor.processImage(
        originalBytes: bytes,
        grayscale: false,
        negative: false,
        sepia: false,
        rgbAdjustment: true,
        posterizationLevels: 0,
        redFactor: 2.0,
        greenFactor: 1.0,
        blueFactor: 1.0,
        brightness: FilterDefaults.brightness, // Correct: 50
        contrast: FilterDefaults.contrast, // Correct: 1.0
        blurRadius: 0,
        edgeDetection: false,
        edgeType: EdgeDetectorType.sobel,
        smoothingType: SmoothingType.gaussian,
        threshold: 128,
        useThreshold: false,
        equalization: false,
        geometry: const GeometryState(),
      );

      final out = img.decodeImage(result.bytes)!;
      final p = out.getPixel(8, 8);
      
      expect(p.r, greaterThan(180)); 
      expect(p.g, closeTo(100, 10));
    });

    test('Posterization works while RGB Adjustment is disabled', () async {
      final image = img.Image(width: 16, height: 16, numChannels: 3);
      for (int y = 0; y < 16; y++) {
        for (int x = 0; x < 16; x++) {
          image.setPixelRgb(x, y, 150, 150, 150);
        }
      }
      final bytes = Uint8List.fromList(img.encodePng(image));

      final result = await ImageProcessor.processImage(
        originalBytes: bytes,
        grayscale: false,
        negative: false,
        sepia: false,
        rgbAdjustment: false,
        posterizationLevels: 2,
        redFactor: 2.0,
        greenFactor: 1.0,
        blueFactor: 1.0,
        brightness: FilterDefaults.brightness,
        contrast: FilterDefaults.contrast,
        blurRadius: 0,
        edgeDetection: false,
        edgeType: EdgeDetectorType.sobel,
        smoothingType: SmoothingType.gaussian,
        threshold: 128,
        useThreshold: false,
        equalization: false,
        geometry: const GeometryState(),
      );

      final out = img.decodeImage(result.bytes)!;
      final p = out.getPixel(8, 8);
      expect(p.r, greaterThan(200)); 
    });

    test('Processed dimensions update after rotation', () async {
      final rect = img.Image(width: 16, height: 32);
      final bytes = Uint8List.fromList(img.encodePng(rect));

      final result = await ImageProcessor.processImage(
        originalBytes: bytes,
        grayscale: false,
        negative: false,
        sepia: false,
        rgbAdjustment: false,
        posterizationLevels: 0,
        redFactor: 1.0,
        greenFactor: 1.0,
        blueFactor: 1.0,
        brightness: FilterDefaults.brightness,
        contrast: FilterDefaults.contrast,
        blurRadius: 0,
        edgeDetection: false,
        edgeType: EdgeDetectorType.sobel,
        smoothingType: SmoothingType.gaussian,
        threshold: 128,
        useThreshold: false,
        equalization: false,
        geometry: const GeometryState(rotationQuarterTurns: 1),
      );

      expect(result.width, 32);
      expect(result.height, 16);
    });
  });
}
