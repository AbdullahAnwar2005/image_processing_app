import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../domain/filter_defaults.dart';
import '../../domain/image_filter_type.dart';
import '../../domain/geometry_state.dart';
import 'lab_card.dart';
import 'feature_chip_wrap.dart';

class FilterControlsCard extends StatelessWidget {
  final Set<String> selectedFilters;
  final Function(String) onFilterToggled;
  
  // Point Operations
  final double brightness;
  final double contrast;
  final double threshold;
  final int posterizationLevels;
  final double redFactor;
  final double greenFactor;
  final double blueFactor;
  
  // Spatial
  final double blurRadius;
  final EdgeDetectorType edgeDetectorType;
  final SmoothingType smoothingType;
  
  // Geometric (Stateful)
  final GeometryState geometry;
  
  // Callbacks
  final ValueChanged<double> onBrightnessChanged;
  final ValueChanged<double> onContrastChanged;
  final ValueChanged<double> onBlurRadiusChanged;
  final ValueChanged<double> onThresholdChanged;
  final ValueChanged<int> onPosterizationChanged;
  final ValueChanged<double> onRedFactorChanged;
  final ValueChanged<double> onGreenFactorChanged;
  final ValueChanged<double> onBlueFactorChanged;
  final Function(EdgeDetectorType) onEdgeTypeChanged;
  final Function(SmoothingType) onSmoothingTypeChanged;
  
  // New Geometry Callbacks
  final VoidCallback onRotateRight;
  final VoidCallback onRotateLeft;
  final VoidCallback onToggleFlipH;
  final VoidCallback onToggleFlipV;
  final ValueChanged<double> onScaleFactorChanged;
  
  final VoidCallback? onProcessingEnd;

