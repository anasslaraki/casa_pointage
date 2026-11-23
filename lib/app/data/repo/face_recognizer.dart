import 'dart:typed_data';

import 'package:injectable/injectable.dart';

import 'package:casa_pointage/app/data/face/face_matcher.dart';
import 'package:casa_pointage/app/data/models/face_match.dart';
import 'package:casa_pointage/app/data/repo/face_template_repo.dart';
import 'package:casa_pointage/app/services/app_service.dart';

enum ScanMode {
  /// The supervisor clocks in a team member (back camera).
  team,

  /// The supervisor clocks themself in (front camera).
  self,
}

/// Recognises the face of a template: who is it, among the enrolled people.
abstract class FaceRecognizer {
  /// Loads the templates of the team (from the server, or from the phone when
  /// there is no network).
  Future<void> prepare();

  /// With [matricule] (or in [ScanMode.self]) the face is verified against
  /// that person only; otherwise it is identified among the team. Returns
  /// `null` when no enrolled person matches.
  Future<FaceMatch?> recognize(
    Float32List face, {
    required ScanMode mode,
    String? matricule,
  });
}

@LazySingleton(as: FaceRecognizer)
class TemplateFaceRecognizer implements FaceRecognizer {
  TemplateFaceRecognizer(this._app, this._templates);

  final AppService _app;
  final FaceTemplateRepo _templates;

  @override
  Future<void> prepare() async {
    await _templates.sync();
  }

  @override
  Future<FaceMatch?> recognize(
    Float32List face, {
    required ScanMode mode,
    String? matricule,
  }) async {
    final team = await _app.getTeam();
    final all = await _templates.stored();

    final target = mode == ScanMode.self
        ? team.where((p) => p.isSupervisor).firstOrNull?.matricule
        : matricule;

    final TemplateMatch? match;
    if (target != null) {
      final own = all.where((t) => t.matricule == target).firstOrNull;
      if (own == null) return null;
      match = FaceMatcher.verify(face, own);
    } else {
      // The supervisor clocks in with "Me pointer", not among the team.
      final supervisors = {
        for (final p in team)
          if (p.isSupervisor) p.matricule,
      };
      match = FaceMatcher.identify(face, [
        for (final t in all)
          if (!supervisors.contains(t.matricule)) t,
      ]);
    }
    if (match == null) return null;

    final person =
        team.where((p) => p.matricule == match!.template.matricule).firstOrNull;
    if (person == null) return null;
    return FaceMatch(person: person, score: (match.score * 100).round());
  }
}
