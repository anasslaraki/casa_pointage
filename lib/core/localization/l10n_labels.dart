import 'package:casa_pointage/app/data/models/assignment.dart';
import 'package:casa_pointage/app/data/models/person.dart';
import 'package:casa_pointage/app/data/models/schedule.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

/// Localized labels for domain enums.
/// "15 min · 0h15": a lateness in minutes, then in hours.
extension LateAmountLabel on AppLocalizations {
  String lateAmountOf(int minutes) {
    final hours = '${minutes ~/ 60}$unitHour'
        '${(minutes % 60).toString().padLeft(2, '0')}';
    return lateAmount(minutes, hours);
  }
}

extension PersonFunctionLabel on PersonFunction {
  String label(AppLocalizations l10n) => switch (this) {
        PersonFunction.supervisor => l10n.functionSupervisor,
        PersonFunction.sweeperMale => l10n.functionSweeperMale,
        PersonFunction.sweeperFemale => l10n.functionSweeperFemale,
        PersonFunction.driver => l10n.functionDriver,
        PersonFunction.loader => l10n.functionLoader,
        PersonFunction.sweeperDriver => l10n.functionSweeperDriver,
        PersonFunction.teamLead => l10n.functionTeamLead,
        PersonFunction.other => '',
      };
}

extension PersonFunctionText on Person {
  /// The translated function, or the text of the API when it has no translation.
  String functionLabel(AppLocalizations l10n) =>
      function == PersonFunction.other ? fonction : function.label(l10n);
}

extension ShiftKindLabel on ShiftKind {
  String label(AppLocalizations l10n) => switch (this) {
        ShiftKind.morning => l10n.shiftMorning,
        ShiftKind.afternoon => l10n.shiftAfternoon,
        ShiftKind.night => l10n.shiftNight,
      };
}

extension AssignmentKindLabel on AssignmentKind {
  String label(AppLocalizations l10n) => switch (this) {
        AssignmentKind.manualSweeping => l10n.assignmentManualSweeping,
        AssignmentKind.mechanicalSweeping => l10n.assignmentMechanicalSweeping,
        AssignmentKind.collection => l10n.assignmentCollection,
        AssignmentKind.supervision => l10n.assignmentSupervision,
      };
}

extension AssignmentLine on Assignment {
  /// "Circuit CABMN12 · CH-0412", or `null` when there is no circuit.
  String? line(AppLocalizations l10n) {
    final circuit = this.circuit;
    if (circuit == null) return null;
    final text = l10n.assignmentCircuitLine(circuit);
    return vehicle == null ? text : '$text · $vehicle';
  }
}

