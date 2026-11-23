// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../app/data/api/api_client.dart' as _i1072;
import '../../app/data/api/location_service.dart' as _i14;
import '../../app/data/api/token_store.dart' as _i94;
import '../../app/data/datasources/local/repos/local_event_repo.dart' as _i550;
import '../../app/data/datasources/local/repos/local_model_version.dart'
    as _i280;
import '../../app/data/datasources/local/repos/local_repo.dart' as _i798;
import '../../app/data/datasources/remote/errors/exceptions.dart' as _i499;
import '../../app/data/datasources/remote/errors/remote_errors.dart' as _i340;
import '../../app/data/datasources/remote/repos/remote_auth_repo.dart' as _i985;
import '../../app/data/datasources/remote/repos/remote_event_repo.dart'
    as _i1054;
import '../../app/data/datasources/remote/repos/remote_face_repo.dart' as _i506;
import '../../app/data/datasources/remote/repos/remote_kiosk_repo.dart'
    as _i581;
import '../../app/data/datasources/remote/repos/remote_team_repo.dart' as _i75;
import '../../app/data/face/face_analyzer.dart' as _i973;
import '../../app/data/face/face_embedder.dart' as _i320;
import '../../app/data/repo/auth_repo.dart' as _i472;
import '../../app/data/repo/event_repo.dart' as _i966;
import '../../app/data/repo/face_recognizer.dart' as _i756;
import '../../app/data/repo/face_template_repo.dart' as _i560;
import '../../app/data/repo/kiosk_repo.dart' as _i244;
import '../../app/data/repo/team_repo.dart' as _i624;
import '../../app/modules/absence/controllers/absence_controller.dart' as _i768;
import '../../app/modules/anomaly/controllers/anomaly_controller.dart' as _i335;
import '../../app/modules/enrolment/controllers/enrolment_controller.dart'
    as _i323;
import '../../app/modules/face_enrol/controllers/face_enrol_controller.dart'
    as _i269;
import '../../app/modules/history/controllers/history_controller.dart' as _i736;
import '../../app/modules/kiosk/controllers/kiosk_controller.dart' as _i164;
import '../../app/modules/login/controllers/login_controller.dart' as _i799;
import '../../app/modules/manual_clock/controllers/manual_clock_controller.dart'
    as _i522;
import '../../app/modules/person_detail/controllers/person_detail_controller.dart'
    as _i161;
