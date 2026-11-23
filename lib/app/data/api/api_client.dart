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

/// HTTP client of the Pointage API: headers, token refresh and error mapping
/// (see section 3 of the API guide).
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
        '--dart-define=POINTAGE_API_KEY=<clé>',
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
