import 'package:flutter_test/flutter_test.dart';

import 'package:casa_pointage/app/data/face/face_matcher.dart';
import 'package:casa_pointage/app/data/face/face_math.dart';
import 'package:casa_pointage/app/data/repo/face_template_repo.dart';

FaceTemplate _t(int id, List<double> v) => FaceTemplate(
      agentId: id,
      matricule: 'M$id',
      template: FaceMath.normalize(v),
    );

void main() {
  final a = _t(1, [1, 0, 0]);
  final b = _t(2, [0, 1, 0]);
  final c = _t(3, [0.9, 0.1, 0]);

  test('identify picks the clear best match', () {
    final face = FaceMath.normalize([0.98, 0.02, 0]);
    final match = FaceMatcher.identify(face, [a, b]);
    expect(match?.template.matricule, 'M1');
  });

  test('identify refuses a face that matches nobody', () {
    final face = FaceMath.normalize([0, 0, 1]);
    expect(FaceMatcher.identify(face, [a, b]), isNull);
  });

  test('identify refuses when two people are too close', () {
    final face = FaceMath.normalize([1, 0.02, 0]);
    expect(FaceMatcher.identify(face, [a, c]), isNull);
  });

  test('verify checks one person only', () {
    final face = FaceMath.normalize([1, 0.05, 0]);
    expect(FaceMatcher.verify(face, a), isNotNull);
    expect(FaceMatcher.verify(face, b), isNull);
  });

  test('template json round trip', () {
    final back = FaceTemplate.fromJson(a.toJson());
    expect(back?.agentId, 1);
    expect(FaceMath.dot(back!.template, a.template), closeTo(1, 1e-6));
  });
}
