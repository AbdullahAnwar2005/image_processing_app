import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class QuickStatsGrid extends StatelessWidget {
  const QuickStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatCard('5+', 'Filters'),
        const SizedBox(width: AppSpacing.sectionGap),
        _buildStatCard('RGB', 'Channels'),
        const SizedBox(width: AppSpacing.sectionGap),
        _buildStatCard('8-bit', 'Depth'),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
