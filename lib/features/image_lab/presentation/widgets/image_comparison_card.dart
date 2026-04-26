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

  const ImageComparisonCard({
    super.key,
    required this.originalBytes,
    required this.processedBytes,
    required this.mode,
    this.isProcessing = false,
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
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(originalBytes, fit: BoxFit.cover),
            _buildLabelOverlay('ORIGINAL', Colors.black.withOpacity(0.55)),
          ],
        );
      case PreviewMode.processed:
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(processedBytes, fit: BoxFit.cover),
            if (isProcessing)
              _buildLoadingOverlay(),
            _buildLabelOverlay('PROCESSED', AppColors.primary.withOpacity(0.75)),
          ],
        );
      case PreviewMode.compare:
        return Row(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(originalBytes, fit: BoxFit.cover),
                  _buildLabelOverlay('ORIGINAL', Colors.black.withOpacity(0.55)),
                ],
              ),
            ),
            Container(width: 2, color: Colors.white),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(processedBytes, fit: BoxFit.cover),
                  if (isProcessing)
                    _buildLoadingOverlay(),
                  _buildLabelOverlay('PROCESSED', AppColors.primary.withOpacity(0.75)),
                ],
              ),
            ),
          ],
        );
    }
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
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.surfaceAlt)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetric('WIDTH', '--'),
          _buildMetric('HEIGHT', '--'),
          _buildMetric('FORMAT', 'JPG/PNG'),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 14,
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
