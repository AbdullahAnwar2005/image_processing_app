import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadii.heroCardRadius,
        boxShadow: AppShadows.heroShadow,
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(AppSpacing.heroPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppRadii.iconButton),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'IMAGE PROCESSING LAB',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start experimenting with image filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Upload an image and explore grayscale, contrast, blur, edge detection, and histogram analysis.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    height: 1.55,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),
                _buildFeatureRow(Icons.bolt_rounded, 'Real-time preview'),
                const SizedBox(height: 12),
                _buildFeatureRow(Icons.analytics_outlined, 'Pixel statistics'),
                const SizedBox(height: 12),
                _buildFeatureRow(Icons.compare_arrows_rounded, 'Visual comparison'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String label) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
