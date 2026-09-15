import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/paginated.dart';
import '../../core/network/api_client.dart';
import '../../core/providers.dart';

/// Backend kategoriyalari (`yangi.txt`): CHAT_MESSAGE, SEARCH_MATCH,
/// ADMIN_BROADCAST — push kelganda qaysi sahifaga o'tish kerakligini
/// aniqlash uchun ishlatiladi (`data.entityType`/`entityId`).
class AppNotification {
  const AppNotification({
    required this.id,
    this.title = '',
    this.body = '',
    this.category,
    this.isRead = false,
    this.createdAt,
    this.data = const {},
  });
  final int id;
  final String title;
  final String body;
  final String? category;
  final bool isRead;
  final String? createdAt;
  final Map<String, dynamic> data;

  String? get entityType => data['entityType']?.toString();
  int? get entityId => asInt(data['entityId']);

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: asInt(j['id']) ?? 0,
        title: asString(j['title'], asString(j['heading'])),
        body: asString(j['body'], asString(j['message'], asString(j['content']))),
        category: j['category']?.toString(),
        isRead: asBool(j['isRead'] ?? j['read']),
        createdAt: j['createdAt']?.toString(),
        data: j['data'] is Map ? Map<String, dynamic>.from(j['data']) : const {},
      );
}

class NotificationsRepository {
  NotificationsRepository(this._api);
  final ApiClient _api;

  Future<Paginated<AppNotification>> list({
    int page = 1,
    int limit = 20,
    bool? isRead,
  }) async {
    final res = await _api.get('/notifications', query: {
      'page': page,
      'limit': limit,
      if (isRead != null) 'isRead': isRead,
    });
    return Paginated.parse(res, AppNotification.fromJson);
  }

  Future<int> unreadCount() async {
    try {
      final res = await _api.get('/notifications/unread-count');
      if (res is int) return res;
      if (res is Map) return asInt(res['count'] ?? res['unread'] ?? res['data']) ?? 0;
      return int.tryParse('$res') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> markRead(int id) async {
    try {
      await _api.patch('/notifications/$id/read');
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await _api.patch('/notifications/read-all');
    } catch (_) {}
  }

  /// Qurilma FCM tokenini ro'yxatdan o'tkazish — login/ro'yxatdan
  /// o'tishdan keyin va token yangilanganda chaqiriladi.
  Future<void> registerDeviceToken(String token, String platform) async {
    await _api.post('/notifications/device-token', body: {
      'token': token,
      'platform': platform,
    });
  }

  /// Logout yoki token eskirganda — qurilmani o'chirish.
  Future<void> deleteDeviceToken(String token) async {
    await _api.delete('/notifications/device-token', body: {'token': token});
  }
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(ref.watch(apiClientProvider)),
);

final unreadCountProvider = FutureProvider<int>((ref) async {
  final auth = ref.watch(apiClientProvider);
  // faqat login bo'lsa
  try {
    return await NotificationsRepository(auth).unreadCount();
  } catch (_) {
    return 0;
  }
});
