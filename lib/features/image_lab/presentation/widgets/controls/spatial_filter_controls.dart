import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../domain/filter_defaults.dart';
import '../../../domain/image_filter_type.dart';
import '../lab_card.dart';
import '../feature_chip_wrap.dart';

class SpatialFilterControls extends StatelessWidget {
  final Set<String> selectedFilters;
  final Function(String) onFilterToggled;
  final double blurRadius;
  final SmoothingType smoothingType;
  final ValueChanged<double> onBlurRadiusChanged;
  final Function(SmoothingType) onSmoothingTypeChanged;
  final VoidCallback? onProcessingEnd;

  const SpatialFilterControls({
    super.key,
    required this.selectedFilters,
    required this.onFilterToggled,
    required this.blurRadius,
    required this.smoothingType,
    required this.onBlurRadiusChanged,
    required this.onSmoothingTypeChanged,
    this.onProcessingEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LabCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          FeatureChipWrap(
            selectedFilters: selectedFilters,
            onFilterToggled: onFilterToggled,
            options: const [
              FeatureOption('Blur', Icons.blur_on),
            ],
          ),
          if (selectedFilters.contains('Blur')) ...[
            const Divider(height: 32),
            _buildSlider(
              label: 'Smoothing Strength',
              value: blurRadius,
              min: FilterDefaults.blurRadiusMin,
              max: FilterDefaults.blurRadiusMax,
              divisions: 8,
              onChanged: onBlurRadiusChanged,
              onChangeEnd: (_) => onProcessingEnd?.call(),
              activeColor: AppColors.blurSlider,
              displayValue: blurRadius.toInt().toString(),
              note: 'Convolution passes.',
            ),
            const SizedBox(height: 16),
            _buildTypeSelector<SmoothingType>(
              label: 'Algorithm',
              value: smoothingType,
              options: {
                SmoothingType.averaging: 'Mean',
                SmoothingType.weightedAverage: 'Weighted',
                SmoothingType.median: 'Median',
              },
              onChanged: onSmoothingTypeChanged,
            ),
          ] else ...[
            const SizedBox(height: 8),
            const Text(
              'Select Blur to enable kernel-based smoothing.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeSelector<T>({
    required String label,
    required T value,
    required Map<T, String> options,
    required Function(T) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<T>(
            segments: options.entries.map((e) => ButtonSegment<T>(value: e.key, label: Text(e.value, style: const TextStyle(fontSize: 10)))).toList(),
            selected: {value},
            onSelectionChanged: (Set<T> selection) => onChanged(selection.first),
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              selectedBackgroundColor: AppColors.primary.withOpacity(0.1),
              selectedForegroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
            ),
            showSelectedIcon: false,
          ),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
    ValueChanged<double>? onChangeEnd,
    required Color activeColor,
    required String displayValue,
    required String note,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                Text(note, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
              ],
            ),
            Text(displayValue, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: activeColor)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            activeTrackColor: activeColor,
            thumbColor: activeColor,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ),
      ],
    );
  }
}
