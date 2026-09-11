import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/paginated.dart';
import '../../core/network/api_client.dart';
import '../../core/providers.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    this.title = '',
    this.body = '',
    this.isRead = false,
    this.createdAt,
    this.type,
  });
  final int id;
  final String title;
  final String body;
  final bool isRead;
  final String? createdAt;
  final String? type;

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: asInt(j['id']) ?? 0,
        title: asString(j['title'], asString(j['heading'])),
        body: asString(j['body'], asString(j['message'], asString(j['content']))),
        isRead: asBool(j['isRead'] ?? j['read']),
        createdAt: j['createdAt']?.toString(),
        type: j['type']?.toString(),
      );
}

class NotificationsRepository {
  NotificationsRepository(this._api);
  final ApiClient _api;

  Future<Paginated<AppNotification>> list({int page = 1, int limit = 20}) async {
    final res =
        await _api.get('/notifications', query: {'page': page, 'limit': limit});
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
