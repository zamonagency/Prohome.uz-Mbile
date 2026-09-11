import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../config/env.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

typedef VoidCallbackAsync = FutureOr<void> Function();

/// Butun ilova uchun yagona HTTP client.
///
/// - `Authorization: Bearer <access>` sarlavhasini avtomatik qo'shadi;
/// - 401 bo'lsa `/auth/refresh` orqali tokenni yangilaydi va so'rovni takrorlaydi;
/// - refresh ham muvaffaqiyatsiz bo'lsa [onSessionExpired] chaqiriladi.
class ApiClient {
  ApiClient({required this.tokens, this.onSessionExpired}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: Env.connectTimeout,
        receiveTimeout: Env.receiveTimeout,
        headers: {'Accept': 'application/json'},
        // 4xx larni ham javob sifatida qabul qilamiz — o'zimiz ishlaymiz.
        validateStatus: (s) => s != null && s < 500,
      ),
    );
    _dio.interceptors.add(_authInterceptor());
    if (Env.enableHttpLogs) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: false,
        logPrint: (o) => _log(o.toString()),
      ));
    }
    _tunePersistentConnections(_dio);

    _plain = Dio(BaseOptions(
      connectTimeout: Env.connectTimeout,
      receiveTimeout: Env.receiveTimeout,
      validateStatus: (s) => s != null && s < 500,
    ));
    _tunePersistentConnections(_plain);
  }

  /// `ApiClient` (demak — shu `Dio`) butun ilova umri davomida BITTA marta
  /// yaratiladi (`apiClientProvider` — Riverpod `Provider`, avtomatik
  /// dispose qilinmaydi), shuning uchun har so'rov uchun yangi HTTP
  /// ulanish OCHILMAYDI. Bu yerda esa ostidagi `HttpClient`ni ham
  /// tarmoq bo'yicha bir nechta parallel ulanishni saqlab turadigan,
  /// bo'sh turgan ulanishni uzoqroq ochiq qoldiradigan qilib sozlaymiz —
  /// keyingi so'rov TCP/TLS handshake'ni qaytadan qilmasdan, mavjud
  /// ulanishni qayta ishlatadi (keep-alive).
  void _tunePersistentConnections(Dio dio) {
    final adapter = dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        final client = HttpClient();
        client.maxConnectionsPerHost = 6;
        client.idleTimeout = const Duration(seconds: 30);
        client.autoUncompress = true;
        return client;
      };
    }
  }

  final TokenStorage tokens;
  final VoidCallbackAsync? onSessionExpired;

  late final Dio _dio;
  late final Dio _plain;

  Completer<bool>? _refreshing;

  Dio get raw => _dio;

  // ── Public helpers ────────────────────────────────────────────────────────

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    String? baseUrl,
    bool auth = true,
  }) =>
      _request('GET', path, query: query, baseUrl: baseUrl, auth: auth);

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    String? baseUrl,
    bool auth = true,
  }) =>
      _request('POST', path,
          body: body, query: query, baseUrl: baseUrl, auth: auth);

  Future<dynamic> patch(String path, {Object? body, bool auth = true}) =>
      _request('PATCH', path, body: body, auth: auth);

  Future<dynamic> delete(String path, {Object? body, bool auth = true}) =>
      _request('DELETE', path, body: body, auth: auth);

  /// Ixtiyoriy tashqi JSON (masalan, OLX feed yoki Wenny).
  Future<dynamic> getExternal(String url, {Map<String, dynamic>? query}) async {
    try {
      final res = await _plain.get(url, queryParameters: query);
      if (res.statusCode != null && res.statusCode! >= 400) {
        throw ApiException('Maʼlumot topilmadi', statusCode: res.statusCode);
      }
      return res.data;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<dynamic> multipart(
    String path, {
    required FormData form,
    String method = 'POST',
  }) =>
      _request(method, path, body: form, auth: true, isMultipart: true);

  // ── Internals ─────────────────────────────────────────────────────────────

  Future<dynamic> _request(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    String? baseUrl,
    bool auth = true,
    bool isMultipart = false,
  }) async {
    // Dio `Options` da `baseUrl` yo'q — boshqa host kerak bo'lsa to'liq URL beramiz.
    final target = (baseUrl != null && baseUrl.isNotEmpty) ? '$baseUrl$path' : path;
    try {
      final res = await _dio.request(
        target,
        data: body,
        queryParameters: query,
        options: Options(
          method: method,
          extra: {'auth': auth},
          contentType: isMultipart ? 'multipart/form-data' : null,
        ),
      );
      final status = res.statusCode ?? 0;
      if (status >= 400) {
        throw ApiException.fromDio(DioException.badResponse(
          statusCode: status,
          requestOptions: res.requestOptions,
          response: res,
        ));
      }
      return res.data;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final needsAuth = options.extra['auth'] != false;
        if (needsAuth) {
          final t = await tokens.readAccess();
          if (t != null && t.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $t';
          }
        }
        handler.next(options);
      },
      onResponse: (res, handler) async {
        final needsAuth = res.requestOptions.extra['auth'] != false;
        final isAuthCall = res.requestOptions.path.contains('/auth/');
        final alreadyRetried = res.requestOptions.extra['__retried'] == true;
        if (res.statusCode == 401 &&
            needsAuth &&
            !isAuthCall &&
            !alreadyRetried) {
          final ok = await _tryRefresh();
          if (ok) {
            try {
              res.requestOptions.extra['__retried'] = true;
              final retry = await _dio.fetch(res.requestOptions);
              return handler.resolve(retry);
            } catch (_) {/* fallthrough */}
          } else {
            await onSessionExpired?.call();
          }
        }
        handler.next(res);
      },
    );
  }

  Future<bool> _tryRefresh() {
    if (_refreshing != null) return _refreshing!.future;
    final c = Completer<bool>();
    _refreshing = c;

    () async {
      try {
        final refresh = await tokens.readRefresh();
        if (refresh == null || refresh.isEmpty) {
          c.complete(false);
          return;
        }
        final res = await _plain.post(
          '${Env.apiBaseUrl}/auth/refresh',
          data: {'refreshToken': refresh},
        );
        final data = res.data;
        if (res.statusCode == 200 && data is Map && data['accessToken'] != null) {
          await tokens.save(
            access: data['accessToken'] as String,
            refresh: (data['refreshToken'] ?? refresh) as String,
          );
          c.complete(true);
        } else {
          await tokens.clear();
          c.complete(false);
        }
      } catch (_) {
        c.complete(false);
      } finally {
        _refreshing = null;
      }
    }();

    return c.future;
  }

  void _log(String msg) {
    // ignore: avoid_print
    assert(() {
      // ignore: avoid_print
      print('[http] $msg');
      return true;
    }());
  }
}
