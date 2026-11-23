import 'package:get/get.dart';
import '../modules/clock_done/bindings/clock_done_binding.dart';
import '../modules/clock_done/views/clock_done_view.dart';
import '../modules/face_enrol/bindings/face_enrol_binding.dart';
import '../modules/face_enrol/views/face_enrol_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/kiosk/bindings/kiosk_binding.dart';
import '../modules/kiosk/views/kiosk_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/manual_clock/bindings/manual_clock_binding.dart';
import '../modules/manual_clock/views/manual_clock_view.dart';
import '../modules/scan/bindings/scan_binding.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/sync/bindings/sync_binding.dart';
import '../modules/sync/views/sync_view.dart';
import '../modules/scan/views/scan_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.SCAN,
      page: () => const ScanView(),
      binding: ScanBinding(),
    ),
    GetPage(
      name: _Paths.CLOCK_DONE,
      page: () => const ClockDoneView(),
      binding: ClockDoneBinding(),
    ),
    GetPage(
      name: _Paths.MANUAL_CLOCK,
      page: () => const ManualClockView(),
      binding: ManualClockBinding(),
    ),
    GetPage(
      name: _Paths.FACE_ENROL,
      page: () => const FaceEnrolView(),
      binding: FaceEnrolBinding(),
    ),
    GetPage(
      name: _Paths.SYNC,
      page: () => const SyncView(),
      binding: SyncBinding(),
    ),
    GetPage(
      name: _Paths.KIOSK,
      page: () => const KioskView(),
      binding: KioskBinding(),
    ),
  ];
}
