import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/settings_controller.dart';
import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import '../models/paginated.dart';

/// `GET {b2cApiBaseUrl}/currency/usd` -> { ccy, rate, date }.
class CurrencyRepository {
  CurrencyRepository(this._api);
  final ApiClient _api;

  Future<double?> usdRate() async {
    try {
      final res = await _api.get('/currency/usd',
          baseUrl: Env.b2cApiBaseUrl, auth: false);
      final map = res is Map ? Map<String, dynamic>.from(res) : const {};
      return asDouble(map['rate']);
    } catch (_) {
      return null;
    }
  }
}

final currencyRepositoryProvider = Provider<CurrencyRepository>(
  (ref) => CurrencyRepository(ref.watch(apiClientProvider)),
);

/// Ilova ochilganda bir marta chaqiriladi (`app.dart`) — jonli kursni
/// yuklab, [SettingsController]ga yozadi. Yuklanguncha oxirgi keshlangan
/// (yoki standart 12900) qiymat ishlatilaveradi — narxlar hech qachon
/// bo'sh ko'rinmaydi.
final usdRateSyncProvider = FutureProvider<void>((ref) async {
  final rate = await ref.watch(currencyRepositoryProvider).usdRate();
  if (rate != null && rate > 0) {
    await ref.read(settingsProvider.notifier).setUsdRate(rate);
  }
});
