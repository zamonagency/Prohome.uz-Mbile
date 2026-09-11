import 'package:intl/intl.dart';

// 'en_US' har doim mavjud — lokal ma'lumot init qilish shart emas.
final _priceFmt = NumberFormat('#,##0', 'en_US');

/// 125000000 -> "125 000 000". null/0 -> "".
String formatPrice(dynamic value) {
  final n = _toNum(value);
  if (n == null || n == 0) return '';
  return _priceFmt.format(n).replaceAll(',', ' ');
}

/// 12500 -> "12,5 mln" kabi qisqartma.
String compactPrice(dynamic value) {
  final n = _toNum(value);
  if (n == null || n == 0) return '—';
  if (n >= 1000000000) return '${(n / 1000000000).toStringAsFixed(1)} mlrd';
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)} mln';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)} ming';
  return n.toStringAsFixed(0);
}

/// Backend narxlarni USD da qaytaradi (masalan 39500 == $39 500).
/// [usd] true bo'lsa shu holicha "$" bilan, aks holda [rate] (1 USD = ? so'm)
/// bo'yicha so'mga aylantirib ko'rsatiladi.
String money(dynamic usdValue, {required bool usd, double rate = 12900}) {
  final n = _toNum(usdValue);
  if (n == null || n == 0) return 'Kelishilgan';
  if (usd) {
    return '\$${_priceFmt.format(n.round()).replaceAll(',', ' ')}';
  }
  final sum = n * (rate <= 0 ? 12900 : rate);
  return "${_priceFmt.format(sum.round()).replaceAll(',', ' ')} so'm";
}

String formatArea(dynamic value) {
  final n = _toNum(value);
  if (n == null || n == 0) return '';
  return '${n % 1 == 0 ? n.toInt() : n} m²';
}

String formatDate(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final d = DateTime.tryParse(iso);
  if (d == null) return '';
  return DateFormat('dd.MM.yyyy').format(d.toLocal());
}

String formatDateTime(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final d = DateTime.tryParse(iso);
  if (d == null) return '';
  return DateFormat('dd.MM.yyyy HH:mm').format(d.toLocal());
}

num? _toNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  return num.tryParse(v.toString().replaceAll(RegExp(r'[^0-9.\-]'), ''));
}

extension StringCap on String {
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
