import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

/// Vector helpers for face templates (embeddings).
abstract class FaceMath {
  /// A copy of [v] with length 1.
  static Float32List normalize(List<double> v) {
    var sum = 0.0;
    for (final x in v) {
      sum += x * x;
    }
    final norm = math.sqrt(sum);
    final out = Float32List(v.length);
    if (norm == 0) return out;
    for (var i = 0; i < v.length; i++) {
      out[i] = v[i] / norm;
    }
    return out;
  }

  /// Cosine similarity of two normalised templates.
  static double dot(Float32List a, Float32List b) {
    var s = 0.0;
    final n = math.min(a.length, b.length);
    for (var i = 0; i < n; i++) {
      s += a[i] * b[i];
    }
    return s;
  }

  /// The normalised average of several templates.
  static Float32List average(List<Float32List> templates) {
    final sum = List<double>.filled(templates.first.length, 0);
    for (final t in templates) {
      for (var i = 0; i < sum.length; i++) {
        sum[i] += t[i];
      }
    }
    return normalize(sum);
  }

  /// Mean similarity of the collected templates to their average: how
  /// consistent the capture was (1 is identical).
  static double quality(List<Float32List> templates) {
    final mean = average(templates);
    var s = 0.0;
    for (final t in templates) {
      s += dot(t, mean);
    }
    return s / templates.length;
  }

  static String toBase64(Float32List template) =>
      base64Encode(template.buffer.asUint8List(
        template.offsetInBytes,
        template.lengthInBytes,
      ));

  static Float32List fromBase64(String text) {
    final bytes = base64Decode(text);
    // Copy: the decoded buffer may not be aligned for a float view.
    return Float32List.view(Uint8List.fromList(bytes).buffer);
  }
}
