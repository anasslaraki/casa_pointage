import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Prints every API call (debug builds only): method, URL, status, time and
/// bodies. The API key, the tokens, passwords, photos and face templates are
/// hidden.
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
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final status = response.statusCode ?? 0;
    final icon = status >= 200 && status < 300 ? '✅' : '⚠️';
    _log(
      '$icon $status ${response.requestOptions.method} '
      '${_url(response.requestOptions)} (${_elapsed(response.requestOptions)})',
    );
    _log('   response: ${_clean('${response.data}')}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(
      '❌ ${err.requestOptions.method} ${_url(err.requestOptions)} '
      '(${_elapsed(err.requestOptions)}): ${err.type.name} ${err.message ?? ''}',
    );
    handler.next(err);
  }

  /// URL with the `code` (API key) value hidden.
  String _url(RequestOptions o) {
    final query = {
      for (final e in o.queryParameters.entries)
        // Show only whether a key was sent and how long it is.
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
