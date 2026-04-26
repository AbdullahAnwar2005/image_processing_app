class HistogramData {
  final List<int> bins; // length 256
  final double mean;
  final double standardDeviation;
  final double entropy;
  final int totalPixels;

  const HistogramData({
    required this.bins,
    required this.mean,
    required this.standardDeviation,
    required this.entropy,
    required this.totalPixels,
  });

  factory HistogramData.empty() {
    return HistogramData(
      bins: List<int>.filled(256, 0),
      mean: 0,
      standardDeviation: 0,
      entropy: 0,
      totalPixels: 0,
    );
  }
}
