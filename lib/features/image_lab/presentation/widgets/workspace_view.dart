import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../screens/image_lab_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

import 'image_comparison_card.dart';
import 'segmented_preview_control.dart';
import 'filter_controls_card.dart';
import 'histogram_card.dart';
import '../../domain/histogram_channel.dart';
import '../../domain/histogram_data.dart';

class WorkspaceView extends StatelessWidget {
  final Uint8List selectedImageBytes;
  final Uint8List processedImageBytes;
  final bool isProcessing;
  final PreviewMode previewMode;
  final double brightness;
  final double contrast;
  final double blurRadius;
  final Set<String> selectedFilters;
  final Map<HistogramChannel, HistogramData>? histogramByChannel;
  final HistogramChannel selectedHistogramChannel;
  final bool isAnalyzingHistogram;
  final Function(HistogramChannel) onHistogramChannelChanged;
  final Function(PreviewMode) onPreviewModeChanged;
  final Function(String) onFilterToggled;
  final ValueChanged<double> onBrightnessChanged;
  final ValueChanged<double> onContrastChanged;
  final ValueChanged<double> onBlurRadiusChanged;
  final ValueChanged<double>? onBrightnessChangeEnd;
  final ValueChanged<double>? onContrastChangeEnd;
  final ValueChanged<double>? onBlurRadiusChangeEnd;
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
    required this.selectedFilters,
    required this.histogramByChannel,
    required this.selectedHistogramChannel,
    required this.isAnalyzingHistogram,
    required this.onHistogramChannelChanged,
    required this.onPreviewModeChanged,
    required this.onFilterToggled,
    required this.onBrightnessChanged,
    required this.onContrastChanged,
    required this.onBlurRadiusChanged,
    this.onBrightnessChangeEnd,
    this.onContrastChangeEnd,
    this.onBlurRadiusChangeEnd,
    required this.onReset,
    required this.onExport,
    required this.onImagePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
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
                  FilterControlsCard(
                    selectedFilters: selectedFilters,
                    onFilterToggled: onFilterToggled,
                    brightness: brightness,
                    contrast: contrast,
                    blurRadius: blurRadius,
                    onBrightnessChanged: onBrightnessChanged,
                    onContrastChanged: onContrastChanged,
                    onBlurRadiusChanged: onBlurRadiusChanged,
                    onBrightnessChangeEnd: onBrightnessChangeEnd,
                    onContrastChangeEnd: onContrastChangeEnd,
                    onBlurRadiusChangeEnd: onBlurRadiusChangeEnd,
                  ),
                   const SizedBox(height: 24),
                  HistogramCard(
                    histogramByChannel: histogramByChannel,
                    selectedChannel: selectedHistogramChannel,
                    onChannelChanged: onHistogramChannelChanged,
                    isLoading: isAnalyzingHistogram,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Image Filters Lab',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            Text(
              'Workspace',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: onReset,
          icon: const Icon(
            Icons.restart_alt_rounded,
            color: AppColors.textSecondary,
          ),
          tooltip: 'Reset Workspace',
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
        AppSpacing.bottomBarPadding + 8, // Added extra bottom safe padding
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
                'Reset',
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
                'Export Image',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
