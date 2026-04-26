enum HistogramChannel {
  red,
  green,
  blue,
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
    }
  }
}
