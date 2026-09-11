/// Muhit sozlamalari. `--dart-define` orqali qayta yozish mumkin:
///   flutter run --dart-define=API_URL=https://api-b2c.prohome.uz
class Env {
  Env._();

  /// Asosiy B2C backend (auth, real-estates, masters, jobs, chat, ...).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api-b2c.prohome.uz',
  );

  /// "Advanced" B2C API (yangi binolar / rooms).
  static const String b2cApiBaseUrl = String.fromEnvironment(
    'B2C_API_URL',
    defaultValue: 'https://backend.prohome.uz/api/v1',
  );

  /// Wenny (joymee.uz uslubidagi) marketpleys API.
  static const String wennyApiBaseUrl = String.fromEnvironment(
    'WENNY_API_URL',
    defaultValue: 'https://backen.prohome.uz/api',
  );

  /// OLX dan yig'ilgan e'lonlar (frontend bilan birga tarqatiladigan JSON).
  static const String olxFeedUrl = String.fromEnvironment(
    'OLX_FEED_URL',
    defaultValue: 'https://prohome.uz/olx-real-estates.json',
  );

  /// Media (rasm/video) uchun asos. Ko'pincha [apiBaseUrl] bilan bir xil.
  static const String mediaBaseUrl = String.fromEnvironment(
    'MEDIA_URL',
    defaultValue: 'https://api-b2c.prohome.uz',
  );

  /// Veb-sayt (ulashish uchun ochiq havolalar shu yerga qurib beriladi —
  /// masalan `$webBaseUrl/real-estates/91`). Android/iOS tomonda App Links /
  /// Universal Links sozlansa, xuddi shu havola ilovani to'g'ridan-to'g'ri
  /// ochadi; sozlanmagan bo'lsa — brauzerda saytning o'zi ochiladi.
  static const String webBaseUrl = String.fromEnvironment(
    'WEB_URL',
    defaultValue: 'https://prohome.uz',
  );

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);

  static const bool enableHttpLogs =
      bool.fromEnvironment('HTTP_LOGS', defaultValue: true);
}
