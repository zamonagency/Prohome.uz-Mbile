import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../app/router.dart';
import '../../../app/settings_controller.dart';
import '../../../common/widgets/app_network_image.dart';
import '../../../common/widgets/state_views.dart';
import '../../auth/auth_controller.dart';
import '../chat_model.dart';
import '../chat_repository.dart';

final myChatsProvider =
    FutureProvider.autoDispose<List<Chat>>((ref) async {
  if (!ref.watch(isAuthenticatedProvider)) return <Chat>[];
  final res = await ref.watch(chatRepositoryProvider).myChats();
  return res.items;
});

class ChatsPage extends ConsumerWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final authed = ref.watch(isAuthenticatedProvider);
    final chats = ref.watch(myChatsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s('nav.chats'))),
      body: !authed
          ? EmptyView(
              icon: Icons.chat_bubble_outline_rounded,
              message: s('auth.need_login'),
              action: ElevatedButton(
                onPressed: () => context.push(Routes.login),
                child: Text(s('auth.login')),
              ),
            )
          : chats.when(
              loading: () => const SkeletonList(count: 6, height: 72),
              error: (e, _) =>
                  ErrorView(error: e, onRetry: () => ref.invalidate(myChatsProvider)),
              data: (list) => list.isEmpty
                  ? EmptyView(
                      icon: Icons.chat_bubble_outline_rounded,
                      message: s('chat.empty'))
                  : RefreshIndicator(
                      onRefresh: () async => ref.invalidate(myChatsProvider),
                      child: ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final c = list[i];
                          return ListTile(
                            leading: ClipOval(
                              child: AppNetworkImage(
                                  raw: c.avatar, width: 48, height: 48),
                            ),
                            title: Text(c.title,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                              c.lastMessage?.content ??
                                  (c.lastMessage?.isMedia ?? false ? '📎 media' : '—'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: c.lastMessage?.createdAt == null
                                ? null
                                : Text(
                                    _ago(c.lastMessage!.createdAt!),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                            onTap: () => context.push(
                              '${Routes.chat(c.id)}?title=${Uri.encodeComponent(c.title)}',
                            ),
                          );
                        },
                      ),
                    ),
            ),
    );
  }

  String _ago(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    return timeago.format(d.toLocal(), locale: 'en_short');
  }
}
