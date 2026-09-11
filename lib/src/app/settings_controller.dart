import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/strings.dart';

enum AppCurrency { uzs, usd }

extension AppCurrencyX on AppCurrency {
  String get code => name;
  String get symbol => this == AppCurrency.usd ? "\$" : "so'm";
  // Standart — dollar; foydalanuvchi o'zi so'mga o'tguncha shunday qoladi.
  static AppCurrency fromCode(String? c) =>
      c == 'uzs' ? AppCurrency.uzs : AppCurrency.usd;
}

class AppSettings {
  const AppSettings({
    this.lang = AppLang.uz,
    this.themeMode = ThemeMode.system,
    this.currency = AppCurrency.usd,
    this.usdRate = 12900,
  });
  final AppLang lang;
  final ThemeMode themeMode;
  final AppCurrency currency;

  /// 1 USD necha so'm (narxlarni USD ga aylantirish uchun).
  final double usdRate;

  AppSettings copyWith({
    AppLang? lang,
    ThemeMode? themeMode,
    AppCurrency? currency,
    double? usdRate,
  }) =>
      AppSettings(
        lang: lang ?? this.lang,
        themeMode: themeMode ?? this.themeMode,
        currency: currency ?? this.currency,
        usdRate: usdRate ?? this.usdRate,
      );
}

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._prefs) : super(const AppSettings()) {
    _load();
  }

  final SharedPreferences _prefs;
  static const _kLang = 'ph_lang';
  static const _kTheme = 'ph_theme';
  static const _kCurrency = 'ph_currency';
  static const _kRate = 'ph_usd_rate';

  void _load() {
    final lang = AppLangX.fromCode(_prefs.getString(_kLang));
    final theme = switch (_prefs.getString(_kTheme)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    state = AppSettings(
      lang: lang,
      themeMode: theme,
      currency: AppCurrencyX.fromCode(_prefs.getString(_kCurrency)),
      usdRate: _prefs.getDouble(_kRate) ?? 12900,
    );
  }

  Future<void> setLang(AppLang lang) async {
    state = state.copyWith(lang: lang);
    await _prefs.setString(_kLang, lang.code);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(_kTheme, mode.name);
  }

  Future<void> toggleTheme(Brightness current) async {
    await setThemeMode(
        current == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> setCurrency(AppCurrency c) async {
    state = state.copyWith(currency: c);
    await _prefs.setString(_kCurrency, c.code);
  }

  Future<void> setUsdRate(double r) async {
    state = state.copyWith(usdRate: r);
    await _prefs.setDouble(_kRate, r);
  }
}

/// `main()` da override qilinadi.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider override qilinmagan'),
);

final settingsProvider =
    StateNotifierProvider<SettingsController, AppSettings>((ref) {
  return SettingsController(ref.watch(sharedPrefsProvider));
});

final localeProvider = Provider<AppLang>((ref) {
  return ref.watch(settingsProvider.select((s) => s.lang));
});

final stringsProvider = Provider<AppStrings>((ref) {
  return AppStrings(ref.watch(localeProvider));
});

final currencyProvider = Provider<AppCurrency>(
  (ref) => ref.watch(settingsProvider.select((s) => s.currency)),
);

