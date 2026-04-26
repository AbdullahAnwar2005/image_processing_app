import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:ui';

class FullImagePreview extends StatelessWidget {
  final Uint8List imageBytes;
  final String heroTag;

  const FullImagePreview({
    super.key,
    required this.imageBytes,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            // Blurred Background
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  color: Colors.black.withOpacity(0.85),
                ),
              ),
            ),
            
            // Close Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
              ),
            ),

            // The Image
            Center(
              child: Hero(
                tag: heroTag,
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            
            // Instruction Tip
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pinch to zoom • Tap to close',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
