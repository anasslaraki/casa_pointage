# API pattern — how Casa Pointage talks to its backend

A guide to copy the way this app calls its API into another Flutter project that
already uses the same stack (GetX, `injectable` + `get_it`, `dio`, freezed
`LoadingState`). It describes **the pattern and the code to reuse**, not the
Pointage business rules.

How to use it: read sections 1 to 3, copy the files of section 4 as they are,
then apply sections 5 to 15 feature by feature (sections 12 to 15 are the
dependency injection chain, the loading state, the splash and the theme). Section 17 lists the mistakes
already made once; do not repeat them.

Replace `<app>` by the package name of the other project and `<API_KEY>` /
`APP_API_KEY` by its own names.

---

## 1. The layers

```
Controller  (@injectable, GetxController)         lib/app/modules/<feature>/controllers
   │  calls
Service     (@lazySingleton)                       lib/app/services/app_service.dart, auth_service.dart
   │  calls
Repo        (interface + Impl, @LazySingleton(as:)) lib/app/data/repo/<name>_repo.dart
   │  maps JSON → models, caches, business rules
Remote repo (interface + Impl, raw calls)          lib/app/data/datasources/remote/repos/remote_<name>_repo.dart
   │  one method per endpoint, returns raw JSON
ApiClient   (@lazySingleton)                       lib/app/data/api/api_client.dart
   │  key, bearer token, refresh, errors
Dio         (RegisterModule, logger in debug)      lib/core/di/register_module.dart
```

Rules:

- A **remote repo** only knows paths, query parameters and bodies. It returns
  `Map<String, dynamic>` / `List` and parses nothing.
- A **repo** turns JSON into models, keeps caches and decides what a screen
  needs. It never touches Flutter widgets.
- A **service** is the only thing controllers call. It mostly delegates to
  repos; it is where several repos are combined.
- A **controller** never imports a repo or a remote repo, only services.
- Errors travel as `ApiException` whose `message` is meant for the user: the
  controller catches it and shows `e.message` as it is.

Folder layout:

```
lib/
  core/di/                 injection.dart, register_module.dart, injection.config.dart (generated)
  core/errors/             message_types.dart
  core/loading/            loading_state.dart, loading_state_x.dart, loading_state_wrapper.dart
  core/theme/              app_theme.dart, app_colors.dart
  core/widgets/            skeleton.dart, pagination_bar.dart, app_sheet.dart
  app/data/api/            api_config, api_exception, api_client, api_logger, token_store
  app/data/datasources/remote/repos/   remote_*_repo.dart
  app/data/repo/           *_repo.dart
  app/data/models/         plain Dart classes
  app/services/            app_service.dart, auth_service.dart
  app/modules/<feature>/   bindings/, controllers/, views/
```

---

## 2. Dependencies and code generation

`pubspec.yaml`:

```yaml
dependencies:
  get: ^4.7.3
  dio: ^5.0.1
  get_it: ^9.3.0
  injectable: ^3.0.0
  flutter_secure_storage: ^10.3.4
  connectivity_plus: ^7.3.2
  freezed_annotation: ^3.1.0

dev_dependencies:
  build_runner: ^2.4.15
  freezed: ^3.2.5
  injectable_generator: ^3.0.2
```

After adding or changing any `@injectable`, `@lazySingleton`, `@module` or
`@freezed` class:

```bash
dart run build_runner build --delete-conflicting-outputs
```

`lib/core/di/injection.dart`:

```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:<app>/core/di/injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies(String env) async =>
    $initGetIt(getIt, environment: env);
```

---

## 3. The API key and the build

The key is **never in the source**. It is a compile-time constant given on the
command line.

`lib/app/data/api/api_config.dart`:

```dart
abstract class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'APP_BASE_URL',
    defaultValue: 'https://<host>/api',
  );

  static const apiKey = String.fromEnvironment('APP_API_KEY');
}
```

`env.json` (git-ignored) and `env.example.json` (committed):

```json
{ "APP_API_KEY": "paste-the-api-key-here" }
```

`.gitignore`: add `env.json`.

Run and build always with the file:

```bash
flutter run --dart-define-from-file=env.json
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols --dart-define-from-file=env.json
```

IDE: VS Code `.vscode/launch.json` → `"args": ["--dart-define-from-file=env.json"]`;
Android Studio run configuration → "Additional run args" the same flag.

Notes:

- Without the flag the key is empty and `ApiClient` throws a clear
  `ApiException` ("Clé API manquante…") on the first call. Keep that guard.
- Obfuscation does **not** hide the key: it stays readable in the APK. It is
  hidden from the repository, not from someone holding the APK.

---

## 4. Files to copy as they are

### 4.1 `api_exception.dart`

```dart
/// An error the user can read: [message] is shown as is.
class ApiException implements Exception {
  const ApiException(this.message, {this.status});

  final String message;
  final int? status;

  bool get isNotFound => status == 404;

  @override
  String toString() => message;
}

/// Wrong or revoked API key (401 on every call, even the login).
class AppNotAuthorized extends ApiException {
  const AppNotAuthorized()
      : super('Application non autorisée, contactez le support', status: 401);
}

/// Tokens refused and the refresh failed: back to the login screen.
class SessionExpired extends ApiException {
  const SessionExpired() : super('Session expirée', status: 401);
}

/// No network, or the server did not answer in time.
class NetworkUnavailable extends ApiException {
  const NetworkUnavailable() : super('Pas de réseau');
}
```

### 4.2 `token_store.dart`

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Access and refresh tokens, kept in the secure storage of the phone.
@lazySingleton
class TokenStore {
  TokenStore(this._storage);

  static const _accessKey = 'access';
  static const _refreshKey = 'refresh';

  final FlutterSecureStorage _storage;

  String? _access;
  String? _refresh;

  String? get access => _access;
  String? get refresh => _refresh;

  Future<void> load() async {
    _access = await _storage.read(key: _accessKey);
    _refresh = await _storage.read(key: _refreshKey);
  }

