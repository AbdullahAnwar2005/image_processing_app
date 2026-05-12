enum ImageFilterType {
  grayscale,
  negative,
  sepia,
  posterization,
  rgbAdjustment,
  brightness,
  contrast,
  blur,
  edgeDetection,
  threshold,
  equalization,
  rotate,
  flip,
  scale,
}

enum EdgeDetectorType {
  sobel,
  prewitt,
  roberts,
  laplacian,
}

enum SmoothingType {
  averaging,
  weightedAverage,
  gaussian,
  median,
  min,
  max,
}

enum RotationAngle {
  cw90,
  ccw90,
}

enum FlipDirection {
  horizontal,
  vertical,
}
