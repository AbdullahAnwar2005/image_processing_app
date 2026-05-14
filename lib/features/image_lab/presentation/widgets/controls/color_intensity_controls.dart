import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../domain/filter_defaults.dart';
import '../lab_card.dart';
import '../feature_chip_wrap.dart';

class ColorIntensityControls extends StatelessWidget {
  final Set<String> selectedFilters;
  final Function(String) onFilterToggled;
  final double brightness;
  final double contrast;
  final int posterizationLevels;
  final double redFactor;
  final double greenFactor;
  final double blueFactor;
  
  final ValueChanged<double> onBrightnessChanged;
  final ValueChanged<double> onContrastChanged;
  final ValueChanged<int> onPosterizationChanged;
  final ValueChanged<double> onRedFactorChanged;
  final ValueChanged<double> onGreenFactorChanged;
  final ValueChanged<double> onBlueFactorChanged;

  final VoidCallback onResetBrightness;
  final VoidCallback onResetContrast;
  final VoidCallback onResetRGB;
  final VoidCallback onResetPosterization;

  final VoidCallback? onProcessingEnd;

  const ColorIntensityControls({
    super.key,
    required this.selectedFilters,
    required this.onFilterToggled,
    required this.brightness,
    required this.contrast,
    required this.posterizationLevels,
    required this.redFactor,
    required this.greenFactor,
    required this.blueFactor,
    required this.onBrightnessChanged,
    required this.onContrastChanged,
    required this.onPosterizationChanged,
    required this.onRedFactorChanged,
    required this.onGreenFactorChanged,
    required this.onBlueFactorChanged,
    required this.onResetBrightness,
    required this.onResetContrast,
    required this.onResetRGB,
    required this.onResetPosterization,
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
              FeatureOption('Grayscale', Icons.hdr_strong),
              FeatureOption('Negative', Icons.invert_colors),
              FeatureOption('Sepia', Icons.photo_filter),
              FeatureOption('Posterize', Icons.color_lens_rounded),
              FeatureOption('Equalization', Icons.equalizer),
              FeatureOption('RGB Adjustment', Icons.tune_rounded),
            ],
          ),
          const Divider(height: 32),
          _buildSlider(
            label: 'Brightness',
            value: brightness,
            defaultValue: FilterDefaults.brightness,
            min: FilterDefaults.brightnessMin,
            max: FilterDefaults.brightnessMax,
            divisions: 200,
            onChanged: onBrightnessChanged,
            onReset: onResetBrightness,
            onChangeEnd: (_) => onProcessingEnd?.call(),
            activeColor: AppColors.brightnessSlider,
            displayValue: brightness.toInt().toString(),
            note: 'Intensity offset.',
          ),
          const SizedBox(height: 12),
          _buildSlider(
            label: 'Contrast',
            value: contrast,
            defaultValue: FilterDefaults.contrast,
            min: FilterDefaults.contrastMin,
            max: FilterDefaults.contrastMax,
            divisions: 20,
            onChanged: onContrastChanged,
            onReset: onResetContrast,
            onChangeEnd: (_) => onProcessingEnd?.call(),
            activeColor: AppColors.contrastSlider,
            displayValue: contrast.toStringAsFixed(1),
            note: 'Intensity scaling.',
          ),
          
          if (selectedFilters.contains('Posterize')) ...[
            const SizedBox(height: 16),
            _buildSlider(
              label: 'Posterization',
              value: posterizationLevels.toDouble(),
              defaultValue: FilterDefaults.posterization,
              min: FilterDefaults.posterizationMin,
              max: FilterDefaults.posterizationMax,
              divisions: 16,
              onChanged: (v) => onPosterizationChanged(v.toInt()),
              onReset: onResetPosterization,
              onChangeEnd: (_) => onProcessingEnd?.call(),
              activeColor: Colors.teal,
              displayValue: posterizationLevels.toString(),
              note: 'Quantizes color levels.',
            ),
          ],
          
          if (selectedFilters.contains('RGB Adjustment')) ...[
             const SizedBox(height: 16),
             _buildRgbAdjusters(),
          ],
        ],
      ),
    );
  }

  Widget _buildRgbAdjusters() {
    final bool isModified = redFactor != FilterDefaults.rgbFactor || 
                           greenFactor != FilterDefaults.rgbFactor || 
                           blueFactor != FilterDefaults.rgbFactor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'CHANNEL BALANCING',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            ),
            if (isModified)
              TextButton(
                onPressed: onResetRGB,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Reset All', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildCompactFactor('R', redFactor, Colors.red, onRedFactorChanged),
            const SizedBox(width: 8),
            _buildCompactFactor('G', greenFactor, Colors.green, onGreenFactorChanged),
            const SizedBox(width: 8),
            _buildCompactFactor('B', blueFactor, Colors.blue, onBlueFactorChanged),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactFactor(String label, double value, Color color, ValueChanged<double> onChanged) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
            Text('${value.toStringAsFixed(1)}x', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                activeTrackColor: color,
                thumbColor: color,
              ),
              child: Slider(
                value: value,
                min: 0,
                max: 2,
                divisions: 10,
                onChanged: onChanged,
                onChangeEnd: (_) => onProcessingEnd?.call(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double defaultValue,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
    required VoidCallback onReset,
    ValueChanged<double>? onChangeEnd,
    required Color activeColor,
    required String displayValue,
    required String note,
  }) {
    final bool isModified = value != defaultValue;

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
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Default: $defaultValue',
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500),
            ),
            if (isModified)
              GestureDetector(
                onTap: onReset,
                child: const Text(
                  'Reset',
                  style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
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
