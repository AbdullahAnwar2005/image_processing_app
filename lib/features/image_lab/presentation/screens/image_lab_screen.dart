import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_processing_app/features/image_lab/theme/app_colors.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/workspace_view.dart';
import '../widgets/full_image_preview.dart';
import '../widgets/concepts_guide_bottom_sheet.dart';
import '../../data/image_processor.dart';
import '../../data/histogram_analyzer.dart';
import '../../data/media_import_service.dart';
import '../../domain/histogram_channel.dart';
import '../../domain/histogram_data.dart';
import '../../domain/filter_defaults.dart';
import '../../domain/image_filter_type.dart';
import '../../domain/geometry_state.dart';

enum PreviewMode { original, processed, compare }

class ImageLabScreen extends StatefulWidget {
  const ImageLabScreen({super.key});

  @override
  State<ImageLabScreen> createState() => _ImageLabScreenState();
}

class _ImageLabScreenState extends State<ImageLabScreen> {
  Uint8List? _selectedImageBytes;
  Uint8List? _processedImageBytes;
  bool _isProcessing = false;

  // Metadata
  int _originalWidth = 0;
  int _originalHeight = 0;
  int _processedWidth = 0;
  int _processedHeight = 0;

  // Performance Optimization
  Timer? _debounceTimer;
  int _lastProcessId = 0;

  // Histogram State
  Map<HistogramChannel, HistogramData>? _histogramByChannel;
  HistogramChannel _selectedHistogramChannel = HistogramChannel.intensity;
  bool _isAnalyzingHistogram = false;
  int _binCount = FilterDefaults.histogramBins;

  PreviewMode _previewMode = PreviewMode.compare;

  // Point Operations State
  double _brightness = FilterDefaults.brightness;
  double _contrast = FilterDefaults.contrast;
  double _threshold = FilterDefaults.threshold;
  int _posterizationLevels = FilterDefaults.posterization.toInt();
  double _redFactor = FilterDefaults.rgbFactor;
  double _greenFactor = FilterDefaults.rgbFactor;
  double _blueFactor = FilterDefaults.rgbFactor;

  // Spatial State
  double _blurRadius = FilterDefaults.blurRadius;
  EdgeDetectorType _edgeDetectorType = EdgeDetectorType.sobel;
  SmoothingType _smoothingType = SmoothingType.gaussian;

  // Geometric State (Stateful)
  GeometryState _geometry = const GeometryState();

  final Set<String> _selectedFilters = {};

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  bool get _hasActiveProcessing {
    if (_selectedFilters.isNotEmpty) return true;
    if (_brightness != FilterDefaults.brightness) return true;
    if (_contrast != FilterDefaults.contrast) return true;
    if (_threshold != FilterDefaults.threshold) return true;
    if (_selectedFilters.contains('Posterize')) return true;
    if (_redFactor != FilterDefaults.rgbFactor) return true;
    if (_greenFactor != FilterDefaults.rgbFactor) return true;
    if (_blueFactor != FilterDefaults.rgbFactor) return true;
    if (_blurRadius > FilterDefaults.blurRadius) return true;
    if (!_geometry.isIdentity) return true;
    return false;
  }

  List<String> get _activeFilterList {
    final list = <String>[];
    if (!_geometry.isIdentity) {
      if (_geometry.rotationQuarterTurns != 0) {
        list.add('Rotate ${(_geometry.rotationQuarterTurns * 90) % 360}°');
      }
      if (_geometry.flipHorizontal) list.add('Flip H');
      if (_geometry.flipVertical) list.add('Flip V');
      if (_geometry.scaleFactor != 1.0)
        list.add('${_geometry.scaleFactor}x Scale');
    }

    for (final filter in _selectedFilters) {
      if (filter == 'Edges') {
        list.add('Edge (${_edgeDetectorType.name.toUpperCase()})');
      } else if (filter == 'Blur') {
        list.add('Blur (${_smoothingType.name.toUpperCase()})');
      } else if (filter == 'RGB Adjustment') {
        list.add('RGB Balancing');
      } else {
        list.add(filter);
      }
    }

    if (_brightness != FilterDefaults.brightness) list.add('Brightness');
    if (_contrast != FilterDefaults.contrast) list.add('Contrast');
    if (_threshold != FilterDefaults.threshold && _selectedFilters.contains('Threshold')) list.add('Threshold');

    return list;
  }

