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

  const HistogramCard({
    super.key,
    required this.histogramByChannel,
    required this.selectedChannel,
    required this.onChannelChanged,
    required this.isLoading,
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
                      'Pixel Intensity Distribution',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Histogram based on processed image',
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
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: currentData == null || currentData.totalPixels == 0
                ? _buildEmptyState()
                : _buildChart(currentData),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 16),
          _buildStats(currentData),
          const SizedBox(height: 4), // Extra bottom spacing to prevent clipping
        ],
      ),
    );
  }

  Widget _buildChannelSelector() {
    return Row(
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
    // Group 256 bins into 32 bars (group size 8)
    const int barCount = 32;
    const int groupSize = 8;
    final List<double> groupedValues = List.filled(barCount, 0);

    for (int i = 0; i < 256; i++) {
      groupedValues[i ~/ groupSize] += data.bins[i].toDouble();
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
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: groupedValues.reduce((a, b) => a > b ? a : b) * 1.1,
        barTouchData: BarTouchData(enabled: false),
        titlesData: const FlTitlesData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => const FlLine(
            color: Color(0xFFF1F5F9),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(barCount, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: groupedValues[i],
                color: barColor,
                width: 4,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
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
