import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class FeatureChipWrap extends StatelessWidget {
  final Set<String> selectedFilters;
  final Function(String)? onFilterToggled;

  const FeatureChipWrap({
    super.key,
    this.selectedFilters = const {},
    this.onFilterToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFilterChip('Grayscale', Icons.hdr_strong),
        _buildFilterChip('Negative', Icons.invert_colors),
        _buildFilterChip('Sepia', Icons.photo_filter),
        _buildFilterChip('Equalization', Icons.equalizer),
        _buildFilterChip('Blur', Icons.blur_on),
        _buildFilterChip('Edges', Icons.filter_center_focus),
        _buildFilterChip('Threshold', Icons.wb_iridescent),
      ],
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final bool isSelected = selectedFilters.contains(label);
    
    Color backgroundColor;
    Color iconColor;
    Color textColor;

    if (isSelected) {
      switch (label) {
        case 'Grayscale':
          backgroundColor = AppColors.grayscaleBg;
          break;
        case 'Blur':
          backgroundColor = AppColors.blurBg;
          break;
        case 'Edges':
          backgroundColor = AppColors.edgesBg;
          break;
        case 'Threshold':
          backgroundColor = AppColors.thresholdBg;
          break;
        case 'Equalization':
        case 'Negative':
        case 'Sepia':
          backgroundColor = AppColors.primary;
          break;
        default:
          backgroundColor = AppColors.primary;
      }
      iconColor = isSelected && (label == 'Equalization' || label == 'Negative' || label == 'Sepia') ? Colors.white : _getTextColor(label);
      textColor = isSelected && (label == 'Equalization' || label == 'Negative' || label == 'Sepia') ? Colors.white : _getTextColor(label);
    } else {
      backgroundColor = AppColors.surfaceAlt;
      iconColor = AppColors.textSecondary;
      textColor = AppColors.textSecondary;
    }

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      avatar: Icon(
        icon,
        size: 14,
        color: iconColor,
      ),
      selected: isSelected,
      onSelected: onFilterToggled != null ? (_) => onFilterToggled!(label) : null,
      backgroundColor: backgroundColor,
      selectedColor: backgroundColor,
      checkmarkColor: textColor,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide(
          color: isSelected ? _getTextColor(label).withOpacity(0.3) : AppColors.divider,
          width: 1,
        ),
      ),
    );
  }

  Color _getTextColor(String label) {
    switch (label) {
      case 'Grayscale':
        return AppColors.grayscaleText;
      case 'Blur':
        return AppColors.blurText;
      case 'Edges':
        return AppColors.edgesText;
      case 'Threshold':
        return AppColors.thresholdText;
      case 'Equalization':
      case 'Negative':
      case 'Sepia':
        return Colors.white;
      default:
        return AppColors.primary;
    }
  }
}
