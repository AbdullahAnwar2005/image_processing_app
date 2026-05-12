import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class FeatureChipWrap extends StatelessWidget {
  final Set<String> selectedFilters;
  final Function(String)? onFilterToggled;
  final List<FeatureOption> options;

  const FeatureChipWrap({
    super.key,
    required this.selectedFilters,
    this.onFilterToggled,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    // Two-column grid layout using Rows and Columns to ensure equal width
    final List<Widget> rows = [];
    for (int i = 0; i < options.length; i += 2) {
      rows.add(
        Row(
          children: [
            Expanded(child: _buildItem(options[i])),
            const SizedBox(width: 8),
            Expanded(
              child: (i + 1 < options.length) 
                  ? _buildItem(options[i + 1]) 
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
      if (i + 2 < options.length) {
        rows.add(const SizedBox(height: 8));
      }
    }

    return Column(children: rows);
  }

  Widget _buildItem(FeatureOption option) {
    final bool isSelected = selectedFilters.contains(option.label);
    
    return InkWell(
      onTap: onFilterToggled != null ? () => onFilterToggled!(option.label) : null,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary.withOpacity(0.4) : AppColors.divider,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              option.icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                option.label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureOption {
  final String label;
  final IconData icon;

  const FeatureOption(this.label, this.icon);
}
