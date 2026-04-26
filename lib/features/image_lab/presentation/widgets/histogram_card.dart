import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'lab_card.dart';

class HistogramCard extends StatefulWidget {
  const HistogramCard({super.key});

  @override
  State<HistogramCard> createState() => _HistogramCardState();
}

class _HistogramCardState extends State<HistogramCard> {
  String selectedChannel = 'R';

  @override
  Widget build(BuildContext context) {
    return LabCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pixel Intensity Distribution',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Histogram preview',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildChannelButton('R', AppColors.histogramR),
                  const SizedBox(width: 4),
                  _buildChannelButton('G', AppColors.histogramG),
                  const SizedBox(width: 4),
                  _buildChannelButton('B', AppColors.histogramB),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildChartPlaceholder(),
          const SizedBox(height: 20),
          _buildInternalStats(),
        ],
      ),
    );
  }

  Widget _buildChannelButton(String label, Color color) {
    final bool isSelected = selectedChannel == label;
    return GestureDetector(
      onTap: () => setState(() => selectedChannel = label),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    final Color channelColor = selectedChannel == 'R'
        ? AppColors.histogramR
        : selectedChannel == 'G'
            ? AppColors.histogramG
            : AppColors.histogramB;

    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Grid lines
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              4,
              (index) => Divider(
                color: AppColors.divider.withOpacity(0.3),
                height: 1,
                thickness: 1,
              ),
            ),
          ),
          // Bars
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                24,
                (index) {
                  final heightFactor = 0.2 + (Random().nextDouble() * 0.8);
                  return Container(
                    width: 8,
                    height: 140 * heightFactor,
                    decoration: BoxDecoration(
                      color: channelColor.withOpacity(0.8),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(2),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInternalStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceAlt),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMiniStat('Mean', '--'),
          _buildMiniStat('Std Dev', '--'),
          _buildMiniStat('Entropy', '--'),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
