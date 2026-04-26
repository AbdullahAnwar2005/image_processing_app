import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_processing_app/features/image_lab/theme/app_colors.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/workspace_view.dart';
import '../widgets/full_image_preview.dart';
import '../../data/image_processor.dart';
import '../../data/histogram_analyzer.dart';
import '../../domain/histogram_channel.dart';
import '../../domain/histogram_data.dart';
import '../../domain/filter_defaults.dart';

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
  double _brightness = FilterDefaults.brightness;
  double _contrast = FilterDefaults.contrast;
  double _blurRadius = FilterDefaults.blurRadius;
  final Set<String> _selectedFilters = {};

  final ImagePicker _picker = ImagePicker();

  bool get _hasActiveProcessing {
    if (_selectedFilters.contains('Edge Detection')) return true;
    if (_selectedFilters.contains('Grayscale')) return true;
    if (_brightness != FilterDefaults.brightness) return true;
    if (_contrast != FilterDefaults.contrast) return true;
    if (_blurRadius > FilterDefaults.blurRadius) return true;
    return false;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return; // User cancelled

      final Uint8List bytes = await image.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _processedImageBytes = bytes;
        _selectedFilters.clear();
        _brightness = FilterDefaults.brightness;
        _contrast = FilterDefaults.contrast;
        _blurRadius = FilterDefaults.blurRadius;
      });
      await _analyzeCurrentHistogram();
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load this image.')),
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
      _brightness = FilterDefaults.brightness;
      _contrast = FilterDefaults.contrast;
      _blurRadius = FilterDefaults.blurRadius;
      _selectedFilters.clear();
    });
  }

  void _onPreviewModeChanged(PreviewMode mode) {
    setState(() {
      _previewMode = mode;
    });
  }

  void _showFullPreview(Uint8List bytes, String heroTag) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.9),
        pageBuilder: (context, animation, secondaryAnimation) => FullImagePreview(
          imageBytes: bytes,
          heroTag: heroTag,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
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
      debugPrint('Histogram analysis error: $e');
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

  Future<void> _exportImage() async {
    final bytes = _processedImageBytes ?? _selectedImageBytes;
    if (bytes == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          throw Exception('Gallery access denied.');
        }
      }

      final directory = await getTemporaryDirectory();
      final String filePath = '${directory.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File file = File(filePath);
      await file.writeAsBytes(bytes);

      await Gal.putImage(filePath);

      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image exported successfully to gallery!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Export error: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not export image.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _reprocessImage() async {
    if (_selectedImageBytes == null) return;

    if (!_hasActiveProcessing) {
      setState(() {
        _processedImageBytes = _selectedImageBytes;
        _isProcessing = false;
      });
      await _analyzeCurrentHistogram();
      return;
    }

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
        edgeDetection: _selectedFilters.contains('Edge Detection'),
      );

      if (mounted) {
        setState(() {
          _processedImageBytes = processed;
          _isProcessing = false;
        });
        await _analyzeCurrentHistogram();
      }
    } catch (e) {
      debugPrint('Processing error: $e');
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
    if (filter == 'Grayscale' || filter == 'Edge Detection') {
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
        if (_blurRadius > FilterDefaults.blurRadius) {
          _blurRadius = FilterDefaults.blurRadius;
          _selectedFilters.remove('Blur');
        } else {
          _blurRadius = 3.0; // Sprint requirement: set to 3 if neutral
          _selectedFilters.add('Blur');
        }
      });
      await _reprocessImage();
    } else if (filter == 'Brightness') {
      setState(() {
        if (_brightness != FilterDefaults.brightness) {
          _brightness = FilterDefaults.brightness;
          _selectedFilters.remove('Brightness');
        } else {
          _brightness = 60.0; // Set to 60 (slight brighten) if neutral
          _selectedFilters.add('Brightness');
        }
      });
      await _reprocessImage();
    } else if (filter == 'Contrast') {
      setState(() {
        if (_contrast != FilterDefaults.contrast) {
          _contrast = FilterDefaults.contrast;
          _selectedFilters.remove('Contrast');
        } else {
          _contrast = 1.2; // Sprint requirement: set to 1.2 if neutral
          _selectedFilters.add('Contrast');
        }
      });
      await _reprocessImage();
    } else {
      // Other filters (visual only/not implemented)
      setState(() {
        if (_selectedFilters.contains(filter)) {
          _selectedFilters.remove(filter);
        } else {
          _selectedFilters.add(filter);
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
              onBrightnessChanged: (val) {
                setState(() {
                  _brightness = val;
                  if (_brightness != FilterDefaults.brightness) {
                    _selectedFilters.add('Brightness');
                  } else {
                    _selectedFilters.remove('Brightness');
                  }
                });
              },
              onContrastChanged: (val) {
                setState(() {
                  _contrast = val;
                  if (_contrast != FilterDefaults.contrast) {
                    _selectedFilters.add('Contrast');
                  } else {
                    _selectedFilters.remove('Contrast');
                  }
                });
              },
              onBlurRadiusChanged: (val) {
                setState(() {
                  _blurRadius = val;
                  if (_blurRadius > FilterDefaults.blurRadius) {
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
              onExport: _exportImage,
              onImagePressed: _showFullPreview,
            ),
    );
  }
}
