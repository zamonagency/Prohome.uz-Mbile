import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/settings_controller.dart';
import '../../common/models/user.dart';
import '../../core/providers.dart';
import '../masters/master_repository.dart';
import '../notifications/push_notifications_controller.dart';
import 'auth_repository.dart';

enum AuthStatus { unknown, authenticated, guest }

class AuthState {
  const AuthState({this.status = AuthStatus.unknown, this.user});

  final AuthStatus status;
  final AppUser? user;

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isReady => status != AuthStatus.unknown;

  AuthState copyWith({AuthStatus? status, AppUser? user, bool clearUser = false}) =>
      AuthState(
        status: status ?? this.status,
        user: clearUser ? null : (user ?? this.user),
      );
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthState()) {
    _bootstrap();
  }

  final Ref _ref;
  static const _kUser = 'ph_user';

  SharedPreferences get _prefs => _ref.read(sharedPrefsProvider);
  AuthRepository get _repo => _ref.read(authRepositoryProvider);

  Future<void> _bootstrap() async {
    final cachedRaw = _prefs.getString(_kUser);
    String? access;
    try {
      access = await _ref.read(tokenStorageProvider).readAccess();
    } catch (_) {
      access = null;
    }

    if (access == null || access.isEmpty) {
      state = const AuthState(status: AuthStatus.guest);
      return;
    }

    if (cachedRaw != null) {
      try {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: AppUser.fromJson(
              Map<String, dynamic>.from(jsonDecode(cachedRaw) as Map)),
        );
      } catch (_) {}
    }

    // Fon rejimida yangilaymiz.
    try {
      final fresh = await _repo.me();
      await _cacheUser(fresh);
      state = AuthState(status: AuthStatus.authenticated, user: fresh);
      // Ilova qayta ochilganda ham (masalan token yangilangan bo'lsa)
      // qurilma push uchun ro'yxatdan o'tganligiga ishonch hosil qilamiz.
      unawaited(_ref.read(pushNotificationsControllerProvider).registerToken());
    } catch (_) {
      if (state.user == null) {
        state = const AuthState(status: AuthStatus.guest);
      }
    }
  }

  Future<void> _cacheUser(AppUser user) async {
    await _prefs.setString(_kUser, jsonEncode(user.toJson()));
  }

  Future<void> _applyAuth(AuthResult result) async {
    await _ref.read(tokenStorageProvider).save(
          access: result.accessToken,
          refresh: result.refreshToken,
        );
    AppUser? user = result.user;
    if (user == null) {
      try {
        user = await _repo.me();
      } catch (_) {
        // Token saqlandi, lekin profilni olib bo'lmadi — keyinroq qayta urinamiz.
      }
    }
    if (user != null) await _cacheUser(user);
    state = AuthState(
      status: AuthStatus.authenticated,
      user: user ??
          const AppUser(id: 0, firstName: 'Foydalanuvchi'),
    );
    // Push: shu qurilmani endi shu foydalanuvchiga bog'lab qo'yamiz.
    unawaited(_ref.read(pushNotificationsControllerProvider).registerToken());
  }

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> sendOtp(String phone, OtpPurpose purpose) =>
      _repo.sendOtp(phone, purpose);

  Future<void> loginWithOtp(String phone, String otp) async {
    final r = await _repo.loginOtp(phone, otp);
    await _applyAuth(r);
  }

  Future<void> loginWithPassword(String phone, String password) async {
    final r = await _repo.loginPassword(phone, password);
    await _applyAuth(r);
  }

  Future<void> register({
    required String phone,
    required String otp,
    String? firstName,
    String? lastName,
    String? password,
    int? locationId,
  }) async {
    final r = await _repo.register(
      phone: phone,
      otp: otp,
      firstName: firstName,
      lastName: lastName,
      password: password,
      locationId: locationId,
    );
    await _applyAuth(r);
  }

  Future<void> registerAsMaster({
    required String phone,
    required String otp,
    required String firstName,
    required String lastName,
    required int experience,
    required int skillTypeId,
    required List<int> skillIds,
    num? salary,
    String? bio,
  }) async {
    final r = await _repo.registerMaster(
      phone: phone,
      otp: otp,
      firstName: firstName,
      lastName: lastName,
      experience: experience,
      skillTypeId: skillTypeId,
      skillIds: skillIds,
      bio: bio,
    );
    await _applyAuth(r);
    // Narx (salary) shu endpointda qabul qilinmaydi — alohida, best-effort.
    if (salary != null) {
      await _ref.read(masterRepositoryProvider).patchMe(salary: salary);
    }
  }

  Future<void> refreshMe() async {
    if (!state.isAuthenticated) return;
    try {
      final fresh = await _repo.me();
      await _cacheUser(fresh);
      state = state.copyWith(user: fresh);
    } catch (_) {}
  }

  Future<void> updateProfile(Map<String, dynamic> patch) async {
    final updated = await _repo.updateMe(patch);
    await _cacheUser(updated);
    state = state.copyWith(user: updated);
  }

  Future<void> logout() async {
    // Token hali login bo'lgan holatda o'chirilishi kerak — endpoint
    // auth talab qiladi, shuning uchun tokenStorage tozalanishidan OLDIN.
    await _ref.read(pushNotificationsControllerProvider).unregisterToken();
    await _ref.read(tokenStorageProvider).clear();
    await _prefs.remove(_kUser);
    state = const AuthState(status: AuthStatus.guest);
  }

  Future<void> handleSessionExpired() async {
    await logout();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) => AuthController(ref));

final currentUserProvider = Provider<AppUser?>(
  (ref) => ref.watch(authControllerProvider).user,
);

final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authControllerProvider).isAuthenticated,
);
