import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/settings_controller.dart';
import '../../../l10n/strings.dart';
import '../../../app/theme.dart';
import '../../../common/widgets/app_network_image.dart';
import '../../../common/widgets/common.dart';
import '../../../common/widgets/favorite_button.dart';
import '../../../common/widgets/image_gallery.dart';
import '../../../common/widgets/money_text.dart';
import '../../../common/widgets/state_views.dart';
import '../../../core/config/env.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/actions.dart';
import '../../../core/utils/formatters.dart';
import '../../chat/chat_repository.dart';
import '../../favorites/favorites_controller.dart';
import '../../home/recently_viewed_controller.dart';
import '../master_model.dart';
import '../master_repository.dart';
import '../widgets/master_card.dart';

class MasterDetailPage extends ConsumerWidget {
  const MasterDetailPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(masterDetailProvider(id));
    final s = ref.watch(stringsProvider);
    ref.listen(masterDetailProvider(id), (_, next) {
      next.whenData((m) => ref.read(recentlyViewedProvider.notifier).trackMaster(m));
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(s('cat.masters')),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => async.maybeWhen(
              data: (m) => shareText('${m.name}\n${Env.webBaseUrl}/masters/$id'),
              orElse: () {},
            ),
          ),
          FavoriteButton(kind: FavKind.master, id: id, compact: false),
        ],
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
            error: e, onRetry: () => ref.invalidate(masterDetailProvider(id))),
        data: (m) => _Body(master: m),
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (m) => _ActionBar(master: m, s: s),
        orElse: () => null,
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.master});
  final Master master;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: master.hasAvatar
                  ? AppNetworkImage(raw: master.avatar, width: 88, height: 88)
                  : Image.asset(master.defaultAvatarAsset,
                      width: 88, height: 88, fit: BoxFit.cover),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(master.name,
                      style: context.texts.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(master.primarySkill,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (master.avgRating > 0) ...[
                        StarRating(value: master.avgRating),
                        const SizedBox(width: 4),
                        Text('(${master.ratings.length})',
                            style: TextStyle(
                                fontSize: 12, color: context.muted)),
                        const SizedBox(width: 10),
                      ],
                      Pill(
                        label: master.isFree
                            ? s('master.free_now')
                            : s('master.busy'),
                        color: master.isFree
                            ? AppColors.success
                            : context.muted,
                        dense: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _stat(context, '${master.experience}', s('master.experience')),
            _stat(context, compactPrice(master.viewCount), s('estate.views')),
            _stat(context, '${master.likeCount}', s('estate.likes')),
          ],
        ),
        if (master.salary != null && master.salary! > 0) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.payments_outlined,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Text('${s('job.budget')}: ',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                MoneyText(master.salary,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
        if ((master.bio ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(s('estate.description'), style: context.texts.titleMedium),
          const SizedBox(height: 6),
          Text(master.bio!.trim(),
              style: context.texts.bodyMedium
                  ?.copyWith(height: 1.5, color: context.muted)),
        ],
        if (master.skills.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(s('master.skills'), style: context.texts.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: master.skills
                .map((sk) => Pill(label: sk.name))
                .toList(),
          ),
        ],
        if (master.portfolio.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(s('master.portfolio'), style: context.texts.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: master.portfolio.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    child: AppNetworkImage(
                        raw: master.portfolio[i], fit: BoxFit.contain),
                  ),
                ),
                child: RoundedImage(raw: master.portfolio[i], height: 120),
              ),
            ),
          ),
        ],
        if (master.ratings.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(s('master.reviews'), style: context.texts.titleMedium),
          const SizedBox(height: 8),
          ...master.ratings.take(10).map((r) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(r.authorName.isEmpty ? 'Foydalanuvchi' : r.authorName,
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        const Spacer(),
                        StarRating(value: r.rating.toDouble()),
                      ],
                    ),
                    if ((r.comment ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(r.comment!,
                          style: TextStyle(color: context.muted, fontSize: 13)),
                    ],
                  ],
                ),
              )),
        ],
        if (master.similar.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(s('home.sec_similar_masters'), style: context.texts.titleMedium),
          const SizedBox(height: 8),
          HScroller(
            height: 220,
            itemWidth: 150,
            itemCount: master.similar.length,
            padding: EdgeInsets.zero,
            itemBuilder: (_, i) => MasterGridCard(master: master.similar[i]),
          ),
        ],
      ],
    );
  }

  Widget _stat(BuildContext context, String value, String label) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.border),
          ),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16)),
              Text(label,
                  style: TextStyle(fontSize: 11, color: context.muted)),
            ],
          ),
        ),
      );
}

class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.master, required this.s});
  final Master master;
  final AppStrings s;

  Future<void> _openChat(BuildContext context, WidgetRef ref) async {
    if (!await ensureAuth(context, ref)) return;
    try {
      final chat = await ref.read(chatRepositoryProvider).startOrGet(master.id);
      if (context.mounted) {
        context.push(
            '${Routes.chat(chat.id)}?title=${Uri.encodeComponent(master.name)}');
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          if (master.phone.isNotEmpty)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => dialPhone(context, master.phone),
                icon: const Icon(Icons.call_rounded, size: 18),
                label: Text(s('common.call')),
              ),
            ),
          if (master.phone.isNotEmpty) const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _openChat(context, ref),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: Text(s('master.write')),
            ),
          ),
        ],
      ),
    );
  }
}
