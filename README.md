# Image Filters Lab

Image Filters Lab is a Flutter mobile application designed for experimenting with basic image processing operations through an interactive and intuitive mobile workspace. It serves as an educational tool and a portfolio project to demonstrate pixel-level image manipulation in a mobile environment.

## Overview
The application provides a "lab" environment where users can load images from their device gallery and apply a variety of filters in real-time. It features a non-destructive processing pipeline that allows for instant comparison between the original and processed outputs, along with deep technical insights provided by a real-time RGB histogram and statistical analysis.

## Features
- **Image Picking**: Seamlessly load images from your device's gallery.
- **Dynamic Previews**: Toggle between Original, Processed, and Side-by-Side Compare modes.
- **Grayscale Conversion**: Real-time luma-based desaturation.
- **Brightness & Contrast**: High-performance color adjustments with calibrated ranges.
- **Gaussian Blur**: Smooth convolutional blur with adjustable radius.
- **Sobel Edge Detection**: Mathematical edge detection using horizontal and vertical gradient kernels.
- **RGB Histogram**: Visual distribution of pixel intensities across Red, Green, and Blue channels.
- **Scientific Statistics**: Real-time calculation of Mean, Standard Deviation, and Shannon Entropy.
- **Performance Optimized**: Automatic resizing for large images and background processing using Dart Isolates.
- **Interactive Preview**: Tap any image for a full-screen, pinch-to-zoom view with Hero animations.

## Tech Stack
- **Framework**: Flutter
- **Language**: Dart
- **Design System**: Material 3 (Native Implementation)
- **Image Processing**: `image` package
- **Data Visualization**: `fl_chart`
- **Native Interop**: `image_picker`, `gal`, `path_provider`

## Screenshots

| Empty State | Workspace |
|---|---|
| ![Empty State](screenshots/empty_state.png) | ![Workspace](screenshots/workspace.png) |

| Compare Mode | Edge Detection |
|---|---|
| ![Compare Mode](screenshots/compare_mode.png) | ![Edge Detection](screenshots/edge_detection.png) |

## Image Processing Pipeline
The app utilizes a robust, non-destructive processing pipeline to ensure quality and stability:
1. **Decode**: The selected image bytes are decoded into a memory buffer.
2. **Rescale**: Large images (>1600px) are safely resized while preserving aspect ratio to maintain high performance.
3. **Filter Chain**: Operations (Grayscale, Brightness, Blur, etc.) are applied sequentially starting from the **original** source to prevent cumulative quality loss.
4. **Edge Branch**: Sobel detection utilizes a specialized grayscale gradient pipeline for maximum clarity.
5. **Analyze**: The final processed bytes are sent to a background isolate for histogram calculation and statistical analysis.

**Core Rule**: The original image bytes remain entirely untouched throughout the session.

## Histogram and Statistics
To provide a deeper understanding of the image data, the app calculates:
- **Histogram**: A bar chart representing the frequency of 256 intensity levels (grouped into 32 bins for clarity).
- **Mean**: The average intensity of the selected color channel.
- **Standard Deviation**: Measures the "spread" or contrast of the intensity distribution.
- **Entropy**: Uses Shannon Entropy to measure the complexity and information density of the image data.

## Project Structure
```
lib/
  features/
    image_lab/
      data/         # Heavy lifting: ImageProcessor and HistogramAnalyzer
      domain/       # Data models, enums, and filter default constants
      presentation/ # UI Layer: Responsive screens and modular widgets
      theme/        # Design system: App-wide colors, spacing, and shadows
```

## What I Learned
- **UI Translation**: Converting a complex "Figma Make" design into a responsive, pixel-perfect Flutter implementation.
- **Byte-Level Logic**: Working directly with `Uint8List` and the `image` library for manual pixel manipulation.
- **Computer Vision Basics**: Implementing the Sobel operator kernel for mathematical edge detection.
- **Concurrency**: Managing heavy computational tasks using `Isolate.run` to keep the UI at 60 FPS.
- **Data Visualization**: Customizing `fl_chart` to display technical scientific data.

## Getting Started
Ensure you have the Flutter SDK installed on your machine.

1. Clone this repository.
2. Run `flutter pub get` to install dependencies.
3. Run `flutter run` to launch the app on your connected device or emulator.

## Status
This project is a technical portfolio piece. While core processing is complete, export functionality and additional filter kernels (like Sharpen or Emboss) are candidates for future updates.
