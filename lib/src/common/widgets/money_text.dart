import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/settings_controller.dart';
import '../../core/utils/formatters.dart';

/// Narxni tanlangan valyutada (UZS/USD) ko'rsatadi.
/// [value] doim USD da bo'ladi (backend shu tarzda qaytaradi); UZS
/// tanlanganda joriy kursga (`settingsProvider.usdRate`) ko'paytiriladi.
class MoneyText extends ConsumerWidget {
  const MoneyText(this.value, {super.key, this.style});
  final dynamic value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    return Text(
      money(value, usd: s.currency == AppCurrency.usd, rate: s.usdRate),
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Riverpod'siz joylar uchun (masalan `WidgetRef` bor bo'lsa).
String moneyOf(dynamic value, AppSettings s) =>
    money(value, usd: s.currency == AppCurrency.usd, rate: s.usdRate);
