import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_processing_app/features/image_lab/theme/app_colors.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/workspace_view.dart';

enum PreviewMode { original, processed, compare }

class ImageLabScreen extends StatefulWidget {
  const ImageLabScreen({super.key});

  @override
  State<ImageLabScreen> createState() => _ImageLabScreenState();
}

class _ImageLabScreenState extends State<ImageLabScreen> {
  Uint8List? _selectedImageBytes;
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
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  void _resetImage() {
    setState(() {
      _selectedImageBytes = null;
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

  void _onFilterToggled(String filter) {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        _selectedFilters.remove(filter);
      } else {
        _selectedFilters.add(filter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _selectedImageBytes == null
          ? EmptyStateView(onPickImage: _pickImage)
          : WorkspaceView(
              selectedImageBytes: _selectedImageBytes!,
              previewMode: _previewMode,
              brightness: _brightness,
              contrast: _contrast,
              blurRadius: _blurRadius,
              selectedFilters: _selectedFilters,
              onPreviewModeChanged: _onPreviewModeChanged,
              onFilterToggled: _onFilterToggled,
              onBrightnessChanged: (val) => setState(() => _brightness = val),
              onContrastChanged: (val) => setState(() => _contrast = val),
              onBlurRadiusChanged: (val) => setState(() => _blurRadius = val),
              onReset: _resetImage,
            ),
    );
  }
}
