import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/settings_controller.dart';
import '../../../l10n/strings.dart';
import '../../../app/theme.dart';
import '../../../common/widgets/common.dart';
import '../../../common/widgets/favorite_button.dart';
import '../../../common/widgets/image_gallery.dart';
import '../../../common/widgets/mini_map.dart';
import '../../../common/widgets/money_text.dart';
import '../../../common/widgets/state_views.dart';
import '../../../core/config/env.dart';
import '../../../core/utils/actions.dart';
import '../../../core/utils/formatters.dart';
import '../../favorites/favorites_controller.dart';
import '../../home/recently_viewed_controller.dart';
import '../real_estate_model.dart';
import '../real_estate_repository.dart';
import '../widgets/real_estate_card.dart';

class RealEstateDetailPage extends ConsumerWidget {
  const RealEstateDetailPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(realEstateDetailProvider(id));
    final s = ref.watch(stringsProvider);
    ref.listen(realEstateDetailProvider(id), (_, next) {
      next.whenData((m) => ref.read(recentlyViewedProvider.notifier).trackEstate(m));
    });

    return Scaffold(
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(realEstateDetailProvider(id)),
        ),
        data: (item) => _Content(item: item),
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (item) => _ContactBar(item: item, s: s),
        orElse: () => null,
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.item});
  final RealEstate item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          leading: const _CircleBack(),
          actions: [
            _CircleAction(
              icon: Icons.share_outlined,
              onTap: () => shareText(
                  '${item.title}\n${moneyOf(item.price, ref.read(settingsProvider))}\n'
                  '${Env.webBaseUrl}/real-estates/${item.id}'),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FavoriteButton(kind: FavKind.estate, id: item.id),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: ImageGallery(
              images: item.gallery.isEmpty ? [item.cover] : item.gallery,
              aspectRatio: 1,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Pill(
                      label: dealLabel(item.dealType, s),
                      filled: true,
                      color: item.isRent ? AppColors.accent : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Pill(label: propertyLabel(item.propertyType, s)),
                  ],
                ),
                const SizedBox(height: 12),
                MoneyText(item.price,
                    style: context.texts.headlineSmall?.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(item.title, style: context.texts.titleMedium),
                if (item.locationName.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.place_outlined, size: 16, color: context.muted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(item.locationName,
                            style: context.texts.bodyMedium
                                ?.copyWith(color: context.muted)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                _SpecGrid(item: item, s: s),
                if ((item.description ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(s('estate.description'),
                      style: context.texts.titleMedium),
                  const SizedBox(height: 8),
                  Text(item.description!.trim(),
                      style: context.texts.bodyMedium
                          ?.copyWith(height: 1.5, color: context.muted)),
                ],
                if (item.hasGeo) ...[
                  const SizedBox(height: 20),
                  Text(s('estate.on_map'), style: context.texts.titleMedium),
                  const SizedBox(height: 8),
                  MiniMap(lat: item.latitude!, lng: item.longitude!),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.visibility_outlined,
                        size: 15, color: context.muted),
                    const SizedBox(width: 4),
                    Text('${item.viewCount} ${s('estate.views')}',
                        style: context.texts.bodySmall
                            ?.copyWith(color: context.muted)),
                    const SizedBox(width: 14),
                    Icon(Icons.favorite_border_rounded,
                        size: 15, color: context.muted),
                    const SizedBox(width: 4),
                    Text('${item.likeCount}',
                        style: context.texts.bodySmall
                            ?.copyWith(color: context.muted)),
                    const Spacer(),
                    Text(formatDate(item.createdAt),
                        style: context.texts.bodySmall
                            ?.copyWith(color: context.muted)),
                  ],
                ),
                if (item.similar.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(s('home.sec_similar_estates'), style: context.texts.titleMedium),
                  const SizedBox(height: 8),
                  HScroller(
                    height: 236,
                    itemWidth: 172,
                    itemCount: item.similar.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (_, i) => RealEstateMiniCard(item: item.similar[i]),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SpecGrid extends StatelessWidget {
  const _SpecGrid({required this.item, required this.s});
  final RealEstate item;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    final specs = <(IconData, String, String)>[
      if (item.roomCount > 0)
        (Icons.meeting_room_outlined, '${item.roomCount}', s('estate.rooms')),
      if (item.areaSize > 0)
        (Icons.straighten_rounded, formatArea(item.areaSize), s('estate.area')),
      if (item.floor != null)
        (
          Icons.stairs_outlined,
          '${item.floor}/${item.totalFloors ?? '—'}',
          s('estate.floor')
        ),
      if (item.plotSize != null && item.plotSize! > 0)
        (Icons.crop_square_rounded, '${item.plotSize}', 'sotix'),
    ];
    if (specs.isEmpty) return const SizedBox.shrink();
    return GridView.count(
      crossAxisCount: specs.length >= 3 ? 3 : specs.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: specs
          .map((sp) => Container(
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(sp.$1, color: AppColors.primary, size: 20),
                    const SizedBox(height: 4),
                    Text(sp.$2,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(sp.$3,
                        style:
                            TextStyle(fontSize: 11, color: context.muted)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _ContactBar extends StatelessWidget {
  const _ContactBar({required this.item, required this.s});
  final RealEstate item;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    if (item.contactPhone.isEmpty) return const SizedBox.shrink();
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => dialPhone(context, item.contactPhone),
              icon: const Icon(Icons.call_rounded, size: 20),
              label: Text('${s('common.call')} · ${item.contactPhone}'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBack extends StatelessWidget {
  const _CircleBack();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(6),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.35),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      );
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(6),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.35),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 20),
            onPressed: onTap,
          ),
        ),
      );
}
