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

  // Performance Optimization
  Timer? _debounceTimer;
  int _lastProcessId = 0;

  // Histogram State
  Map<HistogramChannel, HistogramData>? _histogramByChannel;
  HistogramChannel _selectedHistogramChannel = HistogramChannel.intensity;
  bool _isAnalyzingHistogram = false;
  int _binCount = 32;

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
    if (_posterizationLevels != FilterDefaults.posterization.toInt())
      return true;
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
      } else {
        list.add(filter);
      }
    }

    if (_brightness != FilterDefaults.brightness) list.add('Brightness');
    if (_contrast != FilterDefaults.contrast) list.add('Contrast');
    if (_posterizationLevels != 0) list.add('Posterize');
    if (_redFactor != 1.0 || _greenFactor != 1.0 || _blueFactor != 1.0)
      list.add('RGB Balancing');

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

      setState(() {
        _selectedImageBytes = bytes;
        _processedImageBytes = bytes;
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
      _isProcessing = false;
      _histogramByChannel = null;
      _resetParams();
    });
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
        _isProcessing = false;
      });
      await _analyzeCurrentHistogram();
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final processed = await ImageProcessor.processImage(
        originalBytes: _selectedImageBytes!,
        grayscale: _selectedFilters.contains('Grayscale'),
        negative: _selectedFilters.contains('Negative'),
        sepia: _selectedFilters.contains('Sepia'),
        posterizationLevels: _posterizationLevels,
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
          _processedImageBytes = processed;
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
    showAboutDialog(
      context: context,
      applicationName: 'Image Filters Lab',
      applicationVersion: '1.0.0',

      // applicationIcon: const Icon(Icons.auto_awesome, size: 40, color: AppColors.primary), ///Todo: put the original luncher icon for the app that you'll design
      children: [
        const SizedBox(height: 12),
        const Text(
          'This mobile application demonstrates manual image processing algorithms including point operations, spatial filtering, histogram equalization, and geometric transformations.',
        ),
        const SizedBox(height: 8),
        const Text(
          '• Video Support: Extracts one frame for processing.\n'
          '• Optimization: Resizes large images for performance.\n'
          '• Non-destructive: Original image remains preserved.',
          style: TextStyle(fontSize: 12, height: 1.5),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _selectedImageBytes != null
          ? AppBar(
              title: const Text(
                'Workspace',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                  ),
                  onPressed: _showAbout,
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
              onProcessingEnd: _reprocessImage,
              onReset: _resetImage,
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
