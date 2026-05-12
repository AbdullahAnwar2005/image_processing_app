import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../screens/image_lab_screen.dart';
import 'lab_card.dart';

class ImageComparisonCard extends StatelessWidget {
  final Uint8List originalBytes;
  final Uint8List processedBytes;
  final PreviewMode mode;
  final bool isProcessing;
  final Function(Uint8List, String) onImagePressed;

  // New: Dimensions
  final int originalWidth;
  final int originalHeight;
  final int processedWidth;
  final int processedHeight;

  const ImageComparisonCard({
    super.key,
    required this.originalBytes,
    required this.processedBytes,
    required this.mode,
    this.isProcessing = false,
    required this.onImagePressed,
    required this.originalWidth,
    required this.originalHeight,
    required this.processedWidth,
    required this.processedHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LabCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.imagePreview),
              child: _buildImageContent(),
            ),
          ),
          const SizedBox(height: 12),
          _buildMetricsRow(),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    switch (mode) {
      case PreviewMode.original:
        return _buildTappableImage(
          bytes: originalBytes,
          label: 'ORIGINAL',
          labelColor: Colors.black.withOpacity(0.55),
          heroTag: 'original_preview',
        );
      case PreviewMode.processed:
        return _buildTappableImage(
          bytes: processedBytes,
          label: 'PROCESSED',
          labelColor: AppColors.primary.withOpacity(0.75),
          heroTag: 'processed_preview',
          showLoading: isProcessing,
        );
      case PreviewMode.compare:
        return Row(
          children: [
            Expanded(
              child: _buildTappableImage(
                bytes: originalBytes,
                label: 'ORIGINAL',
                labelColor: Colors.black.withOpacity(0.55),
                heroTag: 'compare_original',
              ),
            ),
            Container(width: 2, color: Colors.white),
            Expanded(
              child: _buildTappableImage(
                bytes: processedBytes,
                label: 'PROCESSED',
                labelColor: AppColors.primary.withOpacity(0.75),
                heroTag: 'compare_processed',
                showLoading: isProcessing,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildTappableImage({
    required Uint8List bytes,
    required String label,
    required Color labelColor,
    required String heroTag,
    bool showLoading = false,
  }) {
    return GestureDetector(
      onTap: () => onImagePressed(bytes, heroTag),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: heroTag,
            child: Image.memory(bytes, fit: BoxFit.cover),
          ),
          if (showLoading) _buildLoadingOverlay(),
          _buildLabelOverlay(label, labelColor),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black26,
      child: const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildLabelOverlay(String text, Color color) {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsRow() {
    String dimensionText;
    if (mode == PreviewMode.compare) {
      dimensionText = 'Org: ${originalWidth}x${originalHeight} • Proc: ${processedWidth}x${processedHeight}';
    } else if (mode == PreviewMode.original) {
      dimensionText = '${originalWidth}x$originalHeight';
    } else {
      dimensionText = '${processedWidth}x$processedHeight';
    }

    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const _Metric(label: 'FORMAT', value: 'JPG/PNG'),
          _Metric(label: 'DIMENSIONS', value: dimensionText),
          const _Metric(label: 'MODE', value: 'RGB'),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
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
    );
  }
}
