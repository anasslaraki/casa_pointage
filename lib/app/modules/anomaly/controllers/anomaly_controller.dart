import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:casa_pointage/core/loading/loading_state.dart';
import 'package:casa_pointage/core/loading/loading_state_x.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import 'package:casa_pointage/app/data/api/api_exception.dart';

import 'package:casa_pointage/app/data/models/declaration.dart';
import 'package:casa_pointage/app/data/models/person.dart';
import 'package:casa_pointage/app/services/app_service.dart';
import 'package:casa_pointage/app/data/utils/attendance_rules.dart';
import 'package:casa_pointage/core/widgets/coming_soon.dart';

/// Anomaly report about one person, for today.
@injectable
class AnomalyController extends GetxController {
  AnomalyController(this.appService, @factoryParam this.matricule);

  final AppService appService;
  final String matricule;

  final pageState = Rx<LoadingState?>(const LoadingState.loading());
  final saving = false.obs;
  final person = Rxn<Person>();
  final kind = RxnString();

  /// Choices of `motifs.anomalie`.
  final reasons = <String>[].obs;
  final comment = ''.obs;

  /// The day concerned (up to 31 days back) and the time that was right.
  final day = _today().obs;
  final time = Rxn<TimeOfDay>();

  final commentController = TextEditingController();

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// A description is required when the type is "other".
  bool get needsComment =>
      kind.value?.toLowerCase() == 'autre' && comment.value.trim().isEmpty;

  bool get canSave => kind.value != null && !needsComment && !saving.value;

  @override
  void onInit() {
    super.onInit();
    commentController.addListener(() => comment.value = commentController.text);
    load();
  }

  Future<void> load() => pageState.run(() async {
    final team = await appService.getTeam();
    person.value = team.where((p) => p.matricule == matricule).firstOrNull;
    reasons.assignAll((await appService.getMotifs()).anomaly);

    // Usually the end of the shift (a forgotten exit).
    final schedule = await appService.getSchedule();
    final end = schedule.shiftAt(AttendanceRules.minuteOfDay(DateTime.now())).endMinute % 1440;
    time.value ??= TimeOfDay(hour: end ~/ 60, minute: end % 60);
  });

  void setDay(DateTime date) => day.value = date;

  void setTime(TimeOfDay value) => time.value = value;

  /// Selecting the type again clears it.
  void selectKind(String value) =>
      kind.value = kind.value == value ? null : value;

  Future<void> save(String savedMessage) async {
    final chosen = kind.value;
    if (chosen == null || !canSave) return;
    saving.value = true;

    try {
      final text = comment.value.trim();
      final dayKey = AttendanceRules.dateKey(day.value);
      final t = time.value;

      await appService.saveDeclaration(
        Declaration(
          id: const Uuid().v4(),
          matricule: matricule,
          kind: DeclarationKind.anomaly,
          anomalyKind: chosen,
          fromDateKey: dayKey,
          toDateKey: dayKey,
          comment: text.isEmpty ? null : text,
          correctTime: t == null
              ? null
              : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
        ),
      );

      Get.back<void>();
      showAppToast(savedMessage);
    } on ApiException catch (e) {
      showAppToast(e.message);
    } finally {
      saving.value = false;
    }
  }

  void close() => Get.back<void>();

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
