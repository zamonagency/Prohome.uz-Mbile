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
import '../../../common/widgets/money_text.dart';
import '../../../core/config/env.dart';
import '../../../core/utils/actions.dart';
import '../../../core/utils/formatters.dart';
import '../../favorites/favorites_controller.dart';
import '../real_estate_model.dart';

String dealLabel(String deal, AppStrings s) =>
    deal == 'RENT' ? s('estate.deal_rent') : s('estate.deal_sale');

String propertyLabel(String type, AppStrings s) => switch (type) {
      'HOUSE' => s('estate.type_house'),
      'OFFICE' => s('estate.type_office'),
      'RETAIL' => s('estate.type_retail'),
      _ => s('estate.type_apartment'),
    };

/// To'liq kenglikdagi ro'yxat kartasi (OLX uslubi).
class RealEstateCard extends ConsumerWidget {
  const RealEstateCard({super.key, required this.item});
  final RealEstate item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      onTap: () => context.push(Routes.estate(item.id)),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          boxShadow: context.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: AppNetworkImage(
                    raw: item.cover,
                    radius: 0,
                  ),
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Pill(
                    label: dealLabel(item.dealType, s),
                    filled: true,
                    color: item.isRent ? AppColors.accent : AppColors.primary,
                    dense: true,
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: FavoriteButton(kind: FavKind.estate, id: item.id),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MoneyText(
                    item.price,
                    style: context.texts.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (item.roomCount > 0)
                        _mini('${item.roomCount} ${s('estate.rooms')}'),
                      if (item.areaSize > 0) _mini(formatArea(item.areaSize)),
                      if (item.floor != null)
                        _mini('${item.floor}/${item.totalFloors ?? '—'} ${s('estate.floor')}'),
                    ],
                  ),
                  if (item.locationName.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.place_outlined, size: 14, color: context.muted),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            item.locationName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.texts.bodySmall
                                ?.copyWith(color: context.muted),
                          ),
                        ),
                        Text(formatDate(item.createdAt),
                            style: context.texts.bodySmall
                                ?.copyWith(color: context.muted)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  StatCounters(viewCount: item.viewCount, likeCount: item.likeCount),
                  if (item.contactPhone.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _ActionIcons(item: item),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mini(String text) => Builder(
        builder: (context) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.border),
          ),
          child: Text(text,
              style: TextStyle(fontSize: 11.5, color: context.muted)),
        ),
      );
}

/// Kompakt karusel kartasi (uy sahifasi).
class RealEstateMiniCard extends ConsumerWidget {
  const RealEstateMiniCard({super.key, required this.item});
  final RealEstate item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      onTap: () => context.push(Routes.estate(item.id)),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          boxShadow: context.softShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
                aspectRatio: 16 / 10,
                child: AppNetworkImage(raw: item.cover)),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MoneyText(item.price,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 12.5)),
                  const SizedBox(height: 4),
                  Text(
                    '${item.roomCount > 0 ? '${item.roomCount} ${s('estate.rooms')} · ' : ''}${formatArea(item.areaSize)}',
                    style: TextStyle(fontSize: 11.5, color: context.muted),
                  ),
                  const SizedBox(height: 6),
                  StatCounters(
                      viewCount: item.viewCount, likeCount: item.likeCount, size: 11),
                  if (item.contactPhone.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _ActionIcons(item: item, compact: true),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Qo'ng'iroq / Telegram / Ulashish — har biri o'z sabab bilan alohida ishlaydi:
/// ulashish tizim "share" varag'ini ochadi (Telegram, WhatsApp, X va h.k. —
/// qurilmada o'rnatilgan barcha ilovalar, shu jumladan "nusxa olish").
class _ActionIcons extends ConsumerWidget {
  const _ActionIcons({required this.item, this.compact = false});
  final RealEstate item;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Avval `Row` standart (`start`) tekislanardi — 3 ta tugma kartaning
    // chap chetiga "yopishib", o'ng tomonda foydalanilmagan bo'sh joy
    // qolardi. Endi butun kenglik bo'yicha tekis taqsimlanadi.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _btn(context, Icons.call_rounded, AppColors.success,
            () => dialPhone(context, item.contactPhone)),
        _btn(context, Icons.send_rounded, const Color(0xFF229ED9),
            () => openTelegram(context, item.contactPhone)),
        _btn(
          context,
          Icons.share_outlined,
          context.muted,
          () => shareText(
              '${item.title}\n${moneyOf(item.price, ref.read(settingsProvider))}\n'
              '${Env.webBaseUrl}/real-estates/${item.id}'),
        ),
      ],
    );
  }

  Widget _btn(BuildContext context, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: color.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(compact ? 6 : 9),
          child: Icon(icon, size: compact ? 15 : 18, color: color),
        ),
      ),
    );
  }
}
