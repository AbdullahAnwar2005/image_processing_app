import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MediaImportService {
  static final ImagePicker _picker = ImagePicker();

  /// Picks a standard image from the gallery.
  static Future<Uint8List?> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );
    if (image == null) return null;
    return await image.readAsBytes();
  }

  /// Picks a video and extracts a single still frame as image bytes.
  /// This allows the video frame to be processed by the existing image pipeline.
  static Future<Uint8List?> extractFrameFromVideo() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 10),
    );
    
    if (video == null) return null;

    // Generate a high-quality thumbnail from the 1-second mark of the video
    final Uint8List? frameBytes = await VideoThumbnail.thumbnailData(
      video: video.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 1280, // Course-aligned resolution limit
      quality: 90,
      timeMs: 1000, // 1 second into the video to ensure a valid frame
    );

    return frameBytes;
  }
}
