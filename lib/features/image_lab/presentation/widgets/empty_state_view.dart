import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import 'lab_card.dart';

class EmptyStateView extends StatelessWidget {
  final VoidCallback onPickImage;
  final VoidCallback onExtractVideoFrame;
  final VoidCallback onShowAbout;

  const EmptyStateView({
    super.key,
    required this.onPickImage,
    required this.onExtractVideoFrame,
    required this.onShowAbout,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_motion_rounded,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Image Filters Lab',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Experiment with manual image processing\nalgorithms and spatial filtering.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            _buildActionCard(
              title: 'Process Image',
              subtitle: 'Load from gallery or camera',
              icon: Icons.image_search_rounded,
              onTap: onPickImage,
              primary: true,
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'Extract Video Frame',
              subtitle: 'Process a single frame from video',
              icon: Icons.video_library_rounded,
              onTap: onExtractVideoFrame,
            ),
            const SizedBox(height: 48),
            TextButton.icon(
              onPressed: onShowAbout,
              icon: const Icon(Icons.info_outline, size: 18),
              label: const Text('About this Project'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool primary = false,
  }) {
    return LabCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary ? AppColors.primary : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: primary ? Colors.white : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.divider,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