  const FilterControlsCard({
    super.key,
    required this.selectedFilters,
    required this.onFilterToggled,
    required this.brightness,
    required this.contrast,
    required this.blurRadius,
    required this.threshold,
    required this.posterizationLevels,
    required this.redFactor,
    required this.greenFactor,
    required this.blueFactor,
    required this.edgeDetectorType,
    required this.smoothingType,
    required this.geometry,
    required this.onBrightnessChanged,
    required this.onContrastChanged,
    required this.onBlurRadiusChanged,
    required this.onThresholdChanged,
    required this.onPosterizationChanged,
    required this.onRedFactorChanged,
    required this.onGreenFactorChanged,
    required this.onBlueFactorChanged,
    required this.onEdgeTypeChanged,
    required this.onSmoothingTypeChanged,
    required this.onRotateRight,
    required this.onRotateLeft,
    required this.onToggleFlipH,
    required this.onToggleFlipV,
    required this.onScaleFactorChanged,
    this.onProcessingEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('1. Geometry', Icons.aspect_ratio_rounded, 'Spatial transforms.'),
        const SizedBox(height: 12),
        LabCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildGeometricControls(),
              const SizedBox(height: 16),
              _buildSlider(
                label: 'Scale Factor',
                value: geometry.scaleFactor,
                min: FilterDefaults.scaleMin,
                max: FilterDefaults.scaleMax,
                divisions: 6,
                onChanged: onScaleFactorChanged,
                onChangeEnd: (_) => onProcessingEnd?.call(),
                activeColor: Colors.deepPurple,
                displayValue: '${geometry.scaleFactor.toStringAsFixed(1)}x',
                note: 'Nearest-neighbor sampling.',
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        _buildSectionHeader('2. Pixel Operations', Icons.palette_rounded, 'Point transforms.'),
        const SizedBox(height: 12),
        LabCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              FeatureChipWrap(
                selectedFilters: selectedFilters,
                onFilterToggled: onFilterToggled,
              ),
              const Divider(height: 32),
              _buildSlider(
                label: 'Brightness',
                value: brightness,
                min: FilterDefaults.brightnessMin,
                max: FilterDefaults.brightnessMax,
                divisions: 100,
                onChanged: onBrightnessChanged,
                onChangeEnd: (_) => onProcessingEnd?.call(),
                activeColor: AppColors.brightnessSlider,
                displayValue: brightness.toInt().toString(),
                note: 'Intensity offset.',
              ),
              const SizedBox(height: 12),
              _buildSlider(
                label: 'Contrast',
                value: contrast,
                min: FilterDefaults.contrastMin,
                max: FilterDefaults.contrastMax,
                divisions: 20,
                onChanged: onContrastChanged,
                onChangeEnd: (_) => onProcessingEnd?.call(),
                activeColor: AppColors.contrastSlider,
                displayValue: contrast.toStringAsFixed(1),
                note: 'Intensity scaling.',
              ),
              const SizedBox(height: 12),
              _buildSlider(
                label: 'Posterization',
                value: posterizationLevels.toDouble(),
                min: FilterDefaults.posterizationMin,
                max: FilterDefaults.posterizationMax,
                divisions: 16,
                onChanged: (v) => onPosterizationChanged(v.toInt()),
                onChangeEnd: (_) => onProcessingEnd?.call(),
                activeColor: Colors.teal,
                displayValue: posterizationLevels == 0 ? 'OFF' : posterizationLevels.toString(),
                note: 'Quantizes color levels.',
              ),
              if (posterizationLevels > 0) ...[
                 const SizedBox(height: 12),
                 _buildRgbAdjusters(),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),
        _buildSectionHeader('3. Spatial & Features', Icons.blur_on_rounded, 'Kernel filtering.'),
        const SizedBox(height: 12),
        LabCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
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
              if (selectedFilters.contains('Blur')) ...[
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
              ],
              if (selectedFilters.contains('Edges')) ...[
                const SizedBox(height: 16),
                _buildTypeSelector<EdgeDetectorType>(
                  label: 'Edge Detector',
                  value: edgeDetectorType,
                  options: {
                    EdgeDetectorType.sobel: 'Sobel',
                    EdgeDetectorType.prewitt: 'Prewitt',
                    EdgeDetectorType.roberts: 'Roberts',
                    EdgeDetectorType.laplacian: 'Laplacian',
                  },
                  onChanged: onEdgeTypeChanged,
                ),
              ],
              if (selectedFilters.contains('Threshold')) ...[
                 const SizedBox(height: 16),
                _buildSlider(
                  label: 'Binary Threshold',
                  value: threshold,
                  min: FilterDefaults.thresholdMin,
                  max: FilterDefaults.thresholdMax,
                  divisions: 255,
                  onChanged: onThresholdChanged,
                  onChangeEnd: (_) => onProcessingEnd?.call(),
                  activeColor: AppColors.thresholdSlider,
                  displayValue: threshold.toInt().toString(),
                  note: 'Intensity segmentation.',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRgbAdjusters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CHANNEL BALANCING',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
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

  Widget _buildGeometricControls() {
    final rotationLabel = '${(geometry.rotationQuarterTurns * 90) % 360}°';
    
    return Row(
      children: [
        _buildActionIconButton(
          Icons.rotate_90_degrees_ccw_rounded, 
          'Left ($rotationLabel)', 
          onRotateLeft
        ),
        const SizedBox(width: 8),
        _buildActionIconButton(
          Icons.rotate_90_degrees_cw_rounded, 
          'Right ($rotationLabel)', 
          onRotateRight
        ),
        const SizedBox(width: 8),
        _buildActionIconButton(
          Icons.flip_rounded, 
          'Flip H', 
          onToggleFlipH,
          isActive: geometry.flipHorizontal,
        ),
        const SizedBox(width: 8),
        _buildActionIconButton(
          Icons.flip_rounded, 
          'Flip V', 
          onToggleFlipV,
          rotate: true,
          isActive: geometry.flipVertical,
        ),
      ],
    );
  }

  Widget _buildActionIconButton(
    IconData icon, 
    String label, 
    VoidCallback onTap, {
    bool rotate = false,
    bool isActive = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isActive ? AppColors.primary.withOpacity(0.3) : AppColors.divider),
          ),
          child: Column(
            children: [
              Transform.rotate(
                angle: rotate ? 1.57 : 0,
                child: Icon(
                  icon, 
                  size: 18, 
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label, 
                style: TextStyle(
                  fontSize: 8, 
                  fontWeight: FontWeight.w700,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
      ],
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<T>(
            segments: options.entries.map((e) {
              return ButtonSegment<T>(
                value: e.key,
                label: Text(e.value, style: const TextStyle(fontSize: 10)),
              );
            }).toList(),
            selected: {value},
            onSelectionChanged: (Set<T> selection) {
              onChanged(selection.first);
            },
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
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  note,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
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
        const SizedBox(height: 2),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: activeColor,
            inactiveTrackColor: AppColors.divider,
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