  Future<void> save({required String access, required String refresh}) async {
    _access = access;
    _refresh = refresh;
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  Future<void> clear() async {
    _access = null;
    _refresh = null;
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
```

### 4.3 `api_client.dart`

What it does for **every** call:

1. Refuses to send when the key is empty.
2. Adds `?code=<key>` to the URL (this API wants the key in the query string).
3. Adds `Authorization: Bearer <access>` except on the login and refresh calls.
4. Never throws on a status code (`validateStatus: (_) => true`) and maps it
   itself; a `DioException` becomes `NetworkUnavailable`.
5. On `401`: login → `AppNotAuthorized`; otherwise renews the tokens **once**
   (single flight, even when several calls fail together), replays the call,
   and if it still fails clears the tokens, emits `sessionExpired` and throws
   `SessionExpired`.
6. Any status other than `200` → `ApiException(message, status:)` where the
   message is the JSON `message` of the body or its plain text.

```dart
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'api_config.dart';
import 'api_exception.dart';
import 'token_store.dart';

/// Body of a successful write: `{ success, message, data }`.
class ApiResult {
  const ApiResult(this.message, this.data);

  final String message;
  final dynamic data;
}

@lazySingleton
class ApiClient {
  ApiClient(this.tokens, this._dio);

  static const _authentication = '/Authentication';
  static const _refreshToken = '/RefreshToken';

  final TokenStore tokens;
  final Dio _dio;

  final _sessionExpired = StreamController<void>.broadcast();
  Future<bool>? _refreshing;

  /// Emits when the session cannot be renewed: go back to the login screen.
  Stream<void> get sessionExpired => _sessionExpired.stream;

  Future<Response<String>> _raw(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    if (ApiConfig.apiKey.isEmpty) {
      throw const ApiException(
        'Clé API manquante : lancez l\'app avec '
        '--dart-define-from-file=env.json',
      );
    }
    final token = tokens.access;
    final isAuthCall = path == _authentication || path == _refreshToken;
    try {
      return await _dio.request<String>(
        path,
        data: body,
        // The API key goes in the URL of every call: `...?code=<key>`.
        queryParameters: {...?query, 'code': ApiConfig.apiKey},
        options: Options(
          method: method,
          responseType: ResponseType.plain,
          contentType: body == null ? null : Headers.jsonContentType,
          validateStatus: (_) => true,
          headers: {
            if (!isAuthCall && token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException {
      throw const NetworkUnavailable();
    }
  }

  /// Renews the tokens once, even when several calls fail together.
  Future<bool> _refresh() =>
      _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);

  Future<bool> _doRefresh() async {
    final refresh = tokens.refresh;
    if (refresh == null) return false;
    final r = await _raw('POST', _refreshToken, body: {'refresh': refresh});
    if (r.statusCode != 200) return false;
    final json = jsonDecode(r.data ?? '{}');
    if (json is! Map) return false;
    await tokens.save(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
    );
    return true;
  }

  Future<Response<String>> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    var r = await _raw(method, path, query: query, body: body);
    if (r.statusCode == 401) {
      if (path == _authentication) throw const AppNotAuthorized();
      if (path != _refreshToken && await _refresh()) {
        r = await _raw(method, path, query: query, body: body);
      }
      if (r.statusCode == 401) {
        await tokens.clear();
        _sessionExpired.add(null);
        throw const SessionExpired();
      }
    }
    return r;
  }

  /// The user-facing text of an error body (JSON `message` or plain text).
  static String _messageOf(String? body) {
    final text = (body ?? '').trim();
    if (text.isEmpty) return 'Erreur interne.';
    try {
      final json = jsonDecode(text);
      if (json is Map && json['message'] is String) {
        return json['message'] as String;
      }
      if (json is String) return json;
    } catch (_) {}
    return text;
  }

  /// Sends a call and returns the decoded JSON body of a `200`.
  Future<dynamic> request(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    final r = await _send(method, path, query: query, body: body);
    final status = r.statusCode ?? 0;
    if (status != 200) {
      throw ApiException(_messageOf(r.data), status: status);
    }
    final text = r.data;
    if (text == null || text.trim().isEmpty) return null;
    return jsonDecode(text);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      request('GET', path, query: query);

  /// Every item of a paginated list (`{ page, totalPages, items }`), reading
  /// the pages one after the other. A bare array is accepted too.
  Future<List<Map<String, dynamic>>> getAllPages(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final items = <Map<String, dynamic>>[];
    var page = 1;
    while (true) {
      final json = await get(
        path,
        query: {...?query, 'page': page, 'pageSize': 200},
      );
      final list = json is List
          ? json
          : json is Map
              ? (json['items'] as List? ?? const [])
              : const [];
      for (final e in list) {
        if (e is Map) items.add(e.cast<String, dynamic>());
      }
      final pages = json is Map ? (json['totalPages'] as num?)?.toInt() ?? 1 : 1;
      if (page >= pages) return items;
      page++;
    }
  }

  /// Sends a write (`{ success, message, data }` answer).
  Future<ApiResult> write(String method, String path, {Object? body}) async {
    final json = await request(method, path, body: body);
    if (json is Map) {
      return ApiResult((json['message'] as String?) ?? '', json['data']);
    }
    return const ApiResult('', null);
  }

  void dispose() => _sessionExpired.close();
}
```

Adapt only the two path constants, the key name in the error message and, if
the backend does not use `?code=`, the line that builds `queryParameters` /
`headers`. The rest is generic.

### 4.4 `api_logger.dart` (debug builds only)

Prints every call as `[API] ➡️ POST url`, `[API] ✅ 200 GET url (123 ms)` and the
response body (cut at 1500 characters). It hides the API key (shows only
`code=***(56 chars)` or `<EMPTY KEY>`) and masks `access`, `refresh`,
`password`, and any large secret field (`photoBase64`, `gabarit`…).

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiLogInterceptor extends Interceptor {
  static const _startKey = 'logStart';
  static const _maxBody = 1500;

  static final _secretFields = RegExp(
    r'"(access|refresh|password|photoBase64|gabarit)"\s*:\s*"[^"]*"',
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now().millisecondsSinceEpoch;
    _log('➡️  ${options.method} ${_url(options)}');
    if (options.data != null) _log('   body: ${_clean('${options.data}')}');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final status = response.statusCode ?? 0;
    final icon = status >= 200 && status < 300 ? '✅' : '⚠️';
    _log('$icon $status ${response.requestOptions.method} '
        '${_url(response.requestOptions)} (${_elapsed(response.requestOptions)})');
    _log('   response: ${_clean('${response.data}')}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log('❌ ${err.requestOptions.method} ${_url(err.requestOptions)} '
        '(${_elapsed(err.requestOptions)}): ${err.type.name} ${err.message ?? ''}');
    handler.next(err);
  }

  /// URL with the `code` (API key) value hidden.
  String _url(RequestOptions o) {
    final query = {
      for (final e in o.queryParameters.entries)
        e.key: e.key == 'code'
            ? (e.value.toString().isEmpty
                ? '<EMPTY KEY>'
                : '***(${e.value.toString().length} chars)')
            : e.value,
    };
    final uri = Uri.parse('${o.baseUrl}${o.path}')
        .replace(queryParameters: query.map((k, v) => MapEntry(k, '$v')));
    return Uri.decodeFull(uri.toString());
  }

  String _elapsed(RequestOptions o) {
    final start = o.extra[_startKey] as int?;
    if (start == null) return '?';
    return '${DateTime.now().millisecondsSinceEpoch - start} ms';
  }

  String _clean(String body) {
    var text = body.replaceAllMapped(
      _secretFields,
      (m) => '"${m.group(1)}":"***"',
    );
    // Dart maps print as {key: value}: hide the same fields there.
    text = text.replaceAllMapped(
      RegExp(r'(access|refresh|password|photoBase64|gabarit): [^,}]*'),
      (m) => '${m.group(1)}: ***',
    );
    return text.length > _maxBody
        ? '${text.substring(0, _maxBody)}… (${text.length} chars)'
        : text;
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[API] $message');
  }
}
```

### 4.5 `register_module.dart`

```dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../app/data/api/api_config.dart';
import '../../app/data/api/api_logger.dart';

/// Third-party objects the generated container cannot build by itself.
@module
abstract class RegisterModule {
  @singleton
  FlutterSecureStorage get storage => const FlutterSecureStorage();

  @singleton
  Connectivity get connectivity;

  @lazySingleton
  Dio dio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
    if (kDebugMode) dio.interceptors.add(ApiLogInterceptor());
    return dio;
  }
}
```

---

## 5. Authentication and the saved session

### 5.1 Remote repo

```dart
abstract class RemoteAuthRepo {
  /// `POST /Authentication`: the JSON answer of the login.
  Future<Map<String, dynamic>> login({required String userName, required String password});

  /// `GET /profil`.
  Future<Map<String, dynamic>> getProfile();
}

@LazySingleton(as: RemoteAuthRepo)
class RemoteAuthRepoImpl implements RemoteAuthRepo {
  RemoteAuthRepoImpl(this._api);
  final ApiClient _api;

  @override
  Future<Map<String, dynamic>> login({required String userName, required String password}) async {
    final json = await _api.request(
      'POST', '/Authentication',
      body: {'userName': userName, 'password': password},
    );
    return (json as Map).cast<String, dynamic>();
  }

  @override
  Future<Map<String, dynamic>> getProfile() async =>
      ((await _api.get('/profil')) as Map).cast<String, dynamic>();
}
```

### 5.2 Repo

- `login` returns the user, or `null` when the credentials are wrong (the API
  answers `400` with a known message); every other refusal is rethrown as
  `ApiException` and its message is shown as is.
- `restoreSession` is what keeps the user logged in until logout or uninstall.

```dart
abstract class AuthRepo {
  Future<User?> login(String login, String password);
  Future<User?> restoreSession();
  Future<void> logout();
}

@LazySingleton(as: AuthRepo)
class AuthRepoImpl implements AuthRepo {
  AuthRepoImpl(this.remoteAuthRepo, this.tokenStore);

  static const _wrongCredentials = 'Utilisateur ou mot de passe incorrect';

  final RemoteAuthRepo remoteAuthRepo;
  final TokenStore tokenStore;

  @override
  Future<User?> login(String login, String password) async {
    final Map<String, dynamic> json;
    try {
      json = await remoteAuthRepo.login(userName: login, password: password);
    } on ApiException catch (e) {
      if (e.status == 400 && e.message.contains(_wrongCredentials)) return null;
      rethrow;
    }
    await tokenStore.save(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
    );
    return _userOf(json, login: login);
  }

  @override
  Future<User?> restoreSession() async {
    await tokenStore.load();
    if (tokenStore.refresh == null) return null;
    try {
      // Also renews the access token when it expired (see ApiClient).
      final json = await remoteAuthRepo.getProfile();
      return _userOf(json, login: '${json['userName'] ?? ''}');
    } on NetworkUnavailable {
      // No network at start: stay signed in, the data loads when it is back.
      return const User.empty();
    } on SessionExpired {
      return null;
    } on ApiException {
      // The account is no longer allowed (inactive, wrong role...).
      await tokenStore.clear();
      return null;
    }
  }

  @override
  Future<void> logout() => tokenStore.clear();
}
```

Adapt `User`, `_userOf` and the "wrong credentials" text to the other API.

### 5.3 Service

```dart
@lazySingleton
class AuthService {
  AuthService(this.authRepo /*, other repos holding caches */);

  final AuthRepo authRepo;
  final user = Rxn<User>();

  Future<User?> login(String login, String password) async {
    final result = await authRepo.login(login, password);
    user.value = result;
    return result;
  }

  /// Whether a session saved on the phone is still usable.
  Future<bool> isLogged() async {
    final restored = await authRepo.restoreSession();
    user.value = restored;
    return restored != null;
  }

  Future<void> logout() async {
    await authRepo.logout();
    // also: reset every cache (repo.reset()) and delete private data
    user.value = null;
  }
}
```

### 5.4 Splash decides the start screen

```dart
@injectable
class SplashController extends GetxController {
  SplashController(this.authService);
  final AuthService authService;

  @override
  void onReady() {
    super.onReady();
    _route();
  }

  Future<void> _route() async {
    final logged = await authService.isLogged();
    Get.offAllNamed(logged ? Routes.HOME : Routes.LOGIN);
  }
}
```

The binding **must create the controller at once**:

```dart
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Not lazy: the view never reads `controller`, so a lazy one would never
    // be created and the check would never run (the app stays on the splash).
    Get.put<SplashController>(getIt<SplashController>());
  }
}
```

`AppPages.INITIAL = Routes.SPLASH`.

### 5.5 Session expired anywhere → login

In `main()` after `configureDependencies(Environment.prod)`:

```dart
getIt<ApiClient>().sessionExpired.listen((_) async {
  await getIt<AuthService>().logout();
  Get.offAllNamed(Routes.LOGIN);
});
```

### 5.6 Login controller

- Returns `null` → "wrong credentials" message of the screen.
- Catches `ApiException` → shows `e.message` (inactive account, wrong role,
  missing key, no network...).

---

## 6. Adding a feature (the recipe)

For each endpoint family:

1. **Remote repo method** (raw JSON):

   ```dart
   @override
   Future<Json> getEquipe(String dateKey, {String? filter, String? search,
       int page = 1, int pageSize = 50}) async =>
     ((await _api.get('/equipe', query: {
       'date': dateKey,
       if (filter != null && filter.isNotEmpty) 'filtre': filter,
       if (search != null && search.trim().isNotEmpty) 'recherche': search.trim(),
       'page': page,
       'pageSize': pageSize,
     })) as Map).cast<String, dynamic>();
   ```

   Writes use `_api.write('POST', '/path', body: {...})` and return `ApiResult`
   (`message` is the text to show to the user).

2. **Repo method** that maps JSON to a model. Parse defensively:
   `(json['x'] as num?)?.toInt() ?? 0`, `'${json['name'] ?? ''}'`,
   `DateTime.tryParse(...)`, lists with `(json['items'] as List? ?? const [])`.
3. **Service method** that delegates.
4. **Controller** (`@injectable`) that calls the service in `load()` (section 8).
5. Run `build_runner`.

Parameters that are only known at run time use `@factoryParam`:

```dart
@injectable
class PersonDetailController extends GetxController {
  PersonDetailController(this.appService, @factoryParam this.matricule);
  ...
}
// binding or sheet:
getIt<PersonDetailController>(param1: matricule)
```

Bindings take controllers from the container, never `new`:

```dart
Get.lazyPut<TeamController>(() => getIt<TeamController>());
```

For a controller opened by a bottom sheet, create it in `initState` with a tag
and delete it in `dispose`:

```dart
late final controller = Get.put(getIt<AbsenceController>(param1: id), tag: id);
@override void dispose() { Get.delete<AbsenceController>(tag: id); super.dispose(); }
```

---

## 7. Caching, sharing calls and refreshing

In a repo that serves several screens:

- Keep a cache with a lifetime (`today` 20 s, past days 10 min).
- **Share calls in flight** so controllers that load together make one request:

  ```dart
  return _inFlight[key] ??= _fetch(key).whenComplete(() {
    _inFlight.remove(key);   // block body, see section 17
  });
  ```

- Memoise reference data (`motifs`, lists for pickers) in a `Future?` field
  and reset it to `null` if the call fails.
- Expose `Stream<void> get changes` and `void refresh()` (clears the caches,
  emits). `reset()` clears everything at logout.
- After **every write**, clear the cache and emit `changes`. Controllers that
  listen reload by themselves:

  ```dart
  _changes = appService.changes.listen((_) => load(silent: true));
  ```

- A visible **"Rafraîchir" button** calls `appService.refresh()` then
  `load()` (with the skeleton). Do not rely on pull-to-refresh alone: users do
  not discover it.

---

## 8. Loading states and skeletons

(The full code of every file is in section 13.)

`core/loading/loading_state.dart` (freezed): `loading`, `empty`, `error(message)`,
`loaded`.

`core/loading/loading_state_x.dart`:

```dart
extension LoadingStateRx on Rx<LoadingState?> {
  /// loading → loaded, or error with the message of the failure. A [silent]
  /// reload keeps the current screen on error.
  Future<void> run(Future<void> Function() body, {bool silent = false}) async {
    if (!silent) value = const LoadingState.loading();
    try {
      await body();
      value = const LoadingState.loaded();
    } on ApiException catch (e) {
      debugPrint('[LOAD] ${e.message}');
      if (!silent) value = LoadingState.error(message: e.message);
    } catch (e, stack) {
      debugPrint('[LOAD] $e\n$stack');
      if (!silent) value = LoadingState.error(message: '$e');
    }
  }
}
```

Controller:

```dart
final pageState = Rx<LoadingState?>(const LoadingState.loading());

Future<void> load({bool silent = false}) =>
    pageState.run(silent: silent, () async { ... });
```

View (never a bare `CircularProgressIndicator`):

```dart
Obx(() {
  final placeholder = LoadingStateWrapper.placeholder(
    context,
    controller.pageState.value,
    onReload: controller.load,
    loadingBuilder: (_) => const TeamSkeleton(),   // optional, default list skeleton
  );
  if (placeholder != null) return placeholder;
  return _Content(controller: controller);
})
```

`placeholder` returns the skeleton while loading, an error view with a retry
button on error, and `null` once loaded. Skeleton widgets (`SkeletonShimmer`,
`SkeletonBox`, `SkeletonRow`, `SkeletonRows`, `SkeletonList`) live in
`core/widgets/skeleton.dart`; make one skeleton per screen that mirrors its
layout.

Buttons that send something show a spinner and are disabled while `saving` is
true (`AppButton(loading: controller.saving.value)`).

---

## 9. Pagination

Two cases, do not mix them:

### 9.1 Caches (reference data): read every page

Use `ApiClient.getAllPages(path, query: ...)` (section 4.3). It reads pages of
200 until `page == totalPages` and also accepts a bare array. Use it for
lists that feed pickers or a local cache (circuits, vehicles, templates...).
A list that changed from `[...]` to `{ items: [...] }` silently becomes empty
if you forget this: check every list endpoint after a backend change.

### 9.2 Screens: one page at a time, the server does the work

When the API supports `filtre`, `recherche`, `page`, `pageSize`:

- Send the filter and the search to the server; **do not filter locally**.
- Counters of the filter chips come from the server (`compteurs`), not from
  the page in memory.
- Model of a page:

  ```dart
  class PageInfo {
    const PageInfo({this.page = 1, this.pageSize = 50, this.total = 0, this.totalPages = 1});
    factory PageInfo.of(Map<String, dynamic> json, {int fallbackTotal = 0}) { ... }
    int get firstItem => total == 0 ? 0 : (page - 1) * pageSize + 1;
    int get lastItem  => total == 0 ? 0 : (page * pageSize).clamp(0, total);
  }
  ```

- Controller state: `filter`, `query`, `page`, `pageInfo`, `counters`, and a
  separate `listLoading` flag.

  ```dart
  Future<void> _reloadList() async {
    listLoading.value = true;            // only the rows show a skeleton
    try { await _fetch(); }
    on ApiException catch (e) { showAppToast(e.message); }
    finally { listLoading.value = false; }
  }
  void selectFilter(F f) { if (f == filter.value) return; filter.value = f; page.value = 1; _reloadList(); }
  void goToPage(int n)   { if (n == page.value) return;  page.value = n;   _reloadList(); }
  ```

  `pageState.run` (full-screen skeleton) is for the **first** load only;
  otherwise the header, the search field and the chips would be rebuilt and
  the field would lose the focus while typing.

- Search: debounce 400 ms, reset `page` to 1.

  ```dart
  _searchDebounce?.cancel();
  _searchDebounce = Timer(const Duration(milliseconds: 400), () {
    page.value = 1;
    _reloadList();
  });
  ```

- UI: `PaginationBar(info: ..., onPage: controller.goToPage)` under the list
  (numbered pages with previous / next arrows and "11–20 sur 132"; hidden when
  there is one page). Page size is a constant of the controller (10).
- Several screens that need the **whole** list (pickers, joins) read all
  pages once in the repo and keep them in the cache of section 7.
- When the whole list is already in memory and small, paginate **on the phone**
  (slice of 10, `PageInfo` computed locally, clamp the page when the list
  shrinks).

---

## 10. Models and parsing rules

- Plain Dart classes in `data/models`; JSON stays inside repos.
- Never trust a field: every cast is nullable with a default.
- Dates like `2026-10-27T15:13:51.4159279` (7 fractional digits) parse with
  `DateTime.tryParse`.
- Times without offset (`...T07:15:00`) are local business time: take
  `hour * 60 + minute` instead of converting time zones.
- A name that can come as text **or** as `{ libelle }`: write one helper
  (`_label`) and use it everywhere.
- Server decisions win over local guesses (late, arrival vs exit, status).
  Local computations are only for what is shown **before** the server answers.

---

## 11. Strings and errors shown to the user

- Anything the server can say (`message` of a `400`) is shown as it is.
- Anything the app says is in the ARB files (FR + AR). No hard-coded text in
  widgets. After editing ARB files: `flutter gen-l10n`.
- Controllers that need a localized message outside a widget use
  `AppLocalizations.of(Get.context!)`.

---

## 12. The chain datasource → repo → service, and the injection in `core/di`

Every API call goes through the **same four files**, and the container
(`core/di`) wires them. Nothing is created with `new` outside of tests.

```
lib/app/data/datasources/remote/repos/remote_team_repo.dart   (1) raw calls
lib/app/data/repo/team_repo.dart                               (2) mapping + cache
lib/app/services/app_service.dart                              (3) what controllers call
lib/app/modules/<feature>/controllers/<x>_controller.dart     (4) @injectable
lib/core/di/injection.dart, register_module.dart               container + third-party objects
lib/core/di/injection.config.dart                              GENERATED, never edited
```

### 12.1 One endpoint through the four layers (`GET /types-absence`)

**(1) Remote repo**: abstract class + `Impl`, both in the same file. The only
constructor argument is `ApiClient`.

```dart
// data/datasources/remote/repos/remote_team_repo.dart
abstract class RemoteTeamRepo {
  /// `GET /types-absence`.
  Future<List<Object?>> getAbsenceTypes();
}

@LazySingleton(as: RemoteTeamRepo)
class RemoteTeamRepoImpl implements RemoteTeamRepo {
  RemoteTeamRepoImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<Object?>> getAbsenceTypes() async {
    final json = await _api.get('/types-absence');
    // A list, or an object holding the list.
    if (json is List) return json;
    if (json is Map) return json.values.whereType<List>().firstOrNull ?? const [];
    return const [];
  }
}
```

**(2) Repo** (`data/repo`): abstract class + `Impl`. It receives the **remote
repo through its interface**, maps JSON to models and caches.

```dart
// data/repo/team_repo.dart
abstract class TeamRepo {
  Future<List<AbsenceType>> getAbsenceTypes();
  void refresh();
}

@LazySingleton(as: TeamRepo)
class TeamRepoImpl implements TeamRepo {
  TeamRepoImpl(this._remote, this._location);

  final RemoteTeamRepo _remote;
  final LocationService _location;

  Future<List<AbsenceType>>? _absenceTypes;

  @override
  Future<List<AbsenceType>> getAbsenceTypes() =>
      _absenceTypes ??= _remote.getAbsenceTypes().then((list) {
        return [
          for (final e in list)
            if (e is Map && e['id'] is num)
              AbsenceType(id: (e['id'] as num).toInt(), label: '${e['libelle']}'),
        ];
      }).catchError((Object e) {
        _absenceTypes = null;      // a failed call is not cached
        throw e;
      });

  @override
  void refresh() {
    _absenceTypes = null;
    // ...clear the other caches, then emit `changes`
  }
}
```

**(3) Service** (`app/services/app_service.dart`): `@lazySingleton`, receives
the **repo interfaces**, one line per method. This is the only entry point of
the controllers.

```dart
@lazySingleton
class AppService {
  AppService(this.teamRepo, this.faceTemplateRepo);

  final TeamRepo teamRepo;
  final FaceTemplateRepo faceTemplateRepo;

  Stream<void> get changes => teamRepo.changes;

  Future<List<AbsenceType>> getAbsenceTypes() => teamRepo.getAbsenceTypes();

  void refresh() => teamRepo.refresh();
}
```

`AuthService` is the second service (section 5.3): login state, logout and
the reset of the caches.

**(4) Controller**: `@injectable`, constructor receives the service(s).

```dart
@injectable
class AbsenceController extends GetxController {
  AbsenceController(this.appService, @factoryParam this.matricule);

  final AppService appService;
  final String matricule;

  final pageState = Rx<LoadingState?>(const LoadingState.loading());
  final reasons = <AbsenceType>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => pageState.run(() async {
    reasons.assignAll(await appService.getAbsenceTypes());
  });
}
```

Always **depend on the interface**, not on the `Impl`
(`final RemoteTeamRepo _remote`, never `RemoteTeamRepoImpl`). That is what
makes the fake repos of section 18 possible.

### 12.2 Annotations: which one where

| Class | Annotation | Why |
|---|---|---|
| `ApiClient`, `TokenStore`, services, repos, remote repos | `@lazySingleton` / `@LazySingleton(as: Interface)` | one instance, created on first use |
| Controllers | `@injectable` | a new instance each time (a screen can be opened twice) |
| Controller with a run-time argument | `@injectable` + `@factoryParam` on the argument | `getIt<X>(param1: value, param2: value)` |
| Third-party objects (`Dio`, `FlutterSecureStorage`, `Connectivity`) | `@module` class `RegisterModule` | they have no annotation of their own |

A repo must be registered **as its interface**: `@LazySingleton(as: TeamRepo)`.
Without `as:` the container registers the `Impl` type and
`getIt<TeamRepo>()` fails at run time.

### 12.3 `core/di`

```
core/di/injection.dart          getIt + configureDependencies (section 2)
core/di/register_module.dart    @module: storage, connectivity, Dio (section 4.5)
core/di/injection.config.dart   GENERATED by build_runner
```

Start-up, in `main()`, before `runApp` (and before anything that uses `getIt`):

```dart
WidgetsFlutterBinding.ensureInitialized();
await configureDependencies(Environment.prod);   // import injectable
```

Then run `dart run build_runner build --delete-conflicting-outputs` every time
a class is **added, renamed, moved, or its constructor changes**. The generator
reads the constructors and writes the wiring, for example:

```dart
// injection.config.dart (generated, do not edit)
gh.lazySingleton<_i1072.ApiClient>(
  () => _i1072.ApiClient(gh<_i94.TokenStore>(), gh<_i361.Dio>()),
);
gh.lazySingleton<_i75.RemoteTeamRepo>(
  () => _i75.RemoteTeamRepoImpl(gh<_i1072.ApiClient>()),
);
gh.lazySingleton<_i624.TeamRepo>(
  () => _i624.TeamRepoImpl(gh<_i75.RemoteTeamRepo>(), gh<_i14.LocationService>()),
);
gh.lazySingleton<_i437.AppService>(
  () => _i437.AppService(gh<_i624.TeamRepo>(), gh<_i560.FaceTemplateRepo>()),
);
gh.factoryParam<_i161.PersonDetailController, String, dynamic>(
  (matricule, _) => _i161.PersonDetailController(gh<_i437.AppService>(), matricule),
);
```

If a build fails with "missing dependency" or the app crashes with
`GetIt: Object/factory with type X is not registered`, the cause is almost
always a class without its annotation or a build that was not run.

Dead code from an old structure (old `datasources` registered in the config)
stays in the container as long as its annotations exist: delete the files, then
rebuild.

### 12.4 Adding a new endpoint family (the 6 steps)

1. Remote repo: add the method to the abstract class and the `Impl`.
2. Repo: add the method (mapping, cache) to the interface and the `Impl`.
3. Service: add one delegating line.
4. Controller: call the service in `load()` with `pageState.run`.
5. Rebuild the container (`build_runner`).
6. Add a fake-remote test for the mapping (section 18).

A **new family** (a new remote repo + repo) also needs: a new constructor
argument in the service (`AppService(this.teamRepo, this.newRepo)`) and a
rebuild.

---

## 13. The loading state with skeletons (`core/loading`)

Every screen that loads data uses the same three pieces: a state, an extension
that runs the load, and a wrapper that chooses what to show. No bare
`CircularProgressIndicator` as a page loader.

### 13.1 `core/errors/message_types.dart`

```dart
import 'package:flutter/material.dart';

enum MessageType { danger, primary, warning, success, info }

class MessageTypeColors {
  static const Color danger = Color(0xFFFF597B);
  static const Color success = Color(0xFF4CD964);
  static const Color warning = Color(0xFFF7B500);
  static const Color info = Color(0xFF40C8F1);
}
```

### 13.2 `core/loading/loading_state.dart` (freezed)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:<app>/core/errors/message_types.dart';

part 'loading_state.freezed.dart';

@freezed
abstract class LoadingState with _$LoadingState {
  const factory LoadingState.loading() = LOADING;
  const factory LoadingState.empty() = EMPTY;
  const factory LoadingState.error({String? message, MessageType? type}) = ERROR;
  const factory LoadingState.loaded({String? message, MessageType? type}) = LOADED;
}
```

`loading_state.freezed.dart` is generated by `build_runner` (section 2). The
classes are named in capitals (`LOADING`, `ERROR`...) so that the wrapper can
test `state is LOADING`.

### 13.3 `core/loading/loading_state_x.dart`: run a load

```dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:<app>/app/data/api/api_exception.dart';
import 'loading_state.dart';

extension LoadingStateRx on Rx<LoadingState?> {
  /// The state is loading, then loaded, or error with the message of the
  /// failure. A [silent] reload keeps the current screen on error.
  Future<void> run(Future<void> Function() body, {bool silent = false}) async {
    if (!silent) value = const LoadingState.loading();
    try {
      await body();
      value = const LoadingState.loaded();
    } on ApiException catch (e) {
      debugPrint('[LOAD] ${e.message}');
      if (!silent) value = LoadingState.error(message: e.message);
    } catch (e, stack) {
      debugPrint('[LOAD] $e\n$stack');
      if (!silent) value = LoadingState.error(message: '$e');
    }
  }
}
```

Usage in a controller:

```dart
final pageState = Rx<LoadingState?>(const LoadingState.loading());

Future<void> load({bool silent = false}) =>
    pageState.run(silent: silent, () async { /* calls */ });
```

- First load and "Réessayer": `load()`: skeleton on screen.
- Reload after a write or a change event: `load(silent: true)`: the content
  stays, an error is ignored.
- An uncaught error never leaves the screen loading forever: it becomes `ERROR`.

### 13.4 `core/loading/loading_state_wrapper.dart`

```dart
class LoadingStateWrapper extends StatelessWidget {
  const LoadingStateWrapper({
    super.key,
    required this.state,
    required this.builder,
    this.onReload,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
  });

  final LoadingState? state;
  final WidgetBuilder builder;
  final VoidCallback? onReload;
  final WidgetBuilder? loadingBuilder;   // skeleton; SkeletonList by default
  final WidgetBuilder? errorBuilder;
  final WidgetBuilder? emptyBuilder;

  /// The widget to show while [state] is not loaded, or `null` when the
  /// content itself must be shown. For screens that build their content inline.
  static Widget? placeholder(
    BuildContext context,
    LoadingState? state, {
    VoidCallback? onReload,
    WidgetBuilder? loadingBuilder,
    WidgetBuilder? errorBuilder,
    WidgetBuilder? emptyBuilder,
  }) {
    final s = state;
    if (s == null || s is LOADING) {
      return loadingBuilder != null
          ? Builder(builder: loadingBuilder)
          : const SkeletonList();
    }
    if (s is ERROR) {
      return errorBuilder != null
          ? Builder(builder: errorBuilder)
          : LoadErrorView(message: s.message, onReload: onReload);
    }
    if (s is EMPTY && emptyBuilder != null) return Builder(builder: emptyBuilder);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final placeholderWidget = placeholder(context, state,
        onReload: onReload,
        loadingBuilder: loadingBuilder,
        errorBuilder: errorBuilder,
        emptyBuilder: emptyBuilder);
    if (placeholderWidget != null) return placeholderWidget;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 250),
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: Builder(builder: builder),
    );
  }
}

/// Default error state: what failed and a button to try again.
class LoadErrorView extends StatelessWidget {
  const LoadErrorView({super.key, this.message, this.onReload});

  final String? message;
  final VoidCallback? onReload;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detail = message?.trim() ?? '';
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 44.r, color: AppColors.pending),
            SizedBox(height: 14.h),
            Text(l10n.loadErrorTitle, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800)),
            if (detail.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(detail, maxLines: 4, overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.sp, color: AppColors.muted)),
            ],
            if (onReload != null) ...[
              SizedBox(height: 18.h),
              FilledButton(onPressed: onReload, child: Text(l10n.loadRetry)),
            ],
          ],
        ),
      ),
    );
  }
}
```

ARB strings to add (FR / AR): `loadErrorTitle` ("Impossible de charger les
données"), `loadRetry` ("Réessayer").

### 13.5 Skeleton widgets (`core/widgets/skeleton.dart`)

- `SkeletonShimmer(child)`: paints every opaque block of its child with a moving
  light gradient (1.3 s loop, `ShaderMask` with `BlendMode.srcIn`).
- `SkeletonBox(width, height, radius, circle)`: a grey block (`AppColors.soft`).
- `SkeletonRow`: a card with a circle, two lines and a pill (list row).
- `SkeletonRows(count)`: a column of rows inside a shimmer, for the **rows of a
  list** while a page reloads.
- `SkeletonList(itemCount)`: a non-scrolling `ListView` of rows inside a
  shimmer, the default page skeleton.

```dart
class SkeletonShimmer extends StatefulWidget {
  const SkeletonShimmer({super.key, required this.child});
  final Widget child;
  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) {
          final t = _animation.value;
          return LinearGradient(
            begin: Alignment(-1.5 + 3 * t, -0.3),
            end: Alignment(-0.5 + 3 * t, 0.3),
            colors: const [AppColors.soft, Color(0xFFF6F7F8), AppColors.soft],
            stops: const [0.25, 0.5, 0.75],
          ).createShader(bounds);
        },
        child: child,
      ),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height = 14, this.radius = 8, this.circle = false});
  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) => Container(
        width: width?.w,
        height: height.h,
        decoration: BoxDecoration(
          color: AppColors.soft,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(radius.r),
        ),
      );
}

