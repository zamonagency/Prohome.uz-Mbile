import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/data/currency_repository.dart';
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

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
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
