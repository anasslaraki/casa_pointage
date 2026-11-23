import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../data/models/supervisor.dart';
import '../routes/app_pages.dart';
import '../data/repo/auth_repo.dart';
import '../data/repo/face_template_repo.dart';
import '../data/repo/team_repo.dart';

/// The signed-in supervisor and the login / logout flow.
@lazySingleton
class AuthService {
  AuthService(this.authRepo, this.teamRepo, this.faceTemplateRepo);

  final AuthRepo authRepo;
  final TeamRepo teamRepo;
  final FaceTemplateRepo faceTemplateRepo;

  final supervisor = Rxn<Supervisor>();

  /// First screen of the signed-in user: the face screen for a kiosk account,
  /// the supervisor home otherwise.
  String get homeRoute =>
      (supervisor.value?.isKiosk ?? false) ? Routes.KIOSK : Routes.HOME;

  /// Returns the supervisor, or `null` when the credentials are wrong.
  /// An `ApiException` carries the server message of the other refusals.
  Future<Supervisor?> login(String login, String password) async {
    final result = await authRepo.login(login, password);
    supervisor.value = result;
    return result;
  }

  /// Whether a session saved on the phone is still usable. The supervisor stays
  /// signed in until [logout] or until the tokens can no longer be renewed.
  Future<bool> isLogged() async {
    final restored = await authRepo.restoreSession();
    supervisor.value = restored;
    return restored != null;
  }

  /// Forgets the tokens and everything cached for this supervisor.
  Future<void> logout() async {
    await authRepo.logout();
    teamRepo.reset();
    await faceTemplateRepo.clear();
    supervisor.value = null;
  }
}