class SkeletonRow extends StatelessWidget {
  const SkeletonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          SkeletonBox(width: 44, height: 44, circle: true),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 140, height: 14),
                SizedBox(height: 8.h),
                SkeletonBox(width: 90, height: 11),
              ],
            ),
          ),
          SkeletonBox(width: 62, height: 24, radius: 12),
        ],
      ),
    );
  }
}

class SkeletonRows extends StatelessWidget {
  const SkeletonRows({super.key, this.count = 6});
  final int count;

  @override
  Widget build(BuildContext context) => SkeletonShimmer(
        child: Column(children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) SizedBox(height: 8.h),
            const SkeletonRow(),
          ],
        ]),
      );
}

class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.itemCount = 7, this.padding});
  final int itemCount;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => SkeletonShimmer(
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: padding ?? EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
          itemCount: itemCount,
          separatorBuilder: (_, _) => SizedBox(height: 8.h),
          itemBuilder: (_, _) => const SkeletonRow(),
        ),
      );
}
```

For a screen with a header and a particular layout, write a **screen skeleton**
that mirrors it (header block, cards, rows) inside one `SkeletonShimmer`, and
pass it as `loadingBuilder`. The shimmer repaints every grey `SkeletonBox`
inside it, so use only `SkeletonBox` and plain containers there.

### 13.6 In a screen

```dart
Obx(() {
  final placeholder = LoadingStateWrapper.placeholder(
    context,
    controller.pageState.value,
    onReload: controller.load,
    loadingBuilder: (_) => const TeamSkeleton(),   // optional
  );
  if (placeholder != null) return placeholder;
  return _Content(controller: controller);
})
```

And, for a list that reloads **inside** an already displayed screen (filter,
search, page change), a second flag so that the header and the search field
stay:

```dart
Obx(() => controller.listLoading.value
    ? SkeletonRows(count: 6)
    : /* the rows */)
