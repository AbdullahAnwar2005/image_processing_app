import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_processing_app/features/image_lab/data/image_processor.dart';
import 'package:image_processing_app/features/image_lab/domain/image_filter_type.dart';
import 'package:image_processing_app/features/image_lab/domain/geometry_state.dart';
import 'package:image/image.dart' as img;

void main() {
  test('Integration: ImageProcessor produces changed bytes on blur', () async {
    // 1. Create a 10x10 test image
    final image = img.Image(width: 10, height: 10);
    for (final p in image) p.setRgb(0, 0, 0);
    image.getPixel(5, 5).setRgb(255, 255, 255);
    final originalBytes = Uint8List.fromList(img.encodeJpg(image));

    // 2. Run through processor
    final result = await ImageProcessor.processImage(
      originalBytes: originalBytes,
      grayscale: false,
      negative: false,
      sepia: false,
      rgbAdjustment: false,
      posterizationLevels: 0,
      redFactor: 1.0,
      greenFactor: 1.0,
      blueFactor: 1.0,
      brightness: 50,
      contrast: 1.0,
      blurRadius: 3.0,
      edgeDetection: false,
      edgeType: EdgeDetectorType.sobel,
      smoothingType: SmoothingType.averaging,
      threshold: 128,
      useThreshold: false,
      equalization: false,
      geometry: const GeometryState(), // Identity geometry
    );

    // 3. Verify
    expect(result.bytes.length, greaterThan(0));
    expect(result.bytes, isNot(originalBytes));
  });
}
