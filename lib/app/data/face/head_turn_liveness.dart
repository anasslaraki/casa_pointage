import 'face_config.dart';

enum HeadTurnStep { firstSide, otherSide, back, passed }

/// "Tournez la tête": the head turns to one side, then to the other side, then
/// comes back to the front. The side is not fixed, so the sign of the angle,
/// which depends on the camera, does not matter. Feed it one reading per
/// camera frame.
class HeadTurnLiveness {
  HeadTurnLiveness({Duration? window})
      : _window = window ?? FaceConfig.headTurnWindow;

  final Duration _window;

  HeadTurnStep _step = HeadTurnStep.firstSide;
  Duration? _startedAt;

  /// 1 or -1: the side of the first turn.
  int _side = 0;

  HeadTurnStep get step => _step;
  bool get passed => _step == HeadTurnStep.passed;

  /// [now] is any increasing clock; [yaw] is the head angle in degrees, `null`
  /// when the frame has no face (the turn is not lost, only the time runs).
  HeadTurnStep feed(Duration now, {double? yaw}) {
    if (_step == HeadTurnStep.passed) return _step;

    final started = _startedAt;
    if (started != null && now - started > _window) reset();

    if (yaw == null) return _step;

    switch (_step) {
      case HeadTurnStep.firstSide:
        if (yaw.abs() >= FaceConfig.headTurnAngle) {
          _side = yaw > 0 ? 1 : -1;
          _startedAt = now;
          _step = HeadTurnStep.otherSide;
        }
      case HeadTurnStep.otherSide:
        if (yaw * _side <= -FaceConfig.headTurnAngle) {
          _step = HeadTurnStep.back;
        }
      case HeadTurnStep.back:
        if (yaw.abs() <= FaceConfig.headTurnBack) _step = HeadTurnStep.passed;
      case HeadTurnStep.passed:
        break;
    }
    return _step;
  }

  void reset() {
    _step = HeadTurnStep.firstSide;
    _startedAt = null;
    _side = 0;
  }
}
