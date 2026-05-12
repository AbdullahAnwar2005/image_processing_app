import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ConceptsGuideBottomSheet extends StatelessWidget {
  const ConceptsGuideBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ConceptsGuideBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lab Concepts Guide',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(backgroundColor: AppColors.surfaceAlt),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              children: [
                _buildSection(
                  'Pixels & RGB',
                  'A digital image is a grid of pixels. Each pixel has red, green, and blue values from 0 to 255.',
                  Icons.grid_4x4_rounded,
                ),
                _buildSection(
                  'Color Operations',
                  'Negative, sepia, posterization, and RGB adjustment change pixel values directly.',
                  Icons.palette_rounded,
                ),
                _buildSection(
                  'Histogram',
                  'A histogram shows how often intensity values appear in the image.',
                  Icons.bar_chart_rounded,
                ),
                _buildSection(
                  'Geometry',
                  'Rotation, flipping, and scaling change pixel positions.',
                  Icons.aspect_ratio_rounded,
                ),
                _buildSection(
                  'Smoothing Filters',
                  'Average, weighted average, and median filters use neighboring pixels to reduce noise.',
                  Icons.blur_on_rounded,
                ),
                _buildSection(
                  'Edge Detection',
                  'Sobel, Prewitt, Roberts, and Laplacian highlight strong intensity changes.',
                  Icons.filter_center_focus_rounded,
                ),
                _buildSection(
                  'Thresholding',
                  'Thresholding converts the image into black and white using an intensity cutoff.',
                  Icons.wb_iridescent_rounded,
                ),
                _buildSection(
                  'Processing Pipeline',
                  'The app uses a non-destructive pipeline. The original image stays safe, and every result is rebuilt from the source.',
                  Icons.account_tree_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
