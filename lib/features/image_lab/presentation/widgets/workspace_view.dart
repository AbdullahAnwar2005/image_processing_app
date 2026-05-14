import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../screens/image_lab_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../domain/geometry_state.dart';

import 'image_comparison_card.dart';
import 'segmented_preview_control.dart';
import 'controls/geometry_controls.dart';
import 'controls/color_intensity_controls.dart';
import 'controls/spatial_filter_controls.dart';
import 'controls/edge_segmentation_controls.dart';
import 'controls/histogram_analysis_panel.dart';
import '../../domain/histogram_channel.dart';
import '../../domain/histogram_data.dart';
import '../../domain/image_filter_type.dart';

class WorkspaceView extends StatefulWidget {
  final Uint8List selectedImageBytes;
  final Uint8List processedImageBytes;
  final bool isProcessing;
  final PreviewMode previewMode;
  
  // Dimensions
  final int originalWidth;
  final int originalHeight;
  final int processedWidth;
  final int processedHeight;
  
  // Point Ops
  final double brightness;
  final double contrast;
  final double threshold;
  final int posterizationLevels;
  final double redFactor;
  final double greenFactor;
  final double blueFactor;
  
  // Spatial
  final double blurRadius;
  final EdgeDetectorType edgeDetectorType;
  final SmoothingType smoothingType;
  
  // Geometric (Stateful)
  final GeometryState geometry;
  
  // State
  final int binCount;
  final Set<String> selectedFilters;
  final List<String> activeFilters;
  final Map<HistogramChannel, HistogramData>? histogramByChannel;
  final HistogramChannel selectedHistogramChannel;
  final bool isAnalyzingHistogram;
  
  final VoidCallback onResetBrightness;
  final VoidCallback onResetContrast;
  final VoidCallback onResetRGB;
  final VoidCallback onResetBlur;
  final VoidCallback onResetThreshold;
  final VoidCallback onResetPosterization;
  final VoidCallback onResetGeometry;
  final VoidCallback onResetHistogram;

  // Callbacks
  final Function(HistogramChannel) onHistogramChannelChanged;
  final Function(int) onBinCountChanged;
  final Function(PreviewMode) onPreviewModeChanged;
  final Function(String) onFilterToggled;
  final Function(EdgeDetectorType) onEdgeTypeChanged;
  final Function(SmoothingType) onSmoothingTypeChanged;
  final ValueChanged<double> onBrightnessChanged;
  final ValueChanged<double> onContrastChanged;
  final ValueChanged<double> onBlurRadiusChanged;
  final ValueChanged<double> onThresholdChanged;
  final ValueChanged<int> onPosterizationChanged;
  final ValueChanged<double> onRedFactorChanged;
  final ValueChanged<double> onGreenFactorChanged;
  final ValueChanged<double> onBlueFactorChanged;

  // Geometry Callbacks
  final VoidCallback onRotateRight;
  final VoidCallback onRotateLeft;
  final VoidCallback onToggleFlipH;
  final VoidCallback onToggleFlipV;
  final ValueChanged<double> onScaleFactorChanged;

  final VoidCallback onProcessingEnd;

  final VoidCallback onReset;
  final VoidCallback onExport;
  final Function(Uint8List, String) onImagePressed;

  const WorkspaceView({
    super.key,
    required this.selectedImageBytes,
    required this.processedImageBytes,
    required this.isProcessing,
    required this.previewMode,
    required this.originalWidth,
    required this.originalHeight,
    required this.processedWidth,
    required this.processedHeight,
    required this.brightness,
    required this.contrast,
    required this.blurRadius,
    required this.threshold,
    required this.posterizationLevels,
    required this.redFactor,
    required this.greenFactor,
    required this.blueFactor,
    required this.binCount,
    required this.edgeDetectorType,
    required this.smoothingType,
    required this.geometry,
    required this.selectedFilters,
    required this.activeFilters,
    required this.histogramByChannel,
    required this.selectedHistogramChannel,
    required this.isAnalyzingHistogram,
    required this.onHistogramChannelChanged,
    required this.onBinCountChanged,
    required this.onPreviewModeChanged,
    required this.onFilterToggled,
    required this.onEdgeTypeChanged,
    required this.onSmoothingTypeChanged,
    required this.onBrightnessChanged,
    required this.onContrastChanged,
    required this.onBlurRadiusChanged,
    required this.onThresholdChanged,
    required this.onPosterizationChanged,
    required this.onRedFactorChanged,
    required this.onGreenFactorChanged,
    required this.onBlueFactorChanged,
    required this.onRotateRight,
    required this.onRotateLeft,
    required this.onToggleFlipH,
    required this.onToggleFlipV,
    required this.onScaleFactorChanged,
    required this.onProcessingEnd,
    required this.onResetBrightness,
    required this.onResetContrast,
    required this.onResetRGB,
    required this.onResetBlur,
    required this.onResetThreshold,
    required this.onResetPosterization,
    required this.onResetGeometry,
    required this.onResetHistogram,
    required this.onReset,
    required this.onExport,
    required this.onImagePressed,
  });

