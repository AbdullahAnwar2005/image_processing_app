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
import 'filter_controls_card.dart';
import 'histogram_card.dart';
import '../../domain/histogram_channel.dart';
import '../../domain/histogram_data.dart';
import '../../domain/image_filter_type.dart';

class WorkspaceView extends StatelessWidget {
  final Uint8List selectedImageBytes;
  final Uint8List processedImageBytes;
  final bool isProcessing;
  final PreviewMode previewMode;
  
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
    required this.onReset,
    required this.onExport,
    required this.onImagePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                ImageComparisonCard(
                  originalBytes: selectedImageBytes,
                  processedBytes: processedImageBytes,
                  isProcessing: isProcessing,
                  mode: previewMode,
                  onImagePressed: onImagePressed,
                ),
                const SizedBox(height: 16),
                SegmentedPreviewControl(
                  selectedMode: previewMode,
                  onModeChanged: onPreviewModeChanged,
                ),
                const SizedBox(height: 24),
                _buildActiveFilterSummary(),
                const SizedBox(height: 24),
                FilterControlsCard(
                  selectedFilters: selectedFilters,
                  onFilterToggled: onFilterToggled,
                  brightness: brightness,
                  contrast: contrast,
                  blurRadius: blurRadius,
                  threshold: threshold,
                  posterizationLevels: posterizationLevels,
                  redFactor: redFactor,
                  greenFactor: greenFactor,
                  blueFactor: blueFactor,
                  edgeDetectorType: edgeDetectorType,
                  smoothingType: smoothingType,
                  geometry: geometry,
                  onBrightnessChanged: onBrightnessChanged,
                  onContrastChanged: onContrastChanged,
                  onBlurRadiusChanged: onBlurRadiusChanged,
                  onThresholdChanged: onThresholdChanged,
                  onPosterizationChanged: onPosterizationChanged,
                  onRedFactorChanged: onRedFactorChanged,
                  onGreenFactorChanged: onGreenFactorChanged,
                  onBlueFactorChanged: onBlueFactorChanged,
                  onEdgeTypeChanged: onEdgeTypeChanged,
                  onSmoothingTypeChanged: onSmoothingTypeChanged,
                  onRotateRight: onRotateRight,
                  onRotateLeft: onRotateLeft,
                  onToggleFlipH: onToggleFlipH,
                  onToggleFlipV: onToggleFlipV,
                  onScaleFactorChanged: onScaleFactorChanged,
                  onProcessingEnd: onProcessingEnd,
                ),
                 const SizedBox(height: 24),
                HistogramCard(
                  histogramByChannel: histogramByChannel,
                  selectedChannel: selectedHistogramChannel,
                  onChannelChanged: onHistogramChannelChanged,
                  isLoading: isAnalyzingHistogram,
                  binCount: binCount,
                  onBinCountChanged: onBinCountChanged,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        _buildBottomActions(),
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
            if (activeFilters.isNotEmpty)
              Text(
                '${activeFilters.length} Operations',
                style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (activeFilters.isEmpty)
          const Text(
            'No filters applied. Image is in its original state.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: activeFilters.map((f) => Container(
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
              onPressed: onReset,
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
              onPressed: onExport,
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
