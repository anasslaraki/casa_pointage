import 'package:get/get.dart';

import 'package:casa_pointage/app/data/models/assignment.dart';
import 'package:casa_pointage/app/data/models/attendance_record.dart';
import 'package:casa_pointage/app/data/models/person.dart';
import 'package:casa_pointage/app/data/repo/face_recognizer.dart';
import 'package:casa_pointage/app/routes/app_pages.dart';

/// What the confirmation screen shows.
class ClockDoneArgs {
  const ClockDoneArgs({
    required this.person,
    required this.kind,
    required this.minute,
    required this.method,
    required this.assignment,
    required this.pending,
    required this.mode,
  });

  final Person person;
  final ClockKind kind;
  final int minute;
  final ClockMethod method;
  final Assignment assignment;

  /// Saved on the phone only, waiting for the network.
  final bool pending;

  /// How the scan was started, to start the next one the same way.
  final ScanMode mode;
}

class ClockDoneController extends GetxController {
  ClockDoneController(this.args);

  final ClockDoneArgs args;

  void clockNext() => Get.offNamed(Routes.SCAN, arguments: args.mode);

  void backToTeam() => Get.until((route) => route.settings.name == Routes.HOME);
}