  Future<void> _handleImport(bool isVideo) async {
    setState(() => _isProcessing = true);
    try {
      final bytes = isVideo
          ? await MediaImportService.extractFrameFromVideo()
          : await MediaImportService.pickImage();

      if (bytes == null) {
        setState(() => _isProcessing = false);
        return;
      }

      final dims = await ImageProcessor.getDimensions(bytes);

      setState(() {
        _selectedImageBytes = bytes;
        _processedImageBytes = bytes;
        _originalWidth = dims.$1;
        _originalHeight = dims.$2;
        _processedWidth = dims.$1;
        _processedHeight = dims.$2;
        _isProcessing = false;
        _resetParams();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isVideo
                  ? 'Video frame extracted successfully.'
                  : 'Image imported successfully.',
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      await _analyzeCurrentHistogram();
    } catch (e) {
      debugPrint('Import error: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isVideo
                  ? 'Could not extract frame from video.'
                  : 'Could not import image.',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _resetParams() {
    _selectedFilters.clear();
    _brightness = FilterDefaults.brightness;
    _contrast = FilterDefaults.contrast;
    _threshold = FilterDefaults.threshold;
    _posterizationLevels = FilterDefaults.posterization.toInt();
    _redFactor = FilterDefaults.rgbFactor;
    _greenFactor = FilterDefaults.rgbFactor;
    _blueFactor = FilterDefaults.rgbFactor;
    _blurRadius = FilterDefaults.blurRadius;
    _edgeDetectorType = EdgeDetectorType.sobel;
    _smoothingType = SmoothingType.gaussian;
    _geometry = const GeometryState();
  }

  void _resetImage() {
    setState(() {
      _selectedImageBytes = null;
      _processedImageBytes = null;
      _originalWidth = 0;
      _originalHeight = 0;
      _processedWidth = 0;
      _processedHeight = 0;
      _isProcessing = false;
      _histogramByChannel = null;
      _resetParams();
    });
  }

  void _resetAllFilters() {
    setState(() {
      _resetParams();
      // Keep _selectedImageBytes but revert processed view to match original
      _processedImageBytes = _selectedImageBytes;
      _processedWidth = _originalWidth;
      _processedHeight = _originalHeight;
      _isProcessing = false;
    });
    // Histogram should also reflect the original state
    _analyzeCurrentHistogram();
  }

  Future<void> _handleResetAll() async {
    if (!_hasActiveProcessing) return;

    final bool? shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Filters?'),
        content: const Text('This will discard all current changes and restore the original image.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (shouldReset == true) {
      _resetAllFilters();
    }
  }

  Future<void> _handleBack() async {
    if (!_hasActiveProcessing) {
      _resetImage();
      return;
    }

    final bool? shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Session?'),
        content: const Text('All active filters and adjustments will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (shouldDiscard == true) {
      _resetImage();
    }
  }

  Future<void> _analyzeCurrentHistogram() async {
    final bytes = _processedImageBytes ?? _selectedImageBytes;
    if (bytes == null) return;
    setState(() => _isAnalyzingHistogram = true);
    try {
      final result = await HistogramAnalyzer.analyze(bytes);
      if (mounted) {
        setState(() {
          _histogramByChannel = result;
          _isAnalyzingHistogram = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isAnalyzingHistogram = false);
    }
  }

  Future<void> _exportImage() async {
    final bytes = _processedImageBytes ?? _selectedImageBytes;
    if (bytes == null) return;
    setState(() => _isProcessing = true);
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) await Gal.requestAccess();
      final directory = await getTemporaryDirectory();
      final String filePath =
          '${directory.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File file = File(filePath);
      await file.writeAsBytes(bytes);
      await Gal.putImage(filePath);
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exported successfully to gallery!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to export image. Check permissions.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _triggerReprocessDebounced() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), _reprocessImage);
  }

  Future<void> _reprocessImage() async {
    if (_selectedImageBytes == null) return;

    final currentId = ++_lastProcessId;

    if (!_hasActiveProcessing) {
      setState(() {
        _processedImageBytes = _selectedImageBytes;
        _processedWidth = _originalWidth;
        _processedHeight = _originalHeight;
        _isProcessing = false;
      });
      await _analyzeCurrentHistogram();
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final result = await ImageProcessor.processImage(
        originalBytes: _selectedImageBytes!,
        grayscale: _selectedFilters.contains('Grayscale'),
        negative: _selectedFilters.contains('Negative'),
        sepia: _selectedFilters.contains('Sepia'),
        rgbAdjustment: _selectedFilters.contains('RGB Adjustment'),
        posterizationLevels: _selectedFilters.contains('Posterize')
            ? _posterizationLevels
            : 0,
        redFactor: _redFactor,
        greenFactor: _greenFactor,
        blueFactor: _blueFactor,
        brightness: _brightness,
        contrast: _contrast,
        blurRadius: _blurRadius,
        edgeDetection: _selectedFilters.contains('Edges'),
        edgeType: _edgeDetectorType,
        smoothingType: _smoothingType,
        threshold: _threshold,
        useThreshold: _selectedFilters.contains('Threshold'),
        equalization: _selectedFilters.contains('Equalization'),
        geometry: _geometry,
      );

      if (mounted && currentId == _lastProcessId) {
        setState(() {
          _processedImageBytes = result.bytes;
          _processedWidth = result.width;
          _processedHeight = result.height;
          _isProcessing = false;
        });
        await _analyzeCurrentHistogram();
      }
    } catch (e) {
      if (mounted && currentId == _lastProcessId) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Processing error. Image may be too large or corrupted.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _onFilterToggled(String filter) async {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        _selectedFilters.remove(filter);
      } else {
        _selectedFilters.add(filter);
      }
    });
    await _reprocessImage();
  }

  void _showAbout() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Image Filters Lab',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'A Flutter mobile multimedia application.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This app helps students explore image processing concepts through interactive, pixel-level operations including color manipulation, histogram analysis, spatial filtering, edge detection, and geometric transformations.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(
                  Icons.terminal_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 8),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Spacer(),
                Text(
                  'Built with Flutter & Dart',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ConceptsGuideBottomSheet.show(context);
                },
                icon: const Icon(Icons.help_outline),
                label: const Text('Concepts Guide'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _selectedImageBytes != null
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                onPressed: _handleBack,
              ),
              title: const Text(
                'Workspace',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.help_outline,
                    color: AppColors.primary,
                  ),
                  onPressed: () => ConceptsGuideBottomSheet.show(context),
                ),
              ],
            )
          : null,
      body: _selectedImageBytes == null
          ? EmptyStateView(
              onPickImage: () => _handleImport(false),
              onExtractVideoFrame: () => _handleImport(true),
              onShowAbout: _showAbout,
            )
          : WorkspaceView(
              selectedImageBytes: _selectedImageBytes!,
              processedImageBytes: _processedImageBytes ?? _selectedImageBytes!,
              isProcessing: _isProcessing,
              previewMode: _previewMode,
              originalWidth: _originalWidth,
              originalHeight: _originalHeight,
              processedWidth: _processedWidth,
              processedHeight: _processedHeight,
              brightness: _brightness,
              contrast: _contrast,
              blurRadius: _blurRadius,
              threshold: _threshold,
              posterizationLevels: _posterizationLevels,
              redFactor: _redFactor,
              greenFactor: _greenFactor,
              blueFactor: _blueFactor,
              binCount: _binCount,
              edgeDetectorType: _edgeDetectorType,
              smoothingType: _smoothingType,
              geometry: _geometry,
              selectedFilters: _selectedFilters,
              activeFilters: _activeFilterList,
              histogramByChannel: _histogramByChannel,
              selectedHistogramChannel: _selectedHistogramChannel,
              isAnalyzingHistogram: _isAnalyzingHistogram,
              onHistogramChannelChanged: (c) =>
                  setState(() => _selectedHistogramChannel = c),
              onBinCountChanged: (b) => setState(() => _binCount = b),
              onPreviewModeChanged: (m) => setState(() => _previewMode = m),
              onFilterToggled: _onFilterToggled,
              onEdgeTypeChanged: (t) {
                setState(() => _edgeDetectorType = t);
                _reprocessImage();
              },
              onSmoothingTypeChanged: (t) {
                setState(() => _smoothingType = t);
                _reprocessImage();
              },
              onBrightnessChanged: (v) {
                setState(() => _brightness = v);
                _triggerReprocessDebounced();
              },
              onContrastChanged: (v) {
                setState(() => _contrast = v);
                _triggerReprocessDebounced();
              },
              onBlurRadiusChanged: (v) {
                setState(() => _blurRadius = v);
                _triggerReprocessDebounced();
              },
              onThresholdChanged: (v) {
                setState(() => _threshold = v);
                _triggerReprocessDebounced();
              },
              onPosterizationChanged: (v) {
                setState(() => _posterizationLevels = v);
                _reprocessImage();
              },
              onRedFactorChanged: (v) {
                setState(() => _redFactor = v);
                _triggerReprocessDebounced();
              },
              onGreenFactorChanged: (v) {
                setState(() => _greenFactor = v);
                _triggerReprocessDebounced();
              },
              onBlueFactorChanged: (v) {
                setState(() => _blueFactor = v);
                _triggerReprocessDebounced();
              },
              onRotateRight: () {
                setState(() => _geometry = _geometry.rotateRight());
                _reprocessImage();
              },
              onRotateLeft: () {
                setState(() => _geometry = _geometry.rotateLeft());
                _reprocessImage();
              },
              onToggleFlipH: () {
                setState(() => _geometry = _geometry.toggleFlipHorizontal());
                _reprocessImage();
              },
              onToggleFlipV: () {
                setState(() => _geometry = _geometry.toggleFlipVertical());
                _reprocessImage();
              },
              onScaleFactorChanged: (s) {
                setState(() => _geometry = _geometry.copyWith(scaleFactor: s));
                _reprocessImage();
              },
              onResetBrightness: () {
                setState(() => _brightness = FilterDefaults.brightness);
                _reprocessImage();
              },
              onResetContrast: () {
                setState(() => _contrast = FilterDefaults.contrast);
                _reprocessImage();
              },
              onResetRGB: () {
                setState(() {
                  _redFactor = FilterDefaults.rgbFactor;
                  _greenFactor = FilterDefaults.rgbFactor;
                  _blueFactor = FilterDefaults.rgbFactor;
                });
                _reprocessImage();
              },
              onResetBlur: () {
                setState(() => _blurRadius = FilterDefaults.blurRadius);
                _reprocessImage();
              },
              onResetThreshold: () {
                setState(() => _threshold = FilterDefaults.threshold);
                _reprocessImage();
              },
              onResetPosterization: () {
                setState(() => _posterizationLevels = FilterDefaults.posterization.toInt());
                _reprocessImage();
              },
              onResetGeometry: () {
                setState(() => _geometry = const GeometryState());
                _reprocessImage();
              },
              onResetHistogram: () {
                setState(() {
                  _binCount = FilterDefaults.histogramBins;
                  _selectedHistogramChannel = HistogramChannel.intensity;
                });
              },
              onProcessingEnd: _reprocessImage,
              onReset: _handleResetAll,
              onExport: _exportImage,
              onImagePressed: (b, t) => Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (_, __, ___) =>
                      FullImagePreview(imageBytes: b, heroTag: t),
                ),
              ),
            ),
    );
  }
}