  @override
  State<WorkspaceView> createState() => _WorkspaceViewState();
}

enum ControlCategory { geometry, color, filters, edges, histogram }

class _WorkspaceViewState extends State<WorkspaceView> {
  ControlCategory _selectedCategory = ControlCategory.geometry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth >= 600;
        
        if (isTablet) {
          return _buildTabletLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildPreviewSection(),
                const SizedBox(height: 24),
                _buildActiveFilterSummary(),
                const SizedBox(height: 24),
                _buildCategorySwitcher(),
                const SizedBox(height: 16),
                _buildSelectedCategoryPanel(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        _buildBottomActions(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Preview & Pipeline
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPreviewSection(),
                      const SizedBox(height: 24),
                      _buildActiveFilterSummary(),
                    ],
                  ),
                ),
              ),
              // Right Column: Controls
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('1. Geometry', Icons.aspect_ratio_rounded, 'Spatial transforms.'),
                      const SizedBox(height: 12),
                      _buildGeometryControls(),
                      const SizedBox(height: 24),
                      _buildSectionHeader('2. Color & Intensity', Icons.palette_rounded, 'Point transforms.'),
                      const SizedBox(height: 12),
                      _buildColorControls(),
                      const SizedBox(height: 24),
                      _buildSectionHeader('3. Spatial & Extraction', Icons.blur_on_rounded, 'Filtering & segmenting.'),
                      const SizedBox(height: 12),
                      _buildSpatialControls(),
                      const SizedBox(height: 24),
                      _buildEdgeControls(),
                      const SizedBox(height: 24),
                      _buildSectionHeader('4. Analysis', Icons.analytics_rounded, 'Histogram statistics.'),
                      const SizedBox(height: 12),
                      _buildHistogramPanel(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildBottomActions(),
      ],
    );
  }

  Widget _buildPreviewSection() {
    return Column(
      children: [
        ImageComparisonCard(
          originalBytes: widget.selectedImageBytes,
          processedBytes: widget.processedImageBytes,
          isProcessing: widget.isProcessing,
          mode: widget.previewMode,
          onImagePressed: widget.onImagePressed,
          originalWidth: widget.originalWidth,
          originalHeight: widget.originalHeight,
          processedWidth: widget.processedWidth,
          processedHeight: widget.processedHeight,
        ),
        const SizedBox(height: 16),
        SegmentedPreviewControl(
          selectedMode: widget.previewMode,
          onModeChanged: widget.onPreviewModeChanged,
        ),
      ],
    );
  }

  Widget _buildCategorySwitcher() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryChip(ControlCategory.geometry, 'Geometry', Icons.aspect_ratio_rounded),
          const SizedBox(width: 8),
          _buildCategoryChip(ControlCategory.color, 'Color', Icons.palette_rounded),
          const SizedBox(width: 8),
          _buildCategoryChip(ControlCategory.filters, 'Filters', Icons.blur_on_rounded),
          const SizedBox(width: 8),
          _buildCategoryChip(ControlCategory.edges, 'Edges', Icons.filter_center_focus_rounded),
          const SizedBox(width: 8),
          _buildCategoryChip(ControlCategory.histogram, 'Histogram', Icons.analytics_rounded),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(ControlCategory category, String label, IconData icon) {
    final bool isSelected = _selectedCategory == category;
    return ChoiceChip(
      showCheckmark: false,
      avatar: Icon(icon, size: 14, color: isSelected ? Colors.white : AppColors.textSecondary),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedCategory = category);
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }

  Widget _buildSelectedCategoryPanel() {
    switch (_selectedCategory) {
      case ControlCategory.geometry:
        return _buildGeometryControls();
      case ControlCategory.color:
        return _buildColorControls();
      case ControlCategory.filters:
        return _buildSpatialControls();
      case ControlCategory.edges:
        return _buildEdgeControls();
      case ControlCategory.histogram:
        return _buildHistogramPanel();
    }
  }

  Widget _buildGeometryControls() {
    return GeometryControls(
      geometry: widget.geometry,
      onRotateRight: widget.onRotateRight,
      onRotateLeft: widget.onRotateLeft,
      onToggleFlipH: widget.onToggleFlipH,
      onToggleFlipV: widget.onToggleFlipV,
      onScaleFactorChanged: widget.onScaleFactorChanged,
      onResetGeometry: widget.onResetGeometry,
      onProcessingEnd: widget.onProcessingEnd,
    );
  }

  Widget _buildColorControls() {
    return ColorIntensityControls(
      selectedFilters: widget.selectedFilters,
      onFilterToggled: widget.onFilterToggled,
      brightness: widget.brightness,
      contrast: widget.contrast,
      posterizationLevels: widget.posterizationLevels,
      redFactor: widget.redFactor,
      greenFactor: widget.greenFactor,
      blueFactor: widget.blueFactor,
      onBrightnessChanged: widget.onBrightnessChanged,
      onContrastChanged: widget.onContrastChanged,
      onPosterizationChanged: widget.onPosterizationChanged,
      onRedFactorChanged: widget.onRedFactorChanged,
      onGreenFactorChanged: widget.onGreenFactorChanged,
      onBlueFactorChanged: widget.onBlueFactorChanged,
      onResetBrightness: widget.onResetBrightness,
      onResetContrast: widget.onResetContrast,
      onResetRGB: widget.onResetRGB,
      onResetPosterization: widget.onResetPosterization,
      onProcessingEnd: widget.onProcessingEnd,
    );
  }

  Widget _buildSpatialControls() {
    return SpatialFilterControls(
      selectedFilters: widget.selectedFilters,
      onFilterToggled: widget.onFilterToggled,
      blurRadius: widget.blurRadius,
      smoothingType: widget.smoothingType,
      onBlurRadiusChanged: widget.onBlurRadiusChanged,
      onSmoothingTypeChanged: widget.onSmoothingTypeChanged,
      onResetBlur: widget.onResetBlur,
      onProcessingEnd: widget.onProcessingEnd,
    );
  }

  Widget _buildEdgeControls() {
    return EdgeSegmentationControls(
      selectedFilters: widget.selectedFilters,
      onFilterToggled: widget.onFilterToggled,
      edgeDetectorType: widget.edgeDetectorType,
      threshold: widget.threshold,
      onEdgeTypeChanged: widget.onEdgeTypeChanged,
      onThresholdChanged: widget.onThresholdChanged,
      onResetThreshold: widget.onResetThreshold,
      onProcessingEnd: widget.onProcessingEnd,
    );
  }

  Widget _buildHistogramPanel() {
    return HistogramAnalysisPanel(
      histogramByChannel: widget.histogramByChannel,
      selectedChannel: widget.selectedHistogramChannel,
      onChannelChanged: widget.onHistogramChannelChanged,
      isLoading: widget.isAnalyzingHistogram,
      binCount: widget.binCount,
      onBinCountChanged: widget.onBinCountChanged,
      onResetHistogram: widget.onResetHistogram,
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildActiveFilterSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ACTIVE PIPELINE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            if (widget.activeFilters.isNotEmpty)
              Text(
                '${widget.activeFilters.length} Operations',
                style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (widget.activeFilters.isEmpty)
          const Text(
            'No filters applied. Image is in its original state.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.activeFilters.map((f) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Text(
                f,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            )).toList(),
          ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.bottomBarPadding,
        AppSpacing.bottomBarPadding,
        AppSpacing.bottomBarPadding,
        AppSpacing.bottomBarPadding + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppShadows.bottomBarShadow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: widget.onReset,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, AppSpacing.buttonHeight),
                side: const BorderSide(color: AppColors.divider),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.primaryButton),
                ),
              ),
              child: const Text(
                'Reset All',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: widget.onExport,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, AppSpacing.buttonHeight),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.primaryButton),
                ),
              ),
              child: const Text(
                'Export Final Image',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
