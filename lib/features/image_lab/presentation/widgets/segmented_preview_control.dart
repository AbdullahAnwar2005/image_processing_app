import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../screens/image_lab_screen.dart';

class SegmentedPreviewControl extends StatelessWidget {
  final PreviewMode selectedMode;
  final Function(PreviewMode) onModeChanged;

  const SegmentedPreviewControl({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadii.segmentedOuter),
      ),
      child: Row(
        children: [
          _buildOption(PreviewMode.original, 'Original'),
          _buildOption(PreviewMode.processed, 'Processed'),
          _buildOption(PreviewMode.compare, 'Compare'),
        ],
      ),
    );
  }

  Widget _buildOption(PreviewMode mode, String label) {
    final isSelected = selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => onModeChanged(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.segmentedInner),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
