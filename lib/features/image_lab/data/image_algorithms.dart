import 'dart:math' as math;
import 'package:image/image.dart' as img;
import '../domain/image_filter_type.dart';
import '../domain/geometry_state.dart';

class ImageAlgorithms {
  static int clampChannel(num value) {
    return value.round().clamp(0, 255);
  }

  static int clampCoordinate(int value, int min, int max) {
    return value.clamp(min, max);
  }

  static img.Image applyManualGrayscale(img.Image src) {
    for (final pixel in src) {
      final gray = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b).round();
      pixel.r = gray;
      pixel.g = gray;
      pixel.b = gray;
    }
    return src;
  }

  static img.Image applyBrightnessContrast(
    img.Image src,
    double brightness,
    double contrast,
  ) {
    if (brightness == 50 && contrast == 1.0) return src;
    final double offset = (brightness - 50) * 4.0;
    final double factor = contrast;
    for (final pixel in src) {
      pixel.r = clampChannel((pixel.r - 128) * factor + 128 + offset);
      pixel.g = clampChannel((pixel.g - 128) * factor + 128 + offset);
      pixel.b = clampChannel((pixel.b - 128) * factor + 128 + offset);
    }
    return src;
  }

  static img.Image applyThreshold(img.Image src, double threshold) {
    for (final pixel in src) {
      final intensity = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b).round();
      final val = intensity >= threshold ? 255 : 0;
      pixel.r = val;
      pixel.g = val;
      pixel.b = val;
    }
    return src;
  }

  static img.Image applyConvolution3x3(
    img.Image src, {
    required List<List<num>> kernel,
    num divisor = 1,
    num offset = 0,
    bool useAbs = false,
  }) {
    final width = src.width;
    final height = src.height;
    final dest = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        double rSum = 0, gSum = 0, bSum = 0;
        for (int ky = 0; ky < 3; ky++) {
          for (int kx = 0; kx < 3; kx++) {
            final int nx = clampCoordinate(x + kx - 1, 0, width - 1);
            final int ny = clampCoordinate(y + ky - 1, 0, height - 1);
            final pixel = src.getPixel(nx, ny);
            final weight = kernel[ky][kx];
            rSum += pixel.r * weight;
            gSum += pixel.g * weight;
            bSum += pixel.b * weight;
          }
        }
        final rFinal = rSum / divisor + offset;
        final gFinal = gSum / divisor + offset;
        final bFinal = bSum / divisor + offset;
        dest.setPixelRgb(
          x, y,
          clampChannel(useAbs ? rFinal.abs() : rFinal),
          clampChannel(useAbs ? gFinal.abs() : gFinal),
          clampChannel(useAbs ? bFinal.abs() : bFinal),
        );
      }
    }
    return dest;
  }

  static img.Image applyBlur(img.Image src, double radius, SmoothingType type) {
    if (radius <= 0) return src;
    
    final int passes = radius.round().clamp(1, 10);
    img.Image result = src;

    for (int i = 0; i < passes; i++) {
      switch (type) {
        case SmoothingType.averaging:
          result = applyConvolution3x3(result, kernel: [[1,1,1],[1,1,1],[1,1,1]], divisor: 9);
          break;
        case SmoothingType.weightedAverage:
        case SmoothingType.gaussian:
          result = applyConvolution3x3(result, kernel: [[1,2,1],[2,4,2],[1,2,1]], divisor: 16);
          break;
        case SmoothingType.median:
          result = applyMedianFilter3x3(result);
          break;
        case SmoothingType.min:
          result = applyMinFilter3x3(result);
          break;
        case SmoothingType.max:
          result = applyMaxFilter3x3(result);
          break;
      }
    }
    return result;
  }

  static img.Image applyMedianFilter3x3(img.Image src) {
    final width = src.width;
    final height = src.height;
    final dest = img.Image(width: width, height: height);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final List<int> rVal = [], gVal = [], bVal = [];
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            final nx = clampCoordinate(x + kx, 0, width - 1);
            final ny = clampCoordinate(y + ky, 0, height - 1);
            final pixel = src.getPixel(nx, ny);
            rVal.add(pixel.r.toInt());
            gVal.add(pixel.g.toInt());
            bVal.add(pixel.b.toInt());
          }
        }
        rVal.sort(); gVal.sort(); bVal.sort();
        dest.setPixelRgb(x, y, rVal[4], gVal[4], bVal[4]);
      }
    }
    return dest;
  }

  static img.Image applyMinFilter3x3(img.Image src) {
    final width = src.width, height = src.height;
    final dest = img.Image(width: width, height: height);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int rM = 255, gM = 255, bM = 255;
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            final nx = clampCoordinate(x + kx, 0, width - 1);
            final ny = clampCoordinate(y + ky, 0, height - 1);
            final p = src.getPixel(nx, ny);
            rM = math.min(rM, p.r.toInt());
            gM = math.min(gM, p.g.toInt());
            bM = math.min(bM, p.b.toInt());
          }
        }
        dest.setPixelRgb(x, y, rM, gM, bM);
      }
    }
    return dest;
  }

  static img.Image applyMaxFilter3x3(img.Image src) {
    final width = src.width, height = src.height;
    final dest = img.Image(width: width, height: height);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int rM = 0, gM = 0, bM = 0;
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            final nx = clampCoordinate(x + kx, 0, width - 1);
            final ny = clampCoordinate(y + ky, 0, height - 1);
            final p = src.getPixel(nx, ny);
            rM = math.max(rM, p.r.toInt());
            gM = math.max(gM, p.g.toInt());
            bM = math.max(bM, p.b.toInt());
          }
        }
        dest.setPixelRgb(x, y, rM, gM, bM);
      }
    }
    return dest;
  }

  static img.Image applyEdgeDetection(img.Image src, EdgeDetectorType type) {
    if (type == EdgeDetectorType.roberts) return _applyRobertsEdgeDetection(src);
    if (type == EdgeDetectorType.laplacian) return _applyLaplacianEdgeDetection(src);

    final width = src.width, height = src.height;
    final dest = img.Image(width: width, height: height);
    final List<List<num>> kX, kY;

    if (type == EdgeDetectorType.sobel) {
      kX = [[-1,0,1],[-2,0,2],[-1,0,1]];
      kY = [[-1,-2,-1],[0,0,0],[1,2,1]];
    } else {
      kX = [[-1,0,1],[-1,0,1],[-1,0,1]];
      kY = [[-1,-1,-1],[0,0,0],[1,1,1]];
    }

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        double gx = 0, gy = 0;
        for (int ky = 0; ky < 3; ky++) {
          for (int kx = 0; kx < 3; kx++) {
            final nx = clampCoordinate(x + kx - 1, 0, width - 1);
            final ny = clampCoordinate(y + ky - 1, 0, height - 1);
            final intensity = src.getPixel(nx, ny).luminance;
            gx += intensity * kX[ky][kx];
            gy += intensity * kY[ky][kx];
          }
        }
        final val = clampChannel(math.sqrt(gx*gx + gy*gy));
        dest.setPixelRgb(x, y, val, val, val);
      }
    }
    return dest;
  }

  static img.Image _applyLaplacianEdgeDetection(img.Image src) {
    return applyConvolution3x3(src, kernel: [[0,-1,0],[-1,4,-1],[0,-1,0]], useAbs: true);
  }

  static img.Image _applyRobertsEdgeDetection(img.Image src) {
    final width = src.width, height = src.height;
    final dest = img.Image(width: width, height: height);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final p00 = src.getPixel(x, y).luminance;
        final p11 = src.getPixel(clampCoordinate(x+1,0,width-1), clampCoordinate(y+1,0,height-1)).luminance;
        final p10 = src.getPixel(clampCoordinate(x+1,0,width-1), y).luminance;
        final p01 = src.getPixel(x, clampCoordinate(y+1,0,height-1)).luminance;
        final val = clampChannel(math.sqrt(math.pow(p00-p11, 2) + math.pow(p10-p01, 2)));
        dest.setPixelRgb(x, y, val, val, val);
      }
    }
    return dest;
  }

  static img.Image applyHistogramEqualization(img.Image src) {
    final int totalPixels = src.width * src.height;
    if (totalPixels == 0) return src;

    final List<int> histogram = buildGrayscaleHistogram256(src);
    final List<int> cdf = buildCdf(histogram);
    final int? cdfMin = findCdfMin(cdf);

    if (cdfMin == null || totalPixels == cdfMin) {
      return applyManualGrayscale(src);
    }

    final List<int> equalizedMap = buildEqualizationMap(cdf, cdfMin, totalPixels);

    for (final pixel in src) {
      final int intensity = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b).round();
      final int mappedValue = equalizedMap[intensity.clamp(0, 255)];
      pixel.r = mappedValue;
      pixel.g = mappedValue;
      pixel.b = mappedValue;
    }
    return src;
  }

  static List<int> buildGrayscaleHistogram256(img.Image src) {
    final List<int> histogram = List<int>.filled(256, 0);
    for (final pixel in src) {
      final int intensity = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b).round();
      histogram[intensity.clamp(0, 255)]++;
    }
    return histogram;
  }

  static List<int> buildCdf(List<int> histogram) {
    final List<int> cdf = List<int>.filled(256, 0);
    int cumulative = 0;
    for (int i = 0; i < 256; i++) {
      cumulative += histogram[i];
      cdf[i] = cumulative;
    }
    return cdf;
  }

  static int? findCdfMin(List<int> cdf) {
    for (int i = 0; i < 256; i++) {
      if (cdf[i] > 0) return cdf[i];
    }
    return null;
  }

  static List<int> buildEqualizationMap(List<int> cdf, int cdfMin, int totalPixels) {
    final List<int> map = List<int>.filled(256, 0);
    for (int i = 0; i < 256; i++) {
      map[i] = (((cdf[i] - cdfMin) / (totalPixels - cdfMin)) * 255).round().clamp(0, 255);
    }
    return map;
  }

  // Phase 7: Expansion Algorithms
  static img.Image applyNegative(img.Image src) {
    for (final pixel in src) {
      pixel.r = 255 - pixel.r;
      pixel.g = 255 - pixel.g;
      pixel.b = 255 - pixel.b;
    }
    return src;
  }

  static img.Image applySepia(img.Image src) {
    for (final pixel in src) {
      final r = pixel.r;
      final g = pixel.g;
      final b = pixel.b;
      pixel.r = clampChannel(0.393 * r + 0.769 * g + 0.189 * b);
      pixel.g = clampChannel(0.349 * r + 0.686 * g + 0.168 * b);
      pixel.b = clampChannel(0.272 * r + 0.534 * g + 0.131 * b);
    }
    return src;
  }

  static img.Image applyPosterization(img.Image src, int levels) {
    if (levels <= 1) return src;
    final int numLevels = levels.clamp(2, 256);
    final double step = 255 / (numLevels - 1);
    for (final pixel in src) {
      pixel.r = clampChannel((pixel.r / step).round() * step);
      pixel.g = clampChannel((pixel.g / step).round() * step);
      pixel.b = clampChannel((pixel.b / step).round() * step);
    }
    return src;
  }

  static img.Image applyRgbAdjustment(img.Image src, double rf, double gf, double bf) {
    for (final pixel in src) {
      pixel.r = clampChannel(pixel.r * rf);
      pixel.g = clampChannel(pixel.g * gf);
      pixel.b = clampChannel(pixel.b * bf);
    }
    return src;
  }

  static img.Image flipHorizontal(img.Image src) {
    final w = src.width, h = src.height;
    final dest = img.Image(width: w, height: h);
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        dest.setPixel(w - 1 - x, y, src.getPixel(x, y));
      }
    }
    return dest;
  }

  static img.Image flipVertical(img.Image src) {
    final w = src.width, h = src.height;
    final dest = img.Image(width: w, height: h);
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        dest.setPixel(x, h - 1 - y, src.getPixel(x, y));
      }
    }
    return dest;
  }

  static img.Image rotate90CW(img.Image src) {
    final w = src.width, h = src.height;
    final dest = img.Image(width: h, height: w);
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        dest.setPixel(h - 1 - y, x, src.getPixel(x, y));
      }
    }
    return dest;
  }

  static img.Image rotate90CCW(img.Image src) {
    final w = src.width, h = src.height;
    final dest = img.Image(width: h, height: w);
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        dest.setPixel(y, w - 1 - x, src.getPixel(x, y));
      }
    }
    return dest;
  }

  static img.Image _rotate180(img.Image src) {
    final w = src.width, h = src.height;
    final dest = img.Image(width: w, height: h);
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        dest.setPixel(w - 1 - x, h - 1 - y, src.getPixel(x, y));
      }
    }
    return dest;
  }

  static img.Image applyGeometryState(img.Image source, GeometryState state) {
    img.Image result = source;
    
    // 1. Apply rotation
    final turns = state.rotationQuarterTurns % 4;
    if (turns == 1) {
      result = rotate90CW(result);
    } else if (turns == 2) {
      result = _rotate180(result);
    } else if (turns == 3) {
      result = rotate90CCW(result);
    }

    // 2. Apply horizontal flip
    if (state.flipHorizontal) {
      result = flipHorizontal(result);
    }

    // 3. Apply vertical flip
    if (state.flipVertical) {
      result = flipVertical(result);
    }

    // 4. Apply scale
    if (state.scaleFactor != 1.0) {
      result = scaleNearestNeighbor(result, state.scaleFactor);
    }

    return result;
  }

  static img.Image scaleNearestNeighbor(img.Image src, double factor) {
    if (factor == 1.0) return src;
    final nW = (src.width * factor).toInt().clamp(1, 4000);
    final nH = (src.height * factor).toInt().clamp(1, 4000);
    final dest = img.Image(width: nW, height: nH);
    for (int y = 0; y < nH; y++) {
      for (int x = 0; x < nW; x++) {
        final sx = (x / factor).toInt().clamp(0, src.width - 1);
        final sy = (y / factor).toInt().clamp(0, src.height - 1);
        dest.setPixel(x, y, src.getPixel(sx, sy));
      }
    }
    return dest;
  }
}
