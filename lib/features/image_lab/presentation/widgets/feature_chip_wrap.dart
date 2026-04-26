import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';

class FeatureChipWrap extends StatelessWidget {
  final Set<String>? selectedFilters;
  final Function(String)? onFilterToggled;

  const FeatureChipWrap({
    super.key,
    this.selectedFilters,
    this.onFilterToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildChip(
          'Grayscale',
          AppColors.grayscaleBg,
          AppColors.grayscaleText,
        ),
        _buildChip(
          'Contrast',
          AppColors.contrastBg,
          AppColors.contrastText,
        ),
        _buildChip(
          'Blur',
          AppColors.blurBg,
          AppColors.blurText,
        ),
        _buildChip(
          'Edges',
          AppColors.edgesBg,
          AppColors.edgesText,
        ),
        _buildChip(
          'Histogram',
          AppColors.histogramBg,
          AppColors.histogramText,
        ),
      ],
    );
  }

  Widget _buildChip(String label, Color bgColor, Color textColor) {
    final bool isSelected = selectedFilters?.contains(label) ?? false;
    
    return GestureDetector(
      onTap: () => onFilterToggled?.call(label),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.chipHorizontalPadding,
          vertical: AppSpacing.chipVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : AppColors.surfaceInput,
          borderRadius: AppRadii.chipRadius,
          border: Border.all(
            color: isSelected ? textColor.withOpacity(0.22) : AppColors.divider,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? textColor : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
