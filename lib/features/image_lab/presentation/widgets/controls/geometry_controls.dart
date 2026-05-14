import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../domain/filter_defaults.dart';
import '../../../domain/geometry_state.dart';
import '../lab_card.dart';

class GeometryControls extends StatelessWidget {
  final GeometryState geometry;
  final VoidCallback onRotateRight;
  final VoidCallback onRotateLeft;
  final VoidCallback onToggleFlipH;
  final VoidCallback onToggleFlipV;
  final ValueChanged<double> onScaleFactorChanged;
  final VoidCallback onResetGeometry;
  final VoidCallback? onProcessingEnd;

  const GeometryControls({
    super.key,
    required this.geometry,
    required this.onRotateRight,
    required this.onRotateLeft,
    required this.onToggleFlipH,
    required this.onToggleFlipV,
    required this.onScaleFactorChanged,
    required this.onResetGeometry,
    this.onProcessingEnd,
  });

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
              const Text(
                'TRANSFORMS',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              if (!geometry.isIdentity)
                TextButton(
                  onPressed: onResetGeometry,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Reset Geometry', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildActionIconButton(
                Icons.rotate_90_degrees_ccw_rounded, 
                'Left', 
                onRotateLeft
              ),
              const SizedBox(width: 8),
              _buildActionIconButton(
                Icons.rotate_90_degrees_cw_rounded, 
                'Right', 
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
          ),
          const SizedBox(height: 16),
          _buildSlider(
            label: 'Scale Factor',
            value: geometry.scaleFactor,
            defaultValue: FilterDefaults.scale,
            min: FilterDefaults.scaleMin,
            max: FilterDefaults.scaleMax,
            divisions: 6,
            onChanged: onScaleFactorChanged,
            onReset: onResetGeometry,
            onChangeEnd: (_) => onProcessingEnd?.call(),
            activeColor: Colors.deepPurple,
            displayValue: '${geometry.scaleFactor.toStringAsFixed(1)}x',
            note: 'Nearest-neighbor sampling.',
          ),
        ],
      ),
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
                Text(
                  label,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                Text(
                  note,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                ),
              ],
            ),
            Text(
              displayValue,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: activeColor),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Default: ${defaultValue.toStringAsFixed(1)}x',
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
