import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import 'notifications_repository.dart';

/// Ilova FON/yopiq holatida kelgan xabar uchun — FCM "notification"
/// maydoni bo'lsa tizim bildirishnomani o'zi ko'rsatadi, bu yerda faqat
/// Firebase'ni shu (alohida) isolate'da ham ishga tushirib qo'yamiz.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

const _androidChannel = AndroidNotificationChannel(
  'prohome_default_channel',
  'ProHome bildirishnomalari',
  description: "Yangi xabar, mos e'lon va boshqa bildirishnomalar",
  importance: Importance.high,
);

/// FCM push'ni to'liq ulaydi: ruxsat so'raydi, ilova OCHIQ paytida ham
/// bildirishnoma ko'rsatadi (flutter_local_notifications — FCM buni
/// foreground'da o'zi qilmaydi), bosilganda tegishli sahifaga o'tkazadi,
/// va qurilma tokenini backendga ro'yxatdan o'tkazadi/o'chiradi.
class PushNotificationsController {
  PushNotificationsController(this._ref);

  final Ref _ref;
  final _local = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  NotificationsRepository get _repo => _ref.read(notificationsRepositoryProvider);

  /// Ilova ochilganda BIR MARTA — auth holatidan mustaqil (tinglovchilar
  /// har doim ishlab tursin, token esa faqat login bo'lganda yuboriladi).
  Future<void> setup() async {
    if (_ready) return;
    _ready = true;
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (defaultTargetPlatform == TargetPlatform.android) {
        await _local
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_androidChannel);
      }
      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: (resp) {
          final raw = resp.payload;
          if (raw == null || raw.isEmpty) return;
          try {
            _handlePayload(Map<String, dynamic>.from(jsonDecode(raw) as Map));
          } catch (_) {}
        },
      );

      FirebaseMessaging.onMessage.listen(_showForeground);
      FirebaseMessaging.onMessageOpenedApp.listen((m) => _handlePayload(m.data));

      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) _handlePayload(initial.data);

      FirebaseMessaging.instance.onTokenRefresh.listen((_) => registerToken());
    } catch (_) {
      // Ruxsat berilmadi yoki Firebase sozlanmagan — ilova oddiy davom etadi.
    }
  }

  Future<void> _showForeground(RemoteMessage message) async {
    final n = message.notification;
    if (n == null) return;
    await _local.show(
      id: message.hashCode,
      title: n.title,
      body: n.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handlePayload(Map<String, dynamic> data) {
    final router = _ref.read(routerProvider);
    final type = (data['entityType'] ?? '').toString().toLowerCase();
    final id = int.tryParse('${data['entityId'] ?? ''}');
    if (id == null) {
      router.push(Routes.notifications);
      return;
    }
    switch (type) {
      case 'chat':
        router.push(Routes.chat(id));
      case 'realestate':
      case 'real_estate':
      case 'real-estate':
        router.push(Routes.estate(id));
      case 'master':
        router.push(Routes.master(id));
      case 'job':
        router.push(Routes.job(id));
      default:
        router.push(Routes.notifications);
    }
  }

  /// Login/ro'yxatdan o'tishdan keyin (va token yangilanganda) chaqiriladi.
  Future<void> registerToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      final platform = defaultTargetPlatform == TargetPlatform.iOS ? 'IOS' : 'ANDROID';
      await _repo.registerDeviceToken(token, platform);
    } catch (_) {
      // Best-effort — push ishlamasa ham ilovaning o'zi davom etadi.
    }
  }

  /// Logout — hali auth bo'lgan holatda, token tozalanishidan OLDIN
  /// chaqirilishi kerak (endpoint login talab qiladi).
  Future<void> unregisterToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await _repo.deleteDeviceToken(token);
    } catch (_) {}
  }
}

final pushNotificationsControllerProvider = Provider<PushNotificationsController>(
  (ref) => PushNotificationsController(ref),
);