import '../../app/modules/profile/controllers/profile_controller.dart' as _i763;
import '../../app/modules/scan/controllers/scan_controller.dart' as _i1004;
import '../../app/modules/splash/controllers/splash_controller.dart' as _i907;
import '../../app/modules/sync/controllers/sync_controller.dart' as _i191;
import '../../app/modules/team/controllers/team_controller.dart' as _i391;
import '../../app/services/app_service.dart' as _i437;
import '../../app/services/auth_service.dart' as _i1028;
import '../../app/services/kiosk_service.dart' as _i1000;
import '../network/network_info.dart' as _i932;
import '../utils/encrytion_manager.dart' as _i854;
import 'register_module.dart' as _i291;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final registerModule = _$RegisterModule();
  gh.singleton<_i558.FlutterSecureStorage>(() => registerModule.storage);
  gh.singleton<_i895.Connectivity>(() => registerModule.connectivity);
  gh.lazySingleton<_i14.LocationService>(() => _i14.LocationService());
  gh.lazySingleton<_i340.RemoteErrors>(() => _i340.RemoteErrors());
  gh.lazySingleton<_i320.FaceEmbedder>(() => _i320.FaceEmbedder());
  gh.lazySingleton<_i361.Dio>(() => registerModule.dio());
  gh.lazySingleton<_i932.NetworkInfo>(
    () => _i932.NetworkInfoImpl(connectivity: gh<_i895.Connectivity>()),
  );
  gh.lazySingleton<_i499.RemoteException>(
    () => _i499.RemoteException(gh<_i340.RemoteErrors>()),
  );
  gh.lazySingleton<_i280.LocalModelVersions>(
    () => _i280.LocalModelVersionsImpl(),
  );
  gh.lazySingleton<_i94.TokenStore>(
    () => _i94.TokenStore(gh<_i558.FlutterSecureStorage>()),
  );
  gh.lazySingleton<_i973.FaceFrameAnalyzer>(
    () => _i973.FaceFrameAnalyzer(gh<_i320.FaceEmbedder>()),
  );
  gh.lazySingleton<_i854.EncryptionManager>(
    () => _i854.EncryptionManagerImpl(),
  );
  gh.lazySingleton<_i1072.ApiClient>(
    () => _i1072.ApiClient(gh<_i94.TokenStore>(), gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i75.RemoteTeamRepo>(
    () => _i75.RemoteTeamRepoImpl(gh<_i1072.ApiClient>()),
  );
  gh.lazySingleton<_i581.RemoteKioskRepo>(
    () => _i581.RemoteKioskRepoImpl(gh<_i1072.ApiClient>()),
  );
  gh.factory<_i1054.RemoteEventRepo>(
    () => _i1054.RemoteEventRepoImpl(
      gh<_i361.Dio>(),
      gh<_i499.RemoteException>(),
    ),
  );
  gh.factory<_i798.LocalRepo>(
    () => _i798.LocalRepoImpl(
      gh<_i280.LocalModelVersions>(),
      gh<_i854.EncryptionManager>(),
    ),
  );
  gh.factory<_i550.LocalEventRepo>(
    () => _i550.LocalEventRepoImpl(gh<_i798.LocalRepo>()),
  );
  gh.lazySingleton<_i506.RemoteFaceRepo>(
    () => _i506.RemoteFaceRepoImpl(gh<_i1072.ApiClient>()),
  );
  gh.lazySingleton<_i985.RemoteAuthRepo>(
    () => _i985.RemoteAuthRepoImpl(gh<_i1072.ApiClient>()),
  );
  gh.lazySingleton<_i624.TeamRepo>(
    () => _i624.TeamRepoImpl(
      gh<_i75.RemoteTeamRepo>(),
      gh<_i14.LocationService>(),
    ),
  );
  gh.lazySingleton<_i966.EventsRepo>(
    () => _i966.EventsRepoImpl(
      gh<_i1054.RemoteEventRepo>(),
      gh<_i550.LocalEventRepo>(),
    ),
  );
  gh.lazySingleton<_i472.AuthRepo>(
    () => _i472.AuthRepoImpl(gh<_i985.RemoteAuthRepo>(), gh<_i94.TokenStore>()),
  );
  gh.lazySingleton<_i560.FaceTemplateRepo>(
    () => _i560.FaceTemplateRepoImpl(
      gh<_i506.RemoteFaceRepo>(),
      gh<_i558.FlutterSecureStorage>(),
    ),
  );
  gh.lazySingleton<_i244.KioskRepo>(
    () => _i244.KioskRepoImpl(
      gh<_i581.RemoteKioskRepo>(),
      gh<_i560.FaceTemplateRepo>(),
      gh<_i14.LocationService>(),
    ),
  );
  gh.lazySingleton<_i1028.AuthService>(
    () => _i1028.AuthService(
      gh<_i472.AuthRepo>(),
      gh<_i624.TeamRepo>(),
      gh<_i560.FaceTemplateRepo>(),
    ),
  );
  gh.lazySingleton<_i437.AppService>(
    () => _i437.AppService(gh<_i624.TeamRepo>(), gh<_i560.FaceTemplateRepo>()),
  );
  gh.factoryParam<_i522.ManualClockController, _i522.ManualClockArgs, dynamic>(
    (_args, _) => _i522.ManualClockController(gh<_i437.AppService>(), _args),
  );
  gh.lazySingleton<_i1000.KioskService>(
    () => _i1000.KioskService(gh<_i244.KioskRepo>()),
  );
  gh.factoryParam<_i269.FaceEnrolController, String, dynamic>(
    (matricule, _) => _i269.FaceEnrolController(
      gh<_i437.AppService>(),
      gh<_i973.FaceFrameAnalyzer>(),
      matricule,
    ),
  );
  gh.factory<_i907.SplashController>(
    () => _i907.SplashController(
      gh<_i1028.AuthService>(),
      gh<_i14.LocationService>(),
    ),
  );
  gh.factory<_i799.LoginController>(
    () => _i799.LoginController(gh<_i1028.AuthService>()),
  );
  gh.factory<_i323.EnrolmentController>(
    () => _i323.EnrolmentController(gh<_i437.AppService>()),
  );
  gh.factory<_i736.HistoryController>(
    () => _i736.HistoryController(gh<_i437.AppService>()),
  );
  gh.factory<_i191.SyncController>(
    () => _i191.SyncController(gh<_i437.AppService>()),
  );
  gh.factory<_i391.TeamController>(
    () => _i391.TeamController(gh<_i437.AppService>()),
  );
  gh.factoryParam<_i768.AbsenceController, String, dynamic>(
    (matricule, _) =>
        _i768.AbsenceController(gh<_i437.AppService>(), matricule),
  );
  gh.factoryParam<_i335.AnomalyController, String, dynamic>(
    (matricule, _) =>
        _i335.AnomalyController(gh<_i437.AppService>(), matricule),
  );
  gh.factoryParam<_i161.PersonDetailController, String, dynamic>(
    (matricule, _) =>
        _i161.PersonDetailController(gh<_i437.AppService>(), matricule),
  );
  gh.lazySingleton<_i756.FaceRecognizer>(
    () => _i756.TemplateFaceRecognizer(
      gh<_i437.AppService>(),
      gh<_i560.FaceTemplateRepo>(),
    ),
  );
  gh.factory<_i763.ProfileController>(
    () => _i763.ProfileController(
      gh<_i437.AppService>(),
      gh<_i1028.AuthService>(),
    ),
  );
  gh.factory<_i164.KioskController>(
    () => _i164.KioskController(
      gh<_i1000.KioskService>(),
      gh<_i973.FaceFrameAnalyzer>(),
      gh<_i1028.AuthService>(),
    ),
  );
  gh.factoryParam<_i1004.ScanController, _i756.ScanMode, String?>(
    (mode, matricule) => _i1004.ScanController(
      gh<_i437.AppService>(),
      gh<_i756.FaceRecognizer>(),
      gh<_i973.FaceFrameAnalyzer>(),
      mode,
      matricule,
    ),
  );
  return getIt;
}

class _$RegisterModule extends _i291.RegisterModule {
  @override
  _i895.Connectivity get connectivity => _i895.Connectivity();
}
