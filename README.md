# Image Filters Lab

## Overview
**Image Filters Lab** is a Flutter-based mobile multimedia application built for the **CPIT-380 Multimedia Technologies** course. The app serves as an interactive educational tool where students can experiment with fundamental image processing algorithms. Unlike standard filter apps that use black-box libraries, this lab implements core algorithms (point operations, spatial filtering, geometric transformations) manually at the pixel level to demonstrate the mathematical principles behind digital image manipulation.

## Problem / Objective
Digital image processing concepts—such as convolutions, histograms, and spatial derivatives—can often feel abstract when studied purely through formulas. The objective of this project is to bridge the gap between theory and practice by providing a "live lab" environment. Users can see exactly how changing a kernel weight, a bin count, or a threshold value affects an image in real-time.

## Core Features

### Media Import
- **Image Import**: Load JPG/PNG images from the device gallery.
- **Video Frame Extraction**: Select a video and extract a high-quality still frame (sampled at the 1-second mark) for processing.
- **Unified Pipeline**: Process extracted video frames using the same professional image processing suite as static images.

### Geometry Operations
- **Rotation**: Rotate 90° clockwise or counter-clockwise.
- **Reflection (Flip)**: Horizontal and vertical axis flipping.
- **Scaling**: Manual nearest-neighbor interpolation ($0.5x$ to $2.0x$).

### Color & Intensity Operations
- **Grayscale**: Weighted luminance conversion ($0.299R + 0.587G + 0.114B$).
- **Negative**: Full color inversion ($255 - channel$).
- **Sepia**: Warm-tone matrix transformation.
- **Posterization**: Color quantization into discrete levels ($2$ to $16$).
- **RGB Balancing**: Manual factor adjustment for Red, Green, and Blue channels.
- **Brightness & Contrast**: Linear intensity offset and midpoint scaling.

### Histogram Operations
- **Multi-channel Support**: Visualize RGB and Intensity distributions.
- **Dynamic Binning**: Adjust resolution between 16, 32, 64, and 256 bins.
- **Histogram Equalization**: Contrast enhancement using cumulative distribution functions (CDF).

### Spatial Filtering (Smoothing)
- **Mean Filter**: Simple box average smoothing.
- **Weighted Average**: Center-weighted kernel smoothing (Gaussian-like).
- **Median Filter**: Non-linear noise reduction (Salt-and-Pepper removal).

### Edge Detection & Segmentation
- **First-Order Derivatives**: Sobel, Prewitt, and Roberts operators.
- **Second-Order Derivatives**: Laplacian operator.
- **Binary Thresholding**: Intensity-based segmentation ($0–255$).

### Export
- **High-Quality Save**: Export the final processed result back to the device gallery.

## Non-Destructive Processing Pipeline
The app utilizes a deterministic, non-destructive pipeline. The original source bytes are preserved, and every adjustment re-runs through the sequence to ensure mathematically consistent results:

1. **Dynamic Optimization**: Resizing large images for mobile performance.
2. **Geometry**: Rotation $\rightarrow$ Flip $\rightarrow$ Scale.
3. **Intensity Normalization**: Grayscale $\rightarrow$ Histogram Equalization.
4. **Color Transforms**: Negative $\rightarrow$ Sepia $\rightarrow$ Posterization.
5. **Channel Balancing**: Manual RGB factors.
6. **Intensity Scaling**: Brightness and Contrast.
7. **Spatial Smoothing**: Neighborhood convolution kernels.
8. **Feature Extraction**: Edge Detection or Binary Thresholding.

## Technical Architecture
- **Framework**: Flutter (Dart)
- **Processing**: `image` package for pixel-level access and JPG/PNG encoding.
- **Concurrency**: `Isolate.run` used for all heavy processing to keep the UI responsive.
- **UI Architecture**: Modular widgets with stateful "Active Pipeline" tracking.
- **Key Services**: 
  - `ImageProcessor`: Pipeline orchestration.
  - `ImageAlgorithms`: Pure, tested mathematical implementations.
  - `MediaImportService`: Abstracted gallery and video frame extraction.

## Testing
The core algorithms are validated by a suite of **41 automated tests**.

**Command:**
```powershell
flutter test test/features/image_lab/
```

**Tested Areas:**
- Color operations (Negative, Sepia, Posterization)
- Convolution filters (Weighted Average impulse response)
- Edge detectors (Sobel/Laplacian gradients)
- Histogram Equalization (CDF accuracy)
- Geometric transformations (Rotation cycles/Reflection identity)
- Pipeline integration (Sequential transform consistency)

## Performance & UX
- **Slider Debounce**: $300ms$ delay on sliders to prevent redundant processing.
- **Stale Request Protection**: `requestId` tracking ensures only the latest result is rendered.
- **Active Pipeline Summary**: A compact visual list of all operations currently affecting the image.
- **Categorized Controls**: Progressive disclosure of complex parameters.

## Screenshots
*(Placeholders - Add actual screenshots to /screenshots directory)*
- `[Landing Page]` - Premium entry screen.
- `[Workspace Overview]` - Side-by-side comparison with active pipeline.
- `[Histogram Analysis]` - RGB/Intensity distribution graphs.
- `[Edge Detection]` - Feature extraction using Sobel/Laplacian.
- `[Geometry Transforms]` - Multi-step rotation and flipping.

## Limitations
- **Video Extraction**: Supports extracting a single still frame, not full-length video filtering.
- **Smoothing Kernels**: Blur strength is implemented through repeated $3 \times 3$ passes rather than variable-size kernels (e.g., $5 \times 5$).
- **Histogram Equalization**: Implemented as a grayscale-based operation to align with core course concepts.
- **Resizing**: Very large images are capped at $1600px$ to maintain high performance on mobile devices.

## Future Work
- Full video frame-by-frame filtering and MP4 export.
- Interactive video scrubber for custom frame selection.
- Support for larger kernel sizes ($5 \times 5$, $7 \times 7$).
- Batch processing for multiple images.
- Educational "Matrix Mode" to visualize kernel multiplications in real-time.

## Getting Started
1. Clone the repository.
2. Run `flutter pub get`.
3. Launch on an emulator or real device: `flutter run`.

## Build Release APK
To generate a production-ready APK:
```powershell
flutter build apk --release
```
