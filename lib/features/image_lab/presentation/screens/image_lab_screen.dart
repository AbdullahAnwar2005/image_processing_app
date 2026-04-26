import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_processing_app/features/image_lab/theme/app_colors.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/workspace_view.dart';
import '../../data/image_processor.dart';
import '../../data/histogram_analyzer.dart';
import '../../domain/histogram_channel.dart';
import '../../domain/histogram_data.dart';

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

  // Histogram State
  Map<HistogramChannel, HistogramData>? _histogramByChannel;
  HistogramChannel _selectedHistogramChannel = HistogramChannel.red;
  bool _isAnalyzingHistogram = false;
  
  PreviewMode _previewMode = PreviewMode.compare;
  double _brightness = 0;
  double _contrast = 1.0;
  double _blurRadius = 0;
  final Set<String> _selectedFilters = {};

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final Uint8List bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _processedImageBytes = bytes;
          _selectedFilters.clear();
          _brightness = 0;
          _contrast = 1.0;
          _blurRadius = 0;
        });
        await _analyzeCurrentHistogram();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _resetImage() {
    setState(() {
      _selectedImageBytes = null;
      _processedImageBytes = null;
      _isProcessing = false;
      _histogramByChannel = null;
      _isAnalyzingHistogram = false;
      _previewMode = PreviewMode.compare;
      _brightness = 0;
      _contrast = 1.0;
      _blurRadius = 0;
      _selectedFilters.clear();
    });
  }

  void _onPreviewModeChanged(PreviewMode mode) {
    setState(() {
      _previewMode = mode;
    });
  }

  Future<void> _analyzeCurrentHistogram() async {
    final bytes = _processedImageBytes ?? _selectedImageBytes;
    if (bytes == null) return;

    setState(() {
      _isAnalyzingHistogram = true;
    });

    try {
      final result = await HistogramAnalyzer.analyze(bytes);
      if (mounted) {
        setState(() {
          _histogramByChannel = result;
          _isAnalyzingHistogram = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzingHistogram = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not analyze image histogram.')),
        );
      }
    }
  }

  Future<void> _reprocessImage() async {
    if (_selectedImageBytes == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final processed = await ImageProcessor.processImage(
        originalBytes: _selectedImageBytes!,
        grayscale: _selectedFilters.contains('Grayscale'),
        brightness: _brightness,
        contrast: _contrast,
        blurRadius: _blurRadius,
      );

      if (mounted) {
        setState(() {
          _processedImageBytes = processed;
          _isProcessing = false;
        });
        await _analyzeCurrentHistogram();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processedImageBytes = _selectedImageBytes;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not process this image.')),
        );
      }
    }
  }

  Future<void> _onFilterToggled(String filter) async {
    if (filter == 'Grayscale') {
      setState(() {
        if (_selectedFilters.contains(filter)) {
          _selectedFilters.remove(filter);
        } else {
          _selectedFilters.add(filter);
        }
      });
      await _reprocessImage();
    } else if (filter == 'Blur') {
      setState(() {
        if (_selectedFilters.contains(filter)) {
          _selectedFilters.remove(filter);
          _blurRadius = 0;
        } else {
          _selectedFilters.add(filter);
          if (_blurRadius == 0) _blurRadius = 3;
        }
      });
      await _reprocessImage();
    } else if (filter == 'Brightness' || filter == 'Contrast') {
      // Visual toggle only for now as per Sprint 4 requirements
      setState(() {
        if (_selectedFilters.contains(filter)) {
          _selectedFilters.remove(filter);
        } else {
          _selectedFilters.add(filter);
        }
      });
    } else {
      // Edge Detection not yet implemented
      setState(() {
        if (_selectedFilters.contains(filter)) {
          _selectedFilters.remove(filter);
        } else {
          _selectedFilters.add(filter);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This filter will be implemented in a later sprint.'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _selectedImageBytes == null
          ? EmptyStateView(onPickImage: _pickImage)
          : WorkspaceView(
              selectedImageBytes: _selectedImageBytes!,
              processedImageBytes: _processedImageBytes ?? _selectedImageBytes!,
              isProcessing: _isProcessing,
              previewMode: _previewMode,
              brightness: _brightness,
              contrast: _contrast,
              blurRadius: _blurRadius,
              selectedFilters: _selectedFilters,
              histogramByChannel: _histogramByChannel,
              selectedHistogramChannel: _selectedHistogramChannel,
              isAnalyzingHistogram: _isAnalyzingHistogram,
              onHistogramChannelChanged: (channel) {
                setState(() => _selectedHistogramChannel = channel);
              },
              onPreviewModeChanged: _onPreviewModeChanged,
              onFilterToggled: _onFilterToggled,
              onBrightnessChanged: (val) => setState(() => _brightness = val),
              onContrastChanged: (val) => setState(() => _contrast = val),
              onBlurRadiusChanged: (val) {
                setState(() {
                  _blurRadius = val;
                  if (_blurRadius > 0) {
                    _selectedFilters.add('Blur');
                  } else {
                    _selectedFilters.remove('Blur');
                  }
                });
              },
              onBrightnessChangeEnd: (val) => _reprocessImage(),
              onContrastChangeEnd: (val) => _reprocessImage(),
              onBlurRadiusChangeEnd: (val) => _reprocessImage(),
              onReset: _resetImage,
            ),
    );
  }
}
