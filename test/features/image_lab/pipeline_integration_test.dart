import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_processing_app/features/image_lab/data/image_processor.dart';
import 'package:image_processing_app/features/image_lab/data/histogram_analyzer.dart';
import 'package:image_processing_app/features/image_lab/domain/image_filter_type.dart';
import 'package:image_processing_app/features/image_lab/domain/geometry_state.dart';
import 'package:image_processing_app/features/image_lab/domain/histogram_channel.dart';

void main() {
  group('Pipeline Integration Tests (Phase 8.6)', () {
    test('Color Pipeline: negative -> sepia -> brightness/contrast', () async {
      final image = img.Image(width: 2, height: 2);
      final originalBytes = Uint8List.fromList(img.encodeJpg(image));

      final resultBytes = await ImageProcessor.processImage(
        originalBytes: originalBytes,
        grayscale: false,
        negative: true,
        sepia: true,
        posterizationLevels: 0,
        redFactor: 1.0,
        greenFactor: 1.0,
        blueFactor: 1.0,
        brightness: 60,
        contrast: 1.2,
        blurRadius: 0,
        edgeDetection: false,
        edgeType: EdgeDetectorType.sobel,
        smoothingType: SmoothingType.averaging,
        threshold: 128,
        useThreshold: false,
        equalization: false,
        geometry: const GeometryState(),
      );

      expect(resultBytes.length, greaterThan(0));
      expect(resultBytes, isNot(originalBytes));
    });

    test('Geometry + Filter: rotateRight -> flipH -> grayscale', () async {
      final image = img.Image(width: 2, height: 3);
      image.setPixelRgb(0, 0, 255, 0, 0); // Red pixel
      final originalBytes = Uint8List.fromList(img.encodeJpg(image));

      final resultBytes = await ImageProcessor.processImage(
        originalBytes: originalBytes,
        grayscale: true,
        negative: false,
        sepia: false,
        posterizationLevels: 0,
        redFactor: 1.0,
        greenFactor: 1.0,
        blueFactor: 1.0,
        brightness: 50,
        contrast: 1.0,
        blurRadius: 0,
        edgeDetection: false,
        edgeType: EdgeDetectorType.sobel,
        smoothingType: SmoothingType.averaging,
        threshold: 128,
        useThreshold: false,
        equalization: false,
        geometry: const GeometryState(rotationQuarterTurns: 1, flipHorizontal: true),
      );

      final resultImg = img.decodeImage(resultBytes)!;
      expect(resultImg.width, 3);
      expect(resultImg.height, 2);
      
      // Verify grayscale: R should equal G should equal B
      final p = resultImg.getPixel(0, 0);
      expect(p.r, p.g);
      expect(p.g, p.b);
    });

    test('Edge + Threshold: Sobel -> Threshold produces binary output', () async {
      final image = img.Image(width: 10, height: 10);
      // Create an edge
      for(int x=0; x<5; x++) for(int y=0; y<10; y++) image.setPixelRgb(x, y, 0, 0, 0);
      for(int x=5; x<10; x++) for(int y=0; y<10; y++) image.setPixelRgb(x, y, 255, 255, 255);
      
      final originalBytes = Uint8List.fromList(img.encodeJpg(image));

      final resultBytes = await ImageProcessor.processImage(
        originalBytes: originalBytes,
        grayscale: false,
        negative: false,
        sepia: false,
        posterizationLevels: 0,
        redFactor: 1.0,
        greenFactor: 1.0,
        blueFactor: 1.0,
        brightness: 50,
        contrast: 1.0,
        blurRadius: 0,
        edgeDetection: true,
        edgeType: EdgeDetectorType.sobel,
        smoothingType: SmoothingType.averaging,
        threshold: 50,
        useThreshold: true,
        equalization: false,
        geometry: const GeometryState(),
      );

      final resultImg = img.decodeImage(resultBytes)!;
      for (final p in resultImg) {
        expect([0, 255].contains(p.r.toInt()), isTrue);
      }
    });

    test('Histogram Analysis reflects processed image state', () async {
      final image = img.Image(width: 2, height: 2);
      for(final p in image) p.setRgb(255, 255, 255); // All white
      final originalBytes = Uint8List.fromList(img.encodeJpg(image));

      // 1. Process with Negative (White -> Black)
      final processedBytes = await ImageProcessor.processImage(
        originalBytes: originalBytes,
        grayscale: false,
        negative: true,
        sepia: false,
        posterizationLevels: 0,
        redFactor: 1.0,
        greenFactor: 1.0,
        blueFactor: 1.0,
        brightness: 50,
        contrast: 1.0,
        blurRadius: 0,
        edgeDetection: false,
        edgeType: EdgeDetectorType.sobel,
        smoothingType: SmoothingType.averaging,
        threshold: 128,
        useThreshold: false,
        equalization: false,
        geometry: const GeometryState(),
      );

      // 2. Analyze histogram
      final stats = await HistogramAnalyzer.analyze(processedBytes);
      final intensity = stats[HistogramChannel.intensity]!;
      
      // Expected: All 4 pixels at bin 0 (Black)
      expect(intensity.bins[0], 4);
      expect(intensity.bins[255], 0);
    });
  });
}
