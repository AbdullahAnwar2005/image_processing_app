import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../domain/histogram_channel.dart';
import '../domain/histogram_data.dart';

class HistogramAnalyzer {
  /// Analyzes image bytes and returns histogram data for R, G, and B channels.
  static Future<Map<HistogramChannel, HistogramData>> analyze(Uint8List imageBytes) async {
    final img.Image? decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      throw Exception('Could not decode image for histogram analysis.');
    }

    final int totalPixels = decodedImage.width * decodedImage.height;
    if (totalPixels == 0) {
      return {
        HistogramChannel.red: HistogramData.empty(),
        HistogramChannel.green: HistogramData.empty(),
        HistogramChannel.blue: HistogramData.empty(),
      };
    }

    final List<int> redBins = List<int>.filled(256, 0);
    final List<int> greenBins = List<int>.filled(256, 0);
    final List<int> blueBins = List<int>.filled(256, 0);

    for (final pixel in decodedImage) {
      redBins[pixel.r.toInt()]++;
      greenBins[pixel.g.toInt()]++;
      blueBins[pixel.b.toInt()]++;
    }

    return {
      HistogramChannel.red: _calculateStats(redBins, totalPixels),
      HistogramChannel.green: _calculateStats(greenBins, totalPixels),
      HistogramChannel.blue: _calculateStats(blueBins, totalPixels),
    };
  }

  static HistogramData _calculateStats(List<int> bins, int totalPixels) {
    double sum = 0;
    for (int i = 0; i < 256; i++) {
      sum += i * bins[i];
    }
    final double mean = sum / totalPixels;

    double varianceSum = 0;
    double entropy = 0;
    for (int i = 0; i < 256; i++) {
      final int count = bins[i];
      if (count > 0) {
        // Standard Deviation components
        varianceSum += math.pow(i - mean, 2) * count;

        // Entropy components
        final double p = count / totalPixels;
        entropy -= p * (math.log(p) / math.log(2));
      }
    }

    final double standardDeviation = math.sqrt(varianceSum / totalPixels);

    return HistogramData(
      bins: bins,
      mean: mean,
      standardDeviation: standardDeviation,
      entropy: entropy,
      totalPixels: totalPixels,
    );
  }
}
