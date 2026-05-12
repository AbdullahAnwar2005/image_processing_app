import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../domain/histogram_channel.dart';
import '../../domain/histogram_data.dart';
import 'lab_card.dart';

class HistogramCard extends StatelessWidget {
  final Map<HistogramChannel, HistogramData>? histogramByChannel;
  final HistogramChannel selectedChannel;
  final Function(HistogramChannel) onChannelChanged;
  final bool isLoading;
  final int binCount;
  final Function(int) onBinCountChanged;

  const HistogramCard({
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
    final HistogramData? currentData = histogramByChannel?[selectedChannel];

    return LabCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Intensity Histogram',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Frequency of pixel intensities (0-255)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildChannelSelector(),
          const SizedBox(height: 16),
          _buildBinSelector(),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: currentData == null || currentData.totalPixels == 0
                ? _buildEmptyState()
                : _buildChart(currentData),
          ),
          const SizedBox(height: 20),
          _buildEducationalNote(),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 16),
          _buildStats(currentData),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildChannelSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: HistogramChannel.values.map((channel) {
          final isSelected = channel == selectedChannel;
          Color channelColor;
          switch (channel) {
            case HistogramChannel.red:
              channelColor = Colors.red.shade400;
              break;
            case HistogramChannel.green:
              channelColor = Colors.green.shade400;
              break;
            case HistogramChannel.blue:
              channelColor = Colors.blue.shade400;
              break;
            case HistogramChannel.intensity:
              channelColor = Colors.grey.shade700;
              break;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onChannelChanged(channel),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? channelColor.withOpacity(0.1) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? channelColor : AppColors.divider,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  channel.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? channelColor : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBinSelector() {
    final List<int> bins = [16, 32, 64, 256];
    return Row(
      children: [
        const Text(
          'Bins:',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        ...bins.map((b) {
          final isSelected = b == binCount;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => onBinCountChanged(b),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  b.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEducationalNote() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course Notes:',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '• Histogram: Shows the frequency of each intensity level.\n'
            '• Binning: Groups intensity levels for display clarity.\n'
            '• Equalization: Spreads intensity values to improve contrast.',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        histogramByChannel == null ? 'Pick an image to view histogram data.' : 'No pixel data available.',
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildChart(HistogramData data) {
    final int groupSize = 256 ~/ binCount;
    final List<double> groupedValues = List.filled(binCount, 0);

    for (int i = 0; i < 256; i++) {
      groupedValues[(i ~/ groupSize).clamp(0, binCount - 1)] += data.bins[i].toDouble();
    }

    Color barColor;
    switch (selectedChannel) {
      case HistogramChannel.red:
        barColor = const Color(0xFFEF4444).withOpacity(0.8);
        break;
      case HistogramChannel.green:
        barColor = const Color(0xFF22C55E).withOpacity(0.8);
        break;
      case HistogramChannel.blue:
        barColor = const Color(0xFF3B82F6).withOpacity(0.8);
        break;
      case HistogramChannel.intensity:
        barColor = const Color(0xFF475569).withOpacity(0.8);
        break;
    }

    final double maxVal = groupedValues.reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal == 0 ? 1 : maxVal * 1.1,
        barTouchData: BarTouchData(enabled: false),
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(binCount, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: groupedValues[i],
                color: barColor,
                width: binCount == 256 ? 1 : (binCount == 64 ? 3 : 6),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(1)),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStats(HistogramData? data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem('Mean', data?.mean.toStringAsFixed(1) ?? '0.0'),
        _buildStatItem('Std Dev', data?.standardDeviation.toStringAsFixed(1) ?? '0.0'),
        _buildStatItem('Entropy', data?.entropy.toStringAsFixed(2) ?? '0.00'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
