import 'package:flutter/material.dart';
import 'package:image_processing_app/features/image_lab/domain/histogram_channel.dart';
import 'package:image_processing_app/features/image_lab/domain/histogram_data.dart';
import '../histogram_card.dart';

class HistogramAnalysisPanel extends StatelessWidget {
  final Map<HistogramChannel, HistogramData>? histogramByChannel;
  final HistogramChannel selectedChannel;
  final Function(HistogramChannel) onChannelChanged;
  final bool isLoading;
  final int binCount;
  final Function(int) onBinCountChanged;

  const HistogramAnalysisPanel({
    super.key,
    required this.histogramByChannel,
    required this.selectedChannel,
    required this.onChannelChanged,
    required this.isLoading,
    required this.binCount,
    required this.onBinCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return HistogramCard(
      histogramByChannel: histogramByChannel,
      selectedChannel: selectedChannel,
      onChannelChanged: onChannelChanged,
      isLoading: isLoading,
      binCount: binCount,
      onBinCountChanged: onBinCountChanged,
    );
  }
}
