import 'package:get/get.dart';

import 'package:casa_pointage/core/loading/loading_state.dart';
import 'package:casa_pointage/core/loading/loading_state_x.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import 'package:casa_pointage/app/data/api/api_exception.dart';

import 'package:casa_pointage/app/data/models/absence_type.dart';
import 'package:casa_pointage/app/data/models/declaration.dart';
import 'package:casa_pointage/app/data/models/person.dart';
import 'package:casa_pointage/app/services/app_service.dart';
import 'package:casa_pointage/app/data/utils/attendance_rules.dart';
import 'package:casa_pointage/core/widgets/coming_soon.dart';

/// Absence declaration of one person, for one or several days.
@injectable
class AbsenceController extends GetxController {
  AbsenceController(this.appService, @factoryParam this.matricule);

  final AppService appService;
  final String matricule;

  final pageState = Rx<LoadingState?>(const LoadingState.loading());
  final saving = false.obs;
  final person = Rxn<Person>();
  final reason = Rxn<AbsenceType>();

  /// Choices of `GET /types-absence`.
  final reasons = <AbsenceType>[].obs;
  final from = _today().obs;
  final to = _today().obs;

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  bool get canSave => reason.value != null && !saving.value;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => pageState.run(() async {
    final team = await appService.getTeam();
    person.value = team.where((p) => p.matricule == matricule).firstOrNull;
    reasons.assignAll(await appService.getAbsenceTypes());
  });

  /// Selecting the reason again clears it.
  void selectReason(AbsenceType value) =>
      reason.value = reason.value == value ? null : value;

  void setFrom(DateTime date) {
    from.value = date;
    if (to.value.isBefore(date)) to.value = date;
  }

  void setTo(DateTime date) => to.value = date;

  Future<void> save(String savedMessage) async {
    final chosen = reason.value;
    if (chosen == null || saving.value) return;
    saving.value = true;

    try {
      await appService.saveDeclaration(
        Declaration(
          id: const Uuid().v4(),
          matricule: matricule,
          kind: DeclarationKind.absence,
          absenceReason: chosen.label,
          absenceTypeId: chosen.id,
          fromDateKey: AttendanceRules.dateKey(from.value),
          toDateKey: AttendanceRules.dateKey(to.value),
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

}
