import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'lab_card.dart';
import 'feature_chip_wrap.dart';

class FilterControlsCard extends StatelessWidget {
  final Set<String> selectedFilters;
  final Function(String) onFilterToggled;
  final double brightness;
  final double contrast;
  final double blurRadius;
  final ValueChanged<double> onBrightnessChanged;
  final ValueChanged<double> onContrastChanged;
  final ValueChanged<double> onBlurRadiusChanged;
  final ValueChanged<double>? onBrightnessChangeEnd;
  final ValueChanged<double>? onContrastChangeEnd;
  final ValueChanged<double>? onBlurRadiusChangeEnd;

  const FilterControlsCard({
    super.key,
    required this.selectedFilters,
    required this.onFilterToggled,
    required this.brightness,
    required this.contrast,
    required this.blurRadius,
    required this.onBrightnessChanged,
    required this.onContrastChanged,
    required this.onBlurRadiusChanged,
    this.onBrightnessChangeEnd,
    this.onContrastChangeEnd,
    this.onBlurRadiusChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LabCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.grayscaleBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Filter Controls',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FeatureChipWrap(
            selectedFilters: selectedFilters,
            onFilterToggled: onFilterToggled,
          ),
          const SizedBox(height: 24),
          _buildSlider(
            label: 'Brightness',
            value: brightness,
            min: -100,
            max: 100,
            onChanged: onBrightnessChanged,
            onChangeEnd: onBrightnessChangeEnd,
            activeColor: AppColors.brightnessSlider,
            displayValue: brightness.toInt().toString(),
          ),
          const SizedBox(height: 16),
          _buildSlider(
            label: 'Contrast',
            value: contrast,
            min: 0,
            max: 2,
            onChanged: onContrastChanged,
            onChangeEnd: onContrastChangeEnd,
            activeColor: AppColors.contrastSlider,
            displayValue: contrast.toStringAsFixed(1),
          ),
          const SizedBox(height: 16),
          _buildSlider(
            label: 'Blur Radius',
            value: blurRadius,
            min: 0,
            max: 10,
            onChanged: onBlurRadiusChanged,
            onChangeEnd: onBlurRadiusChangeEnd,
            activeColor: AppColors.blurSlider,
            displayValue: blurRadius.toInt().toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    ValueChanged<double>? onChangeEnd,
    required Color activeColor,
    required String displayValue,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              displayValue,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: activeColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: activeColor,
            inactiveTrackColor: AppColors.divider,
            thumbColor: activeColor,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ),
      ],
    );
  }
}
