import 'package:dio/dio.dart';

/// Ilova bo'ylab yagona xato turi. UI shu obyektdan `message` ni ko'rsatadi.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.messages = const []});

  final String message;
  final int? statusCode;
  final List<String> messages;

  bool get isNetwork => statusCode == null || statusCode == 0 || statusCode == 503;
  bool get isUnauthorized => statusCode == 401;
  bool get isServer => (statusCode ?? 0) >= 500;
  bool get isTimeout => statusCode == 408;

  @override
  String toString() => 'ApiException($statusCode): $message';

  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException("So'rov vaqti tugadi. Qayta urinib ko'ring.",
            statusCode: 408);
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return ApiException(
          "Internet yoki server bilan aloqa yo'q. Keyinroq urinib ko'ring.",
          statusCode: 503,
        );
      case DioExceptionType.badCertificate:
        return ApiException('Xavfsiz ulanishda muammo (sertifikat).',
            statusCode: 495);
      case DioExceptionType.cancel:
        return ApiException("So'rov bekor qilindi.", statusCode: 0);
      case DioExceptionType.badResponse:
        return ApiException._fromResponse(e.response);
      default:
        return ApiException(
          e.message ?? "Tarmoq xatosi. Qayta urinib ko'ring.",
          statusCode: 503,
        );
    }
  }

  factory ApiException._fromResponse(Response? res) {
    final status = res?.statusCode ?? 0;
    final data = res?.data;
    final parsed = <String>[];
    if (data is Map) {
      final m = data['message'] ?? data['error'];
      if (m is String) parsed.add(m);
      if (m is List) parsed.addAll(m.map((e) => e.toString()));
    } else if (data is String && data.trim().isNotEmpty) {
      parsed.add(data);
    }
    final fallback = status >= 500
        ? 'Serverda vaqtinchalik muammo bor. Birozdan keyin urinib ko\'ring.'
        : 'Kutilmagan xatolik yuz berdi. Qayta urinib ko\'ring.';
    return ApiException(
      parsed.isNotEmpty ? parsed.first : fallback,
      statusCode: status,
      messages: parsed,
    );
  }
}
