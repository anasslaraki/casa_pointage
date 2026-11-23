/// Everything that depends on the face model, in one place. Changing the
/// model means changing this file and enrolling everyone again.
abstract class FaceConfig {
  /// Sent as `modeleVersion`: SFace (OpenCV Zoo, 2021 Dec), 128 numbers.
  static const modelVersion = 'sface-2021dec';
  static const modelAsset = 'assets/models/face_recognition_sface_2021dec.onnx';

  /// The model takes a 112 x 112 aligned face.
  static const inputSize = 112;

  /// Where the five landmarks (right eye, left eye, nose, right mouth corner,
  /// left mouth corner, as seen on the image) land in the aligned face. This is
  /// the standard 112 x 112 template of ArcFace-type models, also used by
  /// OpenCV for SFace.
  static const template = <(double, double)>[
    (38.2946, 51.6963),
    (73.5318, 51.5014),
    (56.0252, 71.7366),
    (41.5493, 92.3655),
    (70.7299, 92.2041),
  ];

  // ---- matching (starting values, to tune on real faces) ----

  /// Identification: best score and its lead over the second best.
  static const identifyThreshold = 0.70;
  static const identifyMargin = 0.05;

  /// Verification against one person.
  static const verifyThreshold = 0.70;

  // ---- liveness (head turn) ----

  /// Turn needed on each side, in degrees, and the angle that counts as
  /// "back to the front".
  static const headTurnAngle = 20.0;
  static const headTurnBack = 10.0;

  /// Time between the first turn and the end of the movement.
  static const headTurnWindow = Duration(seconds: 8);

  // ---- face quality in the frame ----

  /// Head turn accepted at pointage, in degrees.
  static const maxHeadAngle = 15.0;

  // ---- enrolment ----

  /// Good templates collected over the two passes, and the minimum quality.
  static const enrolTemplates = 15;
  static const enrolMinQuality = 0.80;
}
