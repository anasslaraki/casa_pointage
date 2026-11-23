import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import 'package:casa_pointage/app/data/api/location_service.dart';
import 'package:casa_pointage/app/routes/app_pages.dart';
import 'package:casa_pointage/app/services/auth_service.dart';

/// Decides where the app starts: the home (or the face screen of a kiosk
/// account) when a saved session is still usable, the login screen otherwise.
@injectable
class SplashController extends GetxController {
  SplashController(this.authService, this._location);

  final AuthService authService;
  final LocationService _location;

  @override
  void onReady() {
    super.onReady();
    _route();
  }

  Future<void> _route() async {
    final logged = await authService.isLogged();
    Get.offAllNamed(logged ? authService.homeRoute : Routes.LOGIN);

    // Once the splash is over: ask for the location (permission, then the
    // phone's "turn on location" dialog). Nothing shows when it is fine.
    await _location.ensureReady();
  }
}
