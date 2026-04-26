import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatBox('MEAN', '--'),
        const SizedBox(width: 12),
        _buildStatBox('STD DEV', '--'),
        const SizedBox(width: 12),
        _buildStatBox('ENTROPY', '--'),
      ],
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceInput,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceAlt),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
