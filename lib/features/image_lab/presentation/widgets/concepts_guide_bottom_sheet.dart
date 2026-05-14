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
    final double screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      height: screenHeight * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(context),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              children: [
                _buildSection(
                  title: 'Image Basics',
                  icon: Icons.image_outlined,
                  children: [
                    const ConceptGuideItem(
                      title: 'Digital Image',
                      description: 'A discrete representation of a scene, stored as a matrix of numbers (pixels).',
                      useCase: 'Fundamental unit of computer vision.',
                    ),
                    const ConceptGuideItem(
                      title: 'Pixel & RGB',
                      description: 'The smallest element of an image. Each contains Red, Green, and Blue values.',
                      formula: 'Values range from 0 to 255',
                    ),
                  ],
                ),
                _buildSection(
                  title: 'Color & Intensity',
                  icon: Icons.palette_outlined,
                  children: [
                    const ConceptGuideItem(
                      title: 'Intensity',
                      description: 'The perceived brightness of a pixel.',
                    ),
                    const ConceptGuideItem(
                      title: 'Grayscale',
                      description: 'Converts RGB values into one intensity value.',
                      formula: '0.299R + 0.587G + 0.114B',
                    ),
                    const ConceptGuideItem(
                      title: 'Negative',
                      description: 'Inverts each color channel.',
                      formula: '255 - value',
                    ),
                    const ConceptGuideItem(
                      title: 'Sepia',
                      description: 'A warm, brownish-red color effect mimicking old photographs.',
                      useCase: 'Used for artistic or vintage aesthetics.',
                    ),
                    const ConceptGuideItem(
                      title: 'Posterization',
                      description: 'Reduces the number of available color levels.',
                      useCase: 'Useful for stylized or simplified color effects.',
                      formula: 'Levels = 2, 4, 8, 16...',
                    ),
                    const ConceptGuideItem(
                      title: 'RGB Adjustment',
                      description: 'Independently scaling the Red, Green, and Blue channels to balance color.',
                    ),
                    const ConceptGuideItem(
                      title: 'Brightness',
                      description: 'Shifting the overall intensity range up or down by a constant offset.',
                      formula: 'value + offset',
                    ),
                    const ConceptGuideItem(
                      title: 'Contrast',
                      description: 'Stretching the intensity range around a midpoint to enhance detail.',
                      formula: '(value - 128) * factor + 128',
                    ),
                  ],
                ),
                _buildSection(
                  title: 'Histogram',
                  icon: Icons.bar_chart_rounded,
                  children: [
                    const ConceptGuideItem(
                      title: 'Histogram',
                      description: 'Counts how often each intensity or channel value appears in the image.',
                      formula: 'X-axis = intensity, Y-axis = count',
                    ),
                    const ConceptGuideItem(
                      title: 'Binning',
                      description: 'Groups ranges of values into fewer columns for display.',
                      useCase: 'Reduces complexity for large datasets.',
                    ),
                    const ConceptGuideItem(
                      title: 'Histogram Equalization',
                      description: 'A technique to spread out intensities, improving overall image contrast.',
                    ),
                  ],
                ),
                _buildSection(
                  title: 'Geometry',
                  icon: Icons.aspect_ratio_rounded,
                  children: [
                    const ConceptGuideItem(
                      title: 'Geometry',
                      description: 'Operations that change the spatial coordinates of pixels.',
                    ),
                    const ConceptGuideItem(
                      title: 'Rotation',
                      description: 'Turning the image by 90°, 180°, or 270° around its center.',
                    ),
                    const ConceptGuideItem(
                      title: 'Flip / Reflection',
                      description: 'Creating a mirror image horizontally or vertically.',
                    ),
                    const ConceptGuideItem(
                      title: 'Scaling',
                      description: 'Changing dimensions using Nearest Neighbor interpolation.',
                    ),
                  ],
                ),
                _buildSection(
                  title: 'Spatial Filters',
                  icon: Icons.blur_on_rounded,
                  children: [
                    const ConceptGuideItem(
                      title: 'Spatial Filtering',
                      description: 'Modifying a pixel based on the values of its neighbors (3x3 grid).',
                    ),
                    const ConceptGuideItem(
                      title: 'Average Filter',
                      description: 'Smoothing by taking the mean of all neighbors.',
                      formula: '1/9 * Sum of 3x3 neighbors',
                    ),
                    const ConceptGuideItem(
                      title: 'Weighted Average',
                      description: 'Smoothing that gives more importance to the center pixel.',
                    ),
                    const ConceptGuideItem(
                      title: 'Median Filter',
                      description: 'Sorts the 3x3 neighborhood and picks the middle value.',
                      useCase: 'Best for removing salt-and-pepper noise.',
                    ),
                    const ConceptGuideItem(
                      title: 'Min Filter',
                      description: 'Darkens the image by picking the minimum neighbor value.',
                    ),
                    const ConceptGuideItem(
                      title: 'Max Filter',
                      description: 'Brightens the image by picking the maximum neighbor value.',
                    ),
                  ],
                ),
                _buildSection(
                  title: 'Edge & Segmentation',
                  icon: Icons.filter_center_focus_rounded,
                  children: [
                    const ConceptGuideItem(
                      title: 'Edge Detection',
                      description: 'Identifying boundaries by finding sharp changes in intensity.',
                    ),
                    const ConceptGuideItem(
                      title: 'Sobel',
                      description: 'Uses horizontal and vertical kernels to calculate gradients.',
                    ),
                    const ConceptGuideItem(
                      title: 'Prewitt',
                      description: 'Similar to Sobel but uses uniform weights.',
                    ),
                    const ConceptGuideItem(
                      title: 'Roberts',
                      description: 'A simple cross-gradient operator for detecting small edges.',
                    ),
                    const ConceptGuideItem(
                      title: 'Laplacian',
                      description: 'A second-order derivative operator that detects isotropic edges.',
                    ),
                    const ConceptGuideItem(
                      title: 'Thresholding',
                      description: 'Converts an image into black and white using an intensity cutoff.',
                      formula: 'intensity >= T ? 255 : 0',
                    ),
                  ],
                ),
                _buildSection(
                  title: 'App Workflow',
                  icon: Icons.account_tree_outlined,
                  children: [
                    const ConceptGuideItem(
                      title: 'Non-Destructive Pipeline',
                      description: 'Original data is never modified. All filters are reapplied from source.',
                    ),
                    const ConceptGuideItem(
                      title: 'Video Sampling',
                      description: 'Sampling a still image from a video file to process it as a frame.',
                    ),
                  ],
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
        margin: const EdgeInsets.symmetric(vertical: 16),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 16, 12),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lab Concepts Guide',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Quick reference for CPIT-380',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceAlt,
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider.withOpacity(0.5)),
        ),
        child: ExpansionTile(
          initiallyExpanded: title == 'Image Basics',
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedAlignment: Alignment.topLeft,
          children: children,
        ),
      ),
    );
  }
}

class ConceptGuideItem extends StatelessWidget {
  final String title;
  final String description;
  final String? formula;
  final String? useCase;

  const ConceptGuideItem({
    super.key,
    required this.title,
    required this.description,
    this.formula,
    this.useCase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          if (useCase != null) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Use case: ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                Expanded(
                  child: Text(
                    useCase!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (formula != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Text(
                formula!,
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
