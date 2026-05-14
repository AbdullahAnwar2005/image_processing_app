import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../domain/histogram_channel.dart';
import '../../domain/histogram_data.dart';
import '../../domain/filter_defaults.dart';
import 'lab_card.dart';

class HistogramCard extends StatelessWidget {
  final Map<HistogramChannel, HistogramData>? histogramByChannel;
  final HistogramChannel selectedChannel;
  final Function(HistogramChannel) onChannelChanged;
  final bool isLoading;
  final int binCount;
  final Function(int) onBinCountChanged;
  final VoidCallback onResetHistogram;

  const HistogramCard({
    super.key,
    required this.histogramByChannel,
    required this.selectedChannel,
    required this.onChannelChanged,
    required this.isLoading,
    required this.binCount,
    required this.onBinCountChanged,
    required this.onResetHistogram,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Histogram Analysis',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'X: ${_getXAxisLabel()} · Y: pixel count',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: currentData == null || currentData.totalPixels == 0
                ? _buildEmptyState()
                : _buildChart(currentData),
          ),
          const SizedBox(height: 8),
          _buildGradientAxis(),
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

  String _getXAxisLabel() {
    switch (selectedChannel) {
      case HistogramChannel.intensity:
        return 'Intensity value (0–255)';
      case HistogramChannel.red:
        return 'Red channel value (0–255)';
      case HistogramChannel.green:
        return 'Green channel value (0–255)';
      case HistogramChannel.blue:
        return 'Blue channel value (0–255)';
    }
  }

  Widget _buildChannelSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: HistogramChannel.values.map((channel) {
          final isSelected = channel == selectedChannel;
          Color channelColor;
          Color textColor;
          Color bgColor;
          Color borderColor;

          switch (channel) {
            case HistogramChannel.red:
              channelColor = Colors.red.shade600;
              textColor = isSelected ? channelColor : AppColors.textSecondary;
              bgColor = isSelected ? channelColor.withOpacity(0.1) : Colors.transparent;
              borderColor = isSelected ? channelColor : AppColors.divider;
              break;
            case HistogramChannel.green:
              channelColor = Colors.green.shade600;
              textColor = isSelected ? channelColor : AppColors.textSecondary;
              bgColor = isSelected ? channelColor.withOpacity(0.1) : Colors.transparent;
              borderColor = isSelected ? channelColor : AppColors.divider;
              break;
            case HistogramChannel.blue:
              channelColor = Colors.blue.shade600;
              textColor = isSelected ? channelColor : AppColors.textSecondary;
              bgColor = isSelected ? channelColor.withOpacity(0.1) : Colors.transparent;
              borderColor = isSelected ? channelColor : AppColors.divider;
              break;
            case HistogramChannel.intensity:
              channelColor = Colors.grey.shade800;
              textColor = isSelected ? channelColor : AppColors.textSecondary;
              bgColor = isSelected ? Colors.grey.shade200 : Colors.transparent;
              borderColor = isSelected ? Colors.grey.shade400 : AppColors.divider;
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
                  color: bgColor,
                  border: Border.all(
                    color: borderColor,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  channel.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: textColor,
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
    final bool isModified = binCount != FilterDefaults.histogramBins || selectedChannel != HistogramChannel.intensity;
    final int valuesPerBin = 256 ~/ binCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Bins:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
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
                      borderRadius: BorderRadius.circular(6),
                      border: isSelected ? null : Border.all(color: AppColors.divider),
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
            const Spacer(),
            if (isModified)
              GestureDetector(
                onTap: onResetHistogram,
                child: const Text(
                  'Reset view',
                  style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w800),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '$binCount bins · $valuesPerBin value${valuesPerBin > 1 ? 's' : ''} per bar',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientAxis() {
    List<Color> gradientColors;
    switch (selectedChannel) {
      case HistogramChannel.red:
        gradientColors = [Colors.black, Colors.red];
        break;
      case HistogramChannel.green:
        gradientColors = [Colors.black, Colors.green];
        break;
      case HistogramChannel.blue:
        gradientColors = [Colors.black, Colors.blue];
        break;
      case HistogramChannel.intensity:
        gradientColors = [Colors.black, Colors.white];
        break;
    }

    return Column(
      children: [
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(colors: gradientColors),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            Text('64', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            Text('128', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            Text('192', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            Text('255', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildEducationalNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: AppColors.primary.withOpacity(0.8)),
              const SizedBox(width: 6),
              const Text(
                'Course Notes:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '• Histogram shows how often each channel or intensity value appears.\n'
            '• Binning groups ranges of values for easier reading.\n'
            '• Equalization spreads intensities to improve contrast.',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 32, color: AppColors.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 8),
          Text(
            histogramByChannel == null ? 'Import media to analyze histogram' : 'No pixel data available',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
        barColor = const Color(0xFFEF4444);
        break;
      case HistogramChannel.green:
        barColor = const Color(0xFF22C55E);
        break;
      case HistogramChannel.blue:
        barColor = const Color(0xFF3B82F6);
        break;
      case HistogramChannel.intensity:
        barColor = const Color(0xFF64748B);
        break;
    }

    final double maxVal = groupedValues.reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal == 0 ? 1 : maxVal * 1.05,
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
                color: barColor.withOpacity(0.85),
                width: binCount == 256 ? 0.8 : (binCount == 64 ? 2.5 : 5.0),
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
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
