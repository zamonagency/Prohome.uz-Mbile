import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/user.dart';
import '../../core/network/api_client.dart';
import '../../core/providers.dart';

class AuthResult {
  AuthResult({required this.accessToken, required this.refreshToken, this.user});
  final String accessToken;
  final String refreshToken;
  final AppUser? user;

  factory AuthResult.fromJson(Map<String, dynamic> j) => AuthResult(
        accessToken: j['accessToken']?.toString() ?? '',
        refreshToken: j['refreshToken']?.toString() ?? '',
        user: j['user'] is Map
            ? AppUser.fromJson(Map<String, dynamic>.from(j['user']))
            : null,
      );
}

enum OtpPurpose { register, login, resetPassword }

extension on OtpPurpose {
  String get api => switch (this) {
        OtpPurpose.register => 'REGISTER',
        OtpPurpose.login => 'LOGIN',
        OtpPurpose.resetPassword => 'RESET_PASSWORD',
      };
}

class AuthRepository {
  AuthRepository(this._api);
  final ApiClient _api;

  Future<void> sendOtp(String phone, OtpPurpose purpose) async {
    await _api.post('/auth/send-otp',
        auth: false, body: {'phone': phone, 'purpose': purpose.api});
  }

  Future<void> verifyOtp(String phone, String otp, OtpPurpose purpose) async {
    await _api.post('/auth/verify-otp',
        auth: false, body: {'phone': phone, 'otp': otp, 'purpose': purpose.api});
  }

  Future<AuthResult> loginOtp(String phone, String otp) async {
    final res = await _api.post('/auth/login/otp',
        auth: false, body: {'phone': phone, 'otp': otp});
    return AuthResult.fromJson(Map<String, dynamic>.from(res as Map));
  }

  Future<AuthResult> loginPassword(String phone, String password) async {
    final res = await _api.post('/auth/login/password',
        auth: false, body: {'phone': phone, 'password': password});
    return AuthResult.fromJson(Map<String, dynamic>.from(res as Map));
  }

  Future<AuthResult> register({
    required String phone,
    required String otp,
    String? firstName,
    String? lastName,
    String? password,
    int? locationId,
  }) async {
    final res = await _api.post('/auth/register', auth: false, body: {
      'phone': phone,
      'otp': otp,
      if (firstName != null && firstName.isNotEmpty) 'firstName': firstName,
      if (lastName != null && lastName.isNotEmpty) 'lastName': lastName,
      if (password != null && password.isNotEmpty) 'password': password,
      if (locationId != null) 'locationId': locationId,
      'entityType': 'USER',
    });
    return AuthResult.fromJson(Map<String, dynamic>.from(res as Map));
  }

  /// `phone, otp, firstName, lastName, experience, skillTypeId, skillIds`
  /// — backendda hammasi majburiy (swagger: `/auth/master/register`).
  /// `salary` bu endpointda umuman yo'q — ro'yxatdan o'tgach alohida
  /// (`MasterRepository.patchMe`) bilan qo'shiladi.
  Future<AuthResult> registerMaster({
    required String phone,
    required String otp,
    required String firstName,
    required String lastName,
    required int experience,
    required int skillTypeId,
    required List<int> skillIds,
    String? bio,
  }) async {
    final res = await _api.post('/auth/master/register', auth: false, body: {
      'phone': phone,
      'otp': otp,
      'firstName': firstName,
      'lastName': lastName,
      'experience': experience,
      'skillTypeId': skillTypeId,
      'skillIds': skillIds,
      if (bio != null && bio.isNotEmpty) 'bio': bio,
    });
    return AuthResult.fromJson(Map<String, dynamic>.from(res as Map));
  }

  Future<void> resetPassword({
    required String phone,
    required String otp,
    required String password,
  }) async {
    await _api.post('/auth/reset-password',
        auth: false, body: {'phone': phone, 'otp': otp, 'password': password});
  }

  Future<AppUser> me() async {
    final res = await _api.get('/users/me');
    return AppUser.fromJson(Map<String, dynamic>.from(res as Map));
  }

  Future<AppUser> updateMe(Map<String, dynamic> patch) async {
    final res = await _api.patch('/users/me', body: patch);
    return AppUser.fromJson(Map<String, dynamic>.from(res as Map));
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

/// `+998 90 123 45 67` / `901234567` / `0901234567` → `+998901234567`
String normalizePhone(String value) {
  var digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';
  while (digits.startsWith('998') && digits.length > 12) {
    digits = digits.substring(3);
  }
  if (digits.startsWith('998')) return '+${digits.substring(0, digits.length.clamp(0, 12))}';
  if (digits.startsWith('0') && digits.length <= 10) return '+998${digits.substring(1)}';
  if (digits.startsWith('8') && digits.length == 10) return '+998${digits.substring(1)}';
  if (digits.length <= 9) return '+998$digits';
  return '+${digits.substring(0, digits.length.clamp(0, 15))}';
}

bool isValidPhone(String value) =>
    value.replaceAll(RegExp(r'\D'), '').length >= 12;

String prettyPhone(String value) {
  final n = normalizePhone(value);
  final d = n.replaceAll(RegExp(r'\D'), '');
  if (!d.startsWith('998') || d.length < 12) return n;
  final l = d.substring(3);
  return '+998 ${l.substring(0, 2)} ${l.substring(2, 5)} ${l.substring(5, 7)} ${l.substring(7, 9)}';
}
