import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'face_config.dart';

/// Straightens and crops a face to the model input.
abstract class FaceAligner {
  /// [landmarks] are the five points of [FaceConfig.template], in pixels of
  /// [image] (upright, not mirrored). Returns the 112 x 112 face as RGB planes
  /// (channel first), values 0 to 255, ready for the model.
  static Float32List align(img.Image image, List<(double, double)> landmarks) {
    const size = FaceConfig.inputSize;
    final t = FaceConfig.template;
    assert(landmarks.length == t.length);

    // Best similarity transform (scale, rotation, shift) from the landmarks
    // to the template, in the least-squares sense.
    var msx = 0.0, msy = 0.0, mdx = 0.0, mdy = 0.0;
    for (var i = 0; i < t.length; i++) {
      msx += landmarks[i].$1;
      msy += landmarks[i].$2;
      mdx += t[i].$1;
      mdy += t[i].$2;
    }
    msx /= t.length;
    msy /= t.length;
    mdx /= t.length;
    mdy /= t.length;

    var a = 0.0, b = 0.0, s = 0.0;
    for (var i = 0; i < t.length; i++) {
      final sx = landmarks[i].$1 - msx, sy = landmarks[i].$2 - msy;
      final dx = t[i].$1 - mdx, dy = t[i].$2 - mdy;
      a += sx * dx + sy * dy;
      b += sx * dy - sy * dx;
      s += sx * sx + sy * sy;
    }
    final norm = math.sqrt(a * a + b * b);
    if (norm == 0 || s == 0) return Float32List(3 * size * size);
    final cos = a / norm, sin = b / norm;
    final scale = norm / s;

    // For each pixel of the aligned face, where it comes from in the image.
    final out = Float32List(3 * size * size);
    const plane = size * size;
    for (var v = 0; v < size; v++) {
      for (var u = 0; u < size; u++) {
        final px = (u - mdx) / scale, py = (v - mdy) / scale;
        final x = cos * px + sin * py + msx;
        final y = -sin * px + cos * py + msy;
        final (r, g, bl) = _sample(image, x, y);
        final i = v * size + u;
        out[i] = r;
        out[plane + i] = g;
        out[2 * plane + i] = bl;
      }
    }
    return out;
  }

  /// Bilinear colour at a point; the border is repeated outside the image.
  static (double, double, double) _sample(img.Image image, double x, double y) {
    final maxX = image.width - 1, maxY = image.height - 1;
    final cx = x.clamp(0.0, maxX.toDouble());
    final cy = y.clamp(0.0, maxY.toDouble());
    final x0 = cx.floor(), y0 = cy.floor();
    final x1 = math.min(x0 + 1, maxX), y1 = math.min(y0 + 1, maxY);
    final fx = cx - x0, fy = cy - y0;

    final p00 = image.getPixel(x0, y0);
    final p10 = image.getPixel(x1, y0);
    final p01 = image.getPixel(x0, y1);
    final p11 = image.getPixel(x1, y1);

    double mix(num a, num b, num c, num d) =>
        (a * (1 - fx) + b * fx) * (1 - fy) + (c * (1 - fx) + d * fx) * fy;

    return (
      mix(p00.r, p10.r, p01.r, p11.r),
      mix(p00.g, p10.g, p01.g, p11.g),
      mix(p00.b, p10.b, p01.b, p11.b),
    );
  }
}
