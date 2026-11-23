import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:injectable/injectable.dart';

import 'face_aligner.dart';
import 'face_config.dart';
import 'face_embedder.dart';

/// Why a frame is not good enough to use, when it is not.
enum FaceHint {
  none,
  noFace,
  multipleFaces,
  tooFar,
  tooClose,
  notCentered,
  headTurned,
  lowLight,
}

/// The one face found in a frame. Coordinates are in pixels of the upright
/// (rotated, not mirrored) image.
class FaceObservation {
  const FaceObservation({
    required this.box,
    required this.imageSize,
    required this.landmarks,
    required this.leftEyeOpen,
    required this.rightEyeOpen,
    required this.yaw,
  });

  final Rect box;
  final Size imageSize;

  /// The five points of [FaceConfig.template], in that order.
  final List<(double, double)> landmarks;
  final double? leftEyeOpen;
  final double? rightEyeOpen;

  /// Head turn left or right, in degrees (the sign depends on the camera).
  final double yaw;
}

/// What was seen in one camera frame.
class FaceReading {
  const FaceReading({
    required this.image,
    required this.rotation,
    required this.faceCount,
    required this.hint,
    this.face,
  });

  final CameraImage image;

  /// Clockwise degrees to turn the frame upright.
  final int rotation;
  final int faceCount;
  final FaceHint hint;
  final FaceObservation? face;

  /// Exactly one good face, ready to be used.
  bool get ok => hint == FaceHint.none && face != null;
}

/// Finds the face in camera frames (ML Kit) and turns a good frame into a
/// template (alignment and model).
@lazySingleton
class FaceFrameAnalyzer {
  FaceFrameAnalyzer(this._embedder);

  final FaceEmbedder _embedder;

  final _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.fast,
      minFaceSize: 0.15,
    ),
  );

  /// Looks at one frame. The camera must stream `ImageFormatGroup.nv21`.
  ///
  /// [maxAngle] is the head turn accepted; the enrolment accepts more, to
  /// capture the sides of the face.
  Future<FaceReading> analyze(
    CameraImage image,
    CameraDescription camera, {
    double maxAngle = FaceConfig.maxHeadAngle,
  }) async {
    final rotation = camera.sensorOrientation;
    final raw = InputImageRotationValue.fromRawValue(rotation);
    if (raw == null || image.planes.isEmpty) {
      return _reading(image, rotation, 0, FaceHint.noFace);
    }

    final plane = image.planes.first;
    final faces = await _detector.processImage(
      InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: raw,
          format: InputImageFormat.nv21,
          bytesPerRow: plane.bytesPerRow,
        ),
      ),
    );

    if (faces.isEmpty) return _reading(image, rotation, 0, FaceHint.noFace);
    if (faces.length > 1) {
      return _reading(image, rotation, faces.length, FaceHint.multipleFaces);
    }

    final face = faces.first;
    // The frame is turned upright by ML Kit: swap the sides for 90 / 270.
    final turned = rotation == 90 || rotation == 270;
    final size = turned
        ? Size(image.height.toDouble(), image.width.toDouble())
        : Size(image.width.toDouble(), image.height.toDouble());

    final landmarks = _landmarks(face);
    if (landmarks == null) return _reading(image, rotation, 1, FaceHint.noFace);

    final observation = FaceObservation(
      box: face.boundingBox,
      imageSize: size,
      landmarks: landmarks,
      leftEyeOpen: face.leftEyeOpenProbability,
      rightEyeOpen: face.rightEyeOpenProbability,
      yaw: face.headEulerAngleY ?? 0,
    );

    final hint = _judge(face, size, _brightness(plane.bytes, image), maxAngle);
    return FaceReading(
      image: image,
      rotation: rotation,
      faceCount: 1,
      hint: hint,
      face: observation,
    );
  }

  FaceReading _reading(CameraImage image, int rotation, int count, FaceHint hint) =>
      FaceReading(image: image, rotation: rotation, faceCount: count, hint: hint);

  /// The five landmarks in template order. Left and right are taken from the
  /// position in the image, so the names ML Kit gives do not matter.
  List<(double, double)>? _landmarks(Face face) {
    (double, double)? at(FaceLandmarkType t) {
      final p = face.landmarks[t]?.position;
      return p == null ? null : (p.x.toDouble(), p.y.toDouble());
    }

    final eyeA = at(FaceLandmarkType.leftEye);
    final eyeB = at(FaceLandmarkType.rightEye);
    final nose = at(FaceLandmarkType.noseBase);
    final mouthA = at(FaceLandmarkType.leftMouth);
    final mouthB = at(FaceLandmarkType.rightMouth);
    if (eyeA == null ||
        eyeB == null ||
        nose == null ||
        mouthA == null ||
        mouthB == null) {
      return null;
    }

    final eyes = [eyeA, eyeB]..sort((a, b) => a.$1.compareTo(b.$1));
    final mouth = [mouthA, mouthB]..sort((a, b) => a.$1.compareTo(b.$1));
    return [eyes[0], eyes[1], nose, mouth[0], mouth[1]];
  }

  FaceHint _judge(Face face, Size size, double brightness, double maxAngle) {
    final box = face.boundingBox;
    final widthRatio = box.width / size.width;
    if (widthRatio < 0.28) return FaceHint.tooFar;
    if (widthRatio > 0.85) return FaceHint.tooClose;

    final dx = (box.center.dx - size.width / 2).abs() / size.width;
    final dy = (box.center.dy - size.height / 2).abs() / size.height;
    if (dx > 0.18 || dy > 0.2) return FaceHint.notCentered;

    final yaw = face.headEulerAngleY ?? 0;
    final roll = face.headEulerAngleZ ?? 0;
    if (yaw.abs() > maxAngle || roll.abs() > maxAngle) {
      return FaceHint.headTurned;
    }

    if (brightness < 55) return FaceHint.lowLight;
    return FaceHint.none;
  }

  /// Average luma of the frame, from a sparse sample of the Y plane (0-255).
  double _brightness(Uint8List nv21, CameraImage image) {
    final lumaLength = image.width * image.height;
    if (nv21.length < lumaLength) return 255;
    var sum = 0, count = 0;
    for (var i = 0; i < lumaLength; i += 97) {
      sum += nv21[i];
      count++;
    }
    return count == 0 ? 255 : sum / count;
  }

  /// The template of the face of a good [reading].
  Future<Float32List> templateOf(FaceReading reading) async {
    final face = reading.face;
    if (face == null) throw StateError('No face in this frame.');
    final upright = _toUprightRgb(reading.image, reading.rotation);
    final aligned = FaceAligner.align(upright, face.landmarks);
    return _embedder.embed(aligned);
  }

  /// NV21 to an RGB image, turned upright.
  img.Image _toUprightRgb(CameraImage image, int rotation) {
    final w = image.width, h = image.height;
    final data = image.planes.first.bytes;
    final out = img.Image(width: w, height: h);

    for (var y = 0; y < h; y++) {
      final row = y * w;
      final chroma = w * h + (y >> 1) * w;
      for (var x = 0; x < w; x++) {
        final luma = data[row + x];
        final c = chroma + (x & ~1);
        final v = data[c] - 128;
        final u = data[c + 1] - 128;
        out.setPixelRgb(
          x,
          y,
          _clamp(luma + 1.402 * v),
          _clamp(luma - 0.344136 * u - 0.714136 * v),
          _clamp(luma + 1.772 * u),
        );
      }
    }
    return rotation == 0 ? out : img.copyRotate(out, angle: rotation);
  }

  static int _clamp(double v) => math.max(0, math.min(255, v.round()));
}
