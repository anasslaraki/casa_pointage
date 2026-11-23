import 'dart:typed_data';

import '../repo/face_template_repo.dart';
import 'face_config.dart';
import 'face_math.dart';

/// A recognised template and how close it is (cosine similarity, 0 to 1).
class TemplateMatch {
  const TemplateMatch(this.template, this.score);

  final FaceTemplate template;
  final double score;
}

/// Compares a face with the templates of the team.
abstract class FaceMatcher {
  /// Identification: the best template, when it is good enough and clearly
  /// ahead of the second best. Otherwise `null`.
  static TemplateMatch? identify(
    Float32List face,
    List<FaceTemplate> candidates, {
    double threshold = FaceConfig.identifyThreshold,
    double margin = FaceConfig.identifyMargin,
  }) {
    TemplateMatch? best;
    double second = -1;
    for (final c in candidates) {
      final score = FaceMath.dot(face, c.template);
      if (best == null || score > best.score) {
        if (best != null) second = best.score;
        best = TemplateMatch(c, score);
      } else if (score > second) {
        second = score;
      }
    }
    if (best == null) return null;
    if (best.score < threshold) return null;
    if (candidates.length > 1 && best.score - second < margin) return null;
    return best;
  }

  /// Verification against one person.
  static TemplateMatch? verify(
    Float32List face,
    FaceTemplate target, {
    double threshold = FaceConfig.verifyThreshold,
  }) {
    final score = FaceMath.dot(face, target.template);
    return score >= threshold ? TemplateMatch(target, score) : null;
  }
}
