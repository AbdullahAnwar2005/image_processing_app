import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_shadows.dart';
import 'hero_card.dart';
import 'feature_chip_wrap.dart';
import 'quick_stats_grid.dart';
import 'lab_card.dart';

class EmptyStateView extends StatelessWidget {
  final VoidCallback onPickImage;

  const EmptyStateView({super.key, required this.onPickImage});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildHeader(),
            const SizedBox(height: 24),
            const HeroCard(),
            const SizedBox(height: 32),
            const Text(
              'Explore Capabilities',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const FeatureChipWrap(),
            const SizedBox(height: 32),
            _buildImagePlaceholder(),
            const SizedBox(height: 32),
            const QuickStatsGrid(),
            const SizedBox(height: 40),
            _buildPickButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.auto_fix_high, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Image Filters Lab',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Mobile image processing workspace',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return LabCard(
      radius: 24,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No image selected',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose a JPG or PNG image to begin',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickButton() {
    return Container(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      decoration: BoxDecoration(boxShadow: AppShadows.primaryButtonShadow),
      child: FilledButton.icon(
        onPressed: onPickImage,
        icon: const Icon(Icons.photo_library_outlined, size: 20),
        label: const Text(
          'Pick Image',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.primaryButton),
          ),
        ),
      ),
    );
  }
}