```

---

## 14. The splash (the start screen and the saved session)

The splash shows the brand for the time the saved session is checked, then
opens the home or the login. It makes **one** decision, in the controller; the
view is only a picture.

### 14.1 Files

```
lib/app/modules/splash/
  bindings/splash_binding.dart
  controllers/splash_controller.dart
  views/splash_view.dart
```

### 14.2 View

```dart
class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brand,
      body: Center(
        child: Image.asset('assets/images/logo_cb_w.png', width: 160.w),
      ),
    );
  }
}
```

The view **never reads `controller`**: that is why the binding below cannot be
lazy.

### 14.3 Binding: `Get.put`, not `Get.lazyPut`

```dart
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Not lazy: the view never reads the controller, so a lazy one would never
    // be created and the check would never run (the app stays on the splash).
    Get.put<SplashController>(getIt<SplashController>());
  }
}
```

### 14.4 Controller

```dart
@injectable
class SplashController extends GetxController {
  SplashController(this.authService, this._location);

  final AuthService authService;
  final LocationService _location;     // optional: only if the app needs the GPS

  @override
  void onReady() {
    super.onReady();
    _route();
  }

  Future<void> _route() async {
    final logged = await authService.isLogged();
    Get.offAllNamed(logged ? Routes.HOME : Routes.LOGIN);

    // Optional: once the splash is over, ask for the location (permission, then
    // the phone's "turn on location" dialog). Nothing shows when it is fine.
    await _location.ensureReady();
  }
}
```

`authService.isLogged()` is the saved-session check of section 5: it loads the
stored tokens, calls the profile endpoint (which renews an expired access
token), and returns `false` when there is nothing stored, when the refresh
token is refused, or when the account is no longer allowed. With no network it
returns `true`, so the user stays logged in and the data loads later.

### 14.5 Routes

```dart
// app_pages.dart
static const INITIAL = Routes.SPLASH;

