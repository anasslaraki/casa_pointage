import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:casa_pointage/app/data/face/head_turn_liveness.dart';
import 'package:casa_pointage/app/data/face/face_aligner.dart';
import 'package:casa_pointage/app/data/face/face_config.dart';
import 'package:casa_pointage/app/data/face/face_math.dart';

void main() {
  test('normalize gives length 1 and dot of identical templates is 1', () {
    final a = FaceMath.normalize([3, 4, 0]);
    expect(FaceMath.dot(a, a), closeTo(1, 1e-6));
    expect(a[0], closeTo(0.6, 1e-6));
  });

  test('average and quality of identical templates', () {
    final a = FaceMath.normalize([1, 2, 3]);
    expect(FaceMath.quality([a, a, a]), closeTo(1, 1e-6));
    final b = FaceMath.normalize([3, 2, 1]);
    expect(FaceMath.quality([a, b]), lessThan(1));
  });

  test('base64 round trip keeps the template', () {
    final a = FaceMath.normalize(List.generate(128, (i) => math.sin(i + 1)));
    final back = FaceMath.fromBase64(FaceMath.toBase64(a));
    expect(back.length, 128);
    expect(FaceMath.dot(a, back), closeTo(1, 1e-6));
  });

  test('align puts the template landmarks where the model expects them', () {
    // An image where the landmarks sit at the template spots, scaled x2 and
    // shifted: aligning must undo that, so a marker painted on each landmark
    // lands on the template point.
    final image = img.Image(width: 400, height: 400);
    img.fill(image, color: img.ColorRgb8(0, 0, 0));
    const scale = 2.0, ox = 50.0, oy = 80.0;
    final landmarks = [
      for (final p in FaceConfig.template) (p.$1 * scale + ox, p.$2 * scale + oy),
    ];
    for (final l in landmarks) {
      img.fillCircle(
        image,
        x: l.$1.round(),
        y: l.$2.round(),
        radius: 6,
        color: img.ColorRgb8(255, 255, 255),
      );
    }

    final out = FaceAligner.align(image, landmarks);
    const size = FaceConfig.inputSize;
    expect(out.length, 3 * size * size);
    for (final p in FaceConfig.template) {
      final x = p.$1.round(), y = p.$2.round();
      expect(out[y * size + x], greaterThan(150), reason: 'at $x,$y');
    }
    // Far from any landmark it is black.
    expect(out[5 * size + 5], lessThan(10));
  });

  test('head turn: one side, the other side, then front passes', () {
    final h = HeadTurnLiveness();
    Duration t(int ms) => Duration(milliseconds: ms);
    h.feed(t(0), yaw: 2);
    h.feed(t(300), yaw: 28);
    expect(h.step, HeadTurnStep.otherSide);
    h.feed(t(900), yaw: -26);
    expect(h.step, HeadTurnStep.back);
    h.feed(t(1300), yaw: -15);
    expect(h.passed, isFalse);
    h.feed(t(1600), yaw: 3);
    expect(h.passed, isTrue);
  });

  test('head turn: same side twice, too slow, or no turn does not pass', () {
    Duration t(int ms) => Duration(milliseconds: ms);

    final a = HeadTurnLiveness();
    a.feed(t(0), yaw: 30);
    a.feed(t(400), yaw: 0);
    a.feed(t(800), yaw: 31);
    expect(a.step, HeadTurnStep.otherSide);

    final b = HeadTurnLiveness();
    b.feed(t(0), yaw: 30);
    b.feed(t(9000), yaw: -30); // after the window: a new first turn
    expect(b.step, HeadTurnStep.otherSide);
    expect(b.passed, isFalse);

    final c = HeadTurnLiveness();
    c.feed(t(0), yaw: 5);
    c.feed(t(500), yaw: -8);
    c.feed(t(900)); // no face
    expect(c.step, HeadTurnStep.firstSide);
  });
}
