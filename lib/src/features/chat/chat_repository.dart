import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/paginated.dart';
import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import 'chat_model.dart';

class ChatRepository {
  ChatRepository(this._api);
  final ApiClient _api;

  Future<Chat> startOrGet(int masterId) async {
    final res = await _api.post('/chats', body: {'masterId': masterId});
    return Chat.fromJson(unwrap(res));
  }

  Future<Paginated<Chat>> myChats({int page = 1, int limit = 20}) async {
    final res = await _api.get('/chats/my', query: {'page': page, 'limit': limit});
    return Paginated.parse(res, Chat.fromJson);
  }

  Future<Paginated<ChatMessage>> messages(int chatId,
      {int page = 1, int limit = 30}) async {
    final res = await _api
        .get('/chats/$chatId/messages', query: {'page': page, 'limit': limit});
    return Paginated.parse(res, ChatMessage.fromJson);
  }

  Future<ChatMessage> sendText(int chatId, String content) async {
    final res = await _api
        .post('/chats/$chatId/messages', body: {'content': content});
    return ChatMessage.fromJson(unwrap(res));
  }
}

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(ref.watch(apiClientProvider)),
);