static final routes = [
  GetPage(name: _Paths.SPLASH, page: () => const SplashView(), binding: SplashBinding()),
  GetPage(name: _Paths.HOME,   page: () => const HomeView(),   binding: HomeBinding()),
  GetPage(name: _Paths.LOGIN,  page: () => const LoginView(),  binding: LoginBinding()),
  // ...
];
```

```dart
// main.dart
GetMaterialApp(
  initialRoute: AppPages.INITIAL,
  getPages: AppPages.routes,
  // ...
)
```

And the "session lost" listener of section 5.5 sends the user back to the
login from anywhere.

Logout: `AuthService.logout()` clears the tokens, resets every cache, then
`Get.offAllNamed(Routes.LOGIN)`. The user stays logged in until a logout or an
uninstall, because the tokens are in the secure storage.

---

## 15. The theme and the bold texts

### 15.1 The problem

With `GoogleFonts.xxxTextTheme()` every text style is tied to **one**
regular-weight font file. A `Text` that then asks for `FontWeight.bold` or
`w800` finds no bolder file in that family and keeps drawing the regular one:
titles never get darker or bigger, whatever the weight in the code. Only
styles built directly with `GoogleFonts.xxx(fontWeight: ...)` worked.

### 15.2 The fix: bundle the font files and declare the weights

1. Put the files in `assets/fonts/` (here Barlow and Barlow Condensed from the
   Google Fonts repository, SIL Open Font Licence):

   ```
   Barlow-Regular.ttf  Barlow-Medium.ttf  Barlow-SemiBold.ttf
   Barlow-Bold.ttf     Barlow-ExtraBold.ttf
   BarlowCondensed-SemiBold.ttf  BarlowCondensed-Bold.ttf  BarlowCondensed-ExtraBold.ttf
   ```

2. Declare them with their weights in `pubspec.yaml`:

   ```yaml
   flutter:
     fonts:
       - family: Barlow
         fonts:
           - asset: assets/fonts/Barlow-Regular.ttf
             weight: 400
           - asset: assets/fonts/Barlow-Medium.ttf
             weight: 500
           - asset: assets/fonts/Barlow-SemiBold.ttf
             weight: 600
           - asset: assets/fonts/Barlow-Bold.ttf
             weight: 700
           - asset: assets/fonts/Barlow-ExtraBold.ttf
             weight: 800
       - family: BarlowCondensed
         fonts:
           - asset: assets/fonts/BarlowCondensed-SemiBold.ttf
             weight: 600
           - asset: assets/fonts/BarlowCondensed-Bold.ttf
             weight: 700
           - asset: assets/fonts/BarlowCondensed-ExtraBold.ttf
             weight: 800
   ```

3. Use the family in the theme and **stop using `GoogleFonts` for text**
   (`google_fonts` can be removed from `pubspec.yaml`). A restart is needed:
   new font files are not picked up by hot reload.

Bonus: nothing is downloaded at run time, so the fonts also load offline.

### 15.3 `core/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTheme {
  /// Bundled in `assets/fonts`, so every `FontWeight` finds its own file and
  /// nothing is downloaded.
  static const _family = 'Barlow';

  /// Barlow Condensed, used for numbers and counters.
  static TextStyle numberStyle({double? fontSize, Color? color}) => TextStyle(
        fontFamily: 'BarlowCondensed',
        fontSize: fontSize,
        color: color,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      );

  static ThemeData get light {
    // A plain Material text theme with our family: no GoogleFonts here.
    final base = Typography.material2021().black.apply(
      fontFamily: _family,
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.brand,
      onPrimary: Colors.white,
      secondary: AppColors.acc,
      onSecondary: AppColors.ink,
      error: AppColors.absent,
      surface: AppColors.card,
      onSurface: AppColors.ink,
      outline: AppColors.line,
    );

    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 2),
        );

    return ThemeData(
      useMaterial3: true,
      fontFamily: _family,                 // default family of every Text
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      textTheme: base,
      dividerColor: AppColors.line,
      focusColor: AppColors.focus,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: base.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: border(AppColors.line),
        enabledBorder: border(AppColors.line),
        focusedBorder: border(AppColors.ink),
        errorBorder: border(AppColors.absent),
        focusedErrorBorder: border(AppColors.absent),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: base.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          backgroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: AppColors.line, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: base.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
```

Plug it in `main.dart`: `GetMaterialApp(theme: AppTheme.light, ...)`.

### 15.4 Rules for texts in the screens

- Plain `TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800)` is enough:
  it inherits the family from the theme and the weight now finds its file.
- Titles `w800`, sub-titles `w700`, secondary text `w600`, numbers with
  `AppTheme.numberStyle(...)`.
- Do **not** set `fontFamily` per widget and do **not** build styles with
  `GoogleFonts`.
- Keep colours and sizes in `AppColors` and `ScreenUtil` (`.sp`, `.w`, `.h`,
  `.r`), never in raw numbers repeated in screens.
- If bold ever stops working: check that the weights are declared in
  `pubspec.yaml`, that the file names match, and that the app was restarted.

---

## 16. Migration checklist

1. Add the dependencies (section 2); `build_runner`.
2. Copy `api_config`, `api_exception`, `token_store`, `api_client`,
   `api_logger`, `register_module`, `injection.dart` (section 4); rename the
   key and the two auth paths; add `env.json` + `.gitignore` + run configs.
3. Add `core/errors/message_types.dart`, `core/loading` (state, extension,
   wrapper) and `core/widgets/skeleton.dart` (section 13).
   Bundle the fonts and use the theme of section 15.
4. Auth: remote repo, repo, `AuthService`, the splash of section 14 (view,
   binding with `Get.put`, controller, `INITIAL` route), the
   `sessionExpired` listener in `main`, login controller.
5. For every existing mock or old repo: write remote repo → repo → service →
   controller, delete the old one.
6. Every list endpoint: decide 9.1 (cache, `getAllPages`) or 9.2 (screen, server
   pages).
7. Every screen that loads: `pageState`, `LoadingStateWrapper.placeholder`,
   a skeleton.
8. Every write: spinner on the button, `ApiException.message` in a toast,
   cache cleared + `changes` emitted.
9. `dart run build_runner build --delete-conflicting-outputs`, then
   `flutter analyze`.
10. Test with a fake remote repo (see section 18).

---

## 17. Mistakes already made (do not repeat)

1. **Empty API key** → every call answered `401` and the login looked broken.
   Build and run with `--dart-define-from-file=env.json`; keep the guard that
   throws a readable message.
2. **`whenComplete(() => _inFlight.remove(key))`** returns the removed future
   itself, so `whenComplete` waits for the future it belongs to and never ends
   (the screen loaded forever while the call returned 200). Always use a block
   body: `whenComplete(() { _inFlight.remove(key); })`.
3. **Splash stuck**: `Get.lazyPut` of a controller the view never reads is never
   created. Use `Get.put` for controllers that must run on their own.
4. **`Obx` only tracks what is read while its own builder runs.** Values read in
   a child `StatelessWidget.build` (or a method called later) do not rebuild.
   Read the observables inside an `Obx` in the same widget that displays them.
   This is why a checkbox "did nothing" and why error messages did not appear.
5. **Typing in a search field lost the focus** when the whole screen switched to
   a skeleton on every request. Use a list-only loading flag (section 9.2).
6. **A list changed to `{ items }` and became empty** without any error (face
   templates were overwritten with an empty list). Use `getAllPages`.
7. **`google_fonts` text styles ignore `FontWeight` changes** made afterwards
   (titles stayed regular). Bundle the font files in `assets/fonts` and declare
   the weights in `pubspec.yaml`.
8. **Location**: ask for the permission and the "turn on location" dialog once,
   after the splash; keep a clear message when the phone refuses.
9. **Heredocs with many quotes in shell scripts** break on Windows: write
   scripts to a file instead of inlining them.
10. **Printing Arabic from a Python script** on Windows fails with
    `UnicodeEncodeError`: set `PYTHONIOENCODING=utf-8` or do not print it.

---

## 18. Testing the repos without a server

Fake the remote repo with `noSuchMethod`, so only the methods under test need
to be written:

```dart
class _FakeRemote implements RemoteTeamRepo {
  @override
  Future<Json> getEquipe(String dateKey, {String? filter, String? search,
      int page = 1, int pageSize = 50}) async => { ...sample JSON... };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

test('...', () async {
  final repo = TeamRepoImpl(_FakeRemote(), LocationService());
  expect((await repo.getTeam()).length, 4);
});
```

Test: page merging, filters and counters, date parsing, lateness fields, the
shape of each list endpoint. Run: `flutter test`.

---

## 19. What is specific to Pointage (do not copy)

Team / attendance / history / absences / declarations endpoints and their
models, the face recognition (ML Kit, ONNX model, templates, enrolment), the
GPS service, and the screens built from the HTML prototype. The pattern above
does not depend on any of them.
