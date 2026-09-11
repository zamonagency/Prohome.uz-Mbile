import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> dialPhone(BuildContext context, String phone) async {
  final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  if (clean.isEmpty) return;
  final uri = Uri(scheme: 'tel', path: clean);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Qo‘ng‘iroq qilib bo‘lmadi: $clean')),
    );
  }
}

/// Telefon raqami bo'yicha Telegramda suhbat ochishga urinadi
/// (raqam Telegramda ro'yxatdan o'tgan bo'lsagina ishlaydi).
Future<void> openTelegram(BuildContext context, String phone) async {
  final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  if (clean.isEmpty) return;
  final uri = Uri.parse('https://t.me/$clean');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Telegram topilmadi')));
  }
}

Future<void> openUrlExternal(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Ochib bo‘lmadi: $url')));
  }
}

Future<void> shareText(String text) => Share.share(text);
