enum HistogramChannel {
  red,
  green,
  blue,
  intensity,
}

extension HistogramChannelExtension on HistogramChannel {
  String get label {
    switch (this) {
      case HistogramChannel.red:
        return 'R';
      case HistogramChannel.green:
        return 'G';
      case HistogramChannel.blue:
        return 'B';
      case HistogramChannel.intensity:
        return 'Intensity';
    }
  }
}
