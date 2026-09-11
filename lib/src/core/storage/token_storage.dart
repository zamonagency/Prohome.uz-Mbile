import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Access/refresh tokenlarni xavfsiz saqlash (Keystore / Keychain).
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  static const _kAccess = 'ph_access_token';
  static const _kRefresh = 'ph_refresh_token';

  String? _accessCache;
  String? _refreshCache;

  Future<void> save({required String access, required String refresh}) async {
    _accessCache = access;
    _refreshCache = refresh;
    await _storage.write(key: _kAccess, value: access);
    await _storage.write(key: _kRefresh, value: refresh);
  }

  Future<String?> readAccess() async =>
      _accessCache ??= await _storage.read(key: _kAccess);

  Future<String?> readRefresh() async =>
      _refreshCache ??= await _storage.read(key: _kRefresh);

  Future<void> clear() async {
    _accessCache = null;
    _refreshCache = null;
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }
}
