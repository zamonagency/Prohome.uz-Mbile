import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/data/currency_repository.dart';
import '../features/notifications/push_notifications_controller.dart';
import 'router.dart';
import 'settings_controller.dart';
import 'theme.dart';

class ProHomeApp extends ConsumerWidget {
  const ProHomeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);
    // Narxlar backendda USD keladi — boshida keshlangan/standart kurs bilan
    // ko'rsatiladi, jonli kurs kelishi bilan MoneyText avtomatik yangilanadi.
    ref.watch(usdRateSyncProvider);
    // Push (FCM): ruxsat so'rash, xabarlarni tinglash — bir marta.
    ref.read(pushNotificationsControllerProvider).setup();

    final dark = _resolvedBrightness(context, settings.themeMode) == Brightness.dark;
    // Tizim navigatsiya paneli (orqaga/uy/oxirgi ilovalar tugmalari) —
    // avvalgi kodda faqat status bar sozlangan edi. Uni ilova foniga mos,
    // shaffof qilib qo'ymasak, ba'zi qurilmalarda tizim paneli ilova
    // kontenti ustiga tushib, UI'ni "buzganday" ko'rinardi. Shu bilan
    // birga edge-to-edge yoqilib, Scaffold/SafeArea pastki bo'shliqni
    // to'g'ri hisoblab beradi.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      statusBarBrightness: dark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ));

    return MaterialApp.router(
      title: 'ProHome',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: 0.9,
        maxScaleFactor: 1.3,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}

Brightness _resolvedBrightness(BuildContext context, ThemeMode mode) {
  if (mode == ThemeMode.dark) return Brightness.dark;
  if (mode == ThemeMode.light) return Brightness.light;
  return MediaQuery.platformBrightnessOf(context);
}
