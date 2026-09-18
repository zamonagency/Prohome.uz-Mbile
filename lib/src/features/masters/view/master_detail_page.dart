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
    final master = async.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(s('cat.masters')),
        // Ko'rish/like sonlari pastdagi statistikadan olib tashlanib, shu
        // yerga ko'chirilgan — uchalasi (ko'z/ulashish/yurak) endi AYNAN
        // bir xil o'lchamdagi (40x40) quticha ichida, ostida esa AYNAN
        // bir xil balandlikdagi son joyi bilan chiziladi — shu sabab
        // avval son bo'lmagan "ulashish" ikonkasi boshqalardan bir oz
        // pastroq/yuqoriroq ko'rinib, qator "bir chiziqda turmagan" edi.
        toolbarHeight: 66,
        actions: [
          _AppBarStat(
            icon: Icons.visibility_outlined,
            count: master?.viewCount ?? 0,
          ),
          _AppBarStat(
            icon: Icons.share_outlined,
            onTap: () => async.maybeWhen(
              data: (m) => shareText('${m.name}\n${Env.webBaseUrl}/masters/$id'),
              orElse: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: _AppBarStat(
              count: master?.likeCount ?? 0,
              child: FavoriteButton(kind: FavKind.master, id: id, compact: false),
            ),
          ),
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
                  // Reyting/tajriba/holat — endi bittalab keng "stat"
                  // qutichalarga emas, shu ixcham qatorga (kerak bo'lsa
                  // keyingi qatorga tushib) sig'diriladi. Tajriba (hatto
                  // 0 bo'lsa ham — backendda ko'plab ustada shunday)
                  // doim ko'rinadi, "Hozir bo'sh/Band" pilidan OLDIN.
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      Pill(
                        label: '${master.experience} ${s('master.experience')}',
                        icon: Icons.workspace_premium_outlined,
                        dense: true,
                      ),
                      if (master.avgRating > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StarRating(value: master.avgRating),
                            const SizedBox(width: 4),
                            Text('(${master.ratings.length})',
                                style: TextStyle(
                                    fontSize: 12, color: context.muted)),
                          ],
                        ),
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
                // Endi bitta statik rasm o'rniga — suriladigan (swipe)
                // to'liq ekran galereya, xuddi shu nuqtadan (bosilgan
                // rasmdan) boshlab, keyingi/oldingi ishlarga o'tish mumkin.
                onTap: () => openImageViewer(context, master.portfolio, i),
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
          // MUHIM: 220 balandlik MasterGridCard ichidagi matn/pill'lar
          // (ayniqsa "Jamoa" pili qo'shimcha qatorga tushganda) uchun
          // yetarli emas edi — shu sabab kartaning tagida sariq-qora
          // chiziqli "overflow" ogohlantirishi chiqib turardi. Balandlik
          // haqiqiy kontent bo'yicha (rasm + matn + pill'lar, hattoki
          // 2 qatorli pill holatida ham) zaxira bilan hisoblab qo'yilgan.
          HScroller(
            height: 268,
            itemWidth: 156,
            itemCount: master.similar.length,
            padding: EdgeInsets.zero,
            itemBuilder: (_, i) => MasterGridCard(master: master.similar[i]),
          ),
        ],
      ],
    );
  }

}

/// AppBar'da ikonka + uning tagida kichik son — ko'rish/like sonlarini
/// alohida, keng "stat" qutichasiz, ixcham ko'rsatish uchun.
///
/// MUHIM: uchala harakat (ko'rish/ulashish/like) ham AYNAN bir xil
/// o'lchamdagi (40x40) ikonka qutichasi + AYNAN bir xil balandlikdagi
/// (16) son joyidan iborat — shu bilan barchasi bitta gorizontal
/// chiziqda turadi. Avval "ulashish"da son bo'lmagani uchun uning
/// qutichasi boshqalardan pastroq/torroq bo'lib, qator "sirg'algan"
/// ko'rinardi; endi son yo'q bo'lsa ham shu balandlikdagi bo'sh joy
/// saqlanadi.
class _AppBarStat extends StatelessWidget {
  const _AppBarStat({this.icon, this.child, this.count, this.onTap})
      : assert(icon != null || child != null);
  final IconData? icon;
  final Widget? child;
  final int? count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: child ??
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onTap,
                  child: Icon(icon, size: 22),
                ),
              ),
        ),
        SizedBox(
          height: 16,
          child: count == null
              ? null
              : Center(
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: context.muted,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
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
          // Avval "Qo'ng'iroq" matni + ikonka `Expanded(flex: 1)` ichiga
          // sig'may, so'z o'rtasida ("Qo'ng" / "'iroq") ikki qatorga
          // bo'linib ketardi — chiroyli emas edi. Qo'ng'iroq universal
          // ikonka bilan tushunarli bo'lgani uchun endi faqat ikonkali,
          // ixcham kvadrat tugma; "Yozish" esa to'liq qolgan joyni oladi.
          if (master.phone.isNotEmpty) ...[
            SizedBox(
              width: 52,
              height: 52,
              child: OutlinedButton(
                onPressed: () => dialPhone(context, master.phone),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Icon(Icons.call_rounded, size: 22),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
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
