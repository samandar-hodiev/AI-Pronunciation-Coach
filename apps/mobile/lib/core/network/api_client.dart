import 'dart:async';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'api_exception.dart';

/// Backend bilan ishlaydigan yagona HTTP mijoz.
///
/// Ekranlar to'g'ridan-to'g'ri HTTP so'rov yubormaydi — hammasi shu qatlamdan
/// o'tadi. Shu sababli xato o'girish, tokenni qo'shish va manzilni sozlash
/// bitta joyda saqlanadi.
class ApiClient {
  ApiClient({Dio? dio, this.tokenProvider}) : _dio = dio ?? Dio() {
    // Sozlamalar tashqaridan berilgan `Dio` ga ham qo'llanadi.
    //
    // Aks holda inyeksiya qilingan mijoz `validateStatus` siz qolar va 4xx
    // javoblar tarmoq xatosi sifatida qayta ishlanardi — natijada backend
    // bergan aniq xato kodi ("EMAIL_ALREADY_REGISTERED" kabi) yo'qolardi.
    if (_dio.options.baseUrl.isEmpty) {
      _dio.options.baseUrl = AppConfig.apiBaseUrl;
    }
    _dio.options
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 15)
      ..contentType = Headers.jsonContentType
      // Xato statuslarni istisno sifatida emas, javob sifatida olamiz —
      // shunda backend bergan xato matni va kodi o'qiladi.
      ..validateStatus = (int? status) => status != null && status < 500;
  }

  final Dio _dio;

  /// Har bir so'rovdan oldin joriy tokenni beradi. `null` bo'lsa sarlavha
  /// qo'shilmaydi.
  final Future<String?> Function()? tokenProvider;

  /// JSON POST so'rovi.
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) {
    return _send(
      () async => _dio.post<dynamic>(
        path,
        data: body,
        options: Options(headers: await _headers(authenticated)),
      ),
    );
  }

  /// JSON GET so'rovi.
  Future<Map<String, dynamic>> get(String path, {bool authenticated = false}) {
    return _send(
      () async => _dio.get<dynamic>(
        path,
        options: Options(headers: await _headers(authenticated)),
      ),
    );
  }

  Future<Map<String, String>> _headers(bool authenticated) async {
    if (!authenticated) return <String, String>{};

    final String? token = await tokenProvider?.call();
    if (token == null || token.isEmpty) return <String, String>{};

    return <String, String>{'Authorization': 'Bearer $token'};
  }

  Future<Map<String, dynamic>> _send(
    Future<Response<dynamic>> Function() request,
  ) async {
    late final Response<dynamic> response;
    try {
      response = await request();
    } on DioException catch (e) {
      throw _networkException(e);
    } catch (_) {
      throw const ApiException(
        message: 'Something went wrong. Please try again.',
      );
    }

    final dynamic data = response.data;
    final Map<String, dynamic> json = data is Map<String, dynamic>
        ? data
        : <String, dynamic>{};

    final int status = response.statusCode ?? 0;
    if (status >= 200 && status < 300) {
      return json;
    }

    throw _serverException(json, status);
  }

  /// Backend xatosini [ApiException] ga o'giradi.
  ///
  /// Matn backenddan olinadi, chunki u allaqachon foydalanuvchi uchun
  /// yozilgan. Kutilmagan shakldagi javob uchun umumiy matn ishlatiladi.
  ApiException _serverException(Map<String, dynamic> json, int status) {
    final Object? error = json['error'];
    if (error is Map<String, dynamic>) {
      final Object? message = error['message'];
      final Object? code = error['code'];
      if (message is String && message.isNotEmpty) {
        return ApiException(
          message: message,
          code: code is String ? code : null,
          statusCode: status,
        );
      }
    }

    return ApiException(
      message: 'Something went wrong. Please try again.',
      statusCode: status,
    );
  }

  /// Tarmoq xatosini foydalanuvchi tushunadigan matnga o'giradi.
  ApiException _networkException(DioException e) {
    final String message = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'The connection timed out. Please try again.',
      DioExceptionType.connectionError =>
        'Cannot reach the server. Check your internet connection.',
      _ => 'Something went wrong. Please try again.',
    };

    return ApiException(message: message, statusCode: e.response?.statusCode);
  }
}
