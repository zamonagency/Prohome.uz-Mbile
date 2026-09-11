import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/settings_controller.dart';
import '../../../app/theme.dart';
import '../../../common/widgets/state_views.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/auth_controller.dart';
import '../notifications_repository.dart';

final _notificationsProvider = FutureProvider.autoDispose((ref) async {
  if (!ref.watch(isAuthenticatedProvider)) return <AppNotification>[];
  final res = await ref.watch(notificationsRepositoryProvider).list();
  return res.items;
});

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final authed = ref.watch(isAuthenticatedProvider);
    final async = ref.watch(_notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s('profile.notifications'))),
      body: !authed
          ? EmptyView(
              icon: Icons.notifications_none_rounded,
              message: s('auth.need_login'),
              action: ElevatedButton(
                onPressed: () => context.push(Routes.login),
                child: Text(s('auth.login')),
              ),
            )
          : async.when(
              loading: () => const SkeletonList(count: 6, height: 76),
              error: (e, _) => ErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(_notificationsProvider)),
              data: (list) => list.isEmpty
                  ? EmptyView(
                      icon: Icons.notifications_none_rounded,
                      message: s('common.empty'))
                  : RefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(_notificationsProvider),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final n = list[i];
                          return InkWell(
                            borderRadius: BorderRadius.circular(AppTheme.radius),
                            onTap: n.isRead
                                ? null
                                : () async {
                                    await ref
                                        .read(notificationsRepositoryProvider)
                                        .markRead(n.id);
                                    ref.invalidate(_notificationsProvider);
                                    ref.invalidate(unreadCountProvider);
                                  },
                            child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: n.isRead
                                  ? context.colors.surface
                                  : AppColors.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(AppTheme.radius),
                              border: Border.all(color: context.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (!n.isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    Expanded(
                                      child: Text(
                                        n.title.isEmpty ? 'ProHome' : n.title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    Text(formatDate(n.createdAt),
                                        style: TextStyle(
                                            fontSize: 11, color: context.muted)),
                                  ],
                                ),
                                if (n.body.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(n.body,
                                      style: TextStyle(
                                          fontSize: 13, color: context.muted)),
                                ],
                              ],
                            ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
    );
  }
}
