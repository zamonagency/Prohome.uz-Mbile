import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/settings_controller.dart';
import '../../../app/theme.dart';
import '../../../common/widgets/app_network_image.dart';
import '../../../common/widgets/common.dart';
import '../../../common/widgets/favorite_button.dart';
import '../../favorites/favorites_controller.dart';
import '../master_model.dart';

Widget _avatar(Master master, {double? width, double? height}) {
  if (!master.hasAvatar) {
    return Image.asset(master.defaultAvatarAsset,
        width: width, height: height, fit: BoxFit.cover);
  }
  return AppNetworkImage(raw: master.avatar, width: width, height: height);
}

class MasterCard extends ConsumerWidget {
  const MasterCard({super.key, required this.master});
  final Master master;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      onTap: () => context.push(Routes.master(master.id)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          boxShadow: context.softShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _avatar(master, width: 64, height: 64),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(master.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14.5)),
                      ),
                      if (master.avgRating > 0)
                        StarRating(value: master.avgRating),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(master.primarySkill,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.primary, fontSize: 12.5)),
                  const SizedBox(height: 6),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (master.experience > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.workspace_premium_outlined,
                                size: 13, color: context.muted),
                            const SizedBox(width: 3),
                            Text('${master.experience} ${s('master.experience')}',
                                style: TextStyle(
                                    fontSize: 11.5, color: context.muted)),
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
                      if (master.workType.isTeam)
                        Pill(
                          label: s('master.team'),
                          icon: Icons.groups_rounded,
                          dense: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: StatCounters(
                            viewCount: master.viewCount,
                            likeCount: master.likeCount,
                            size: 11.5),
                      ),
                      FavoriteButton(
                          kind: FavKind.master, id: master.id, compact: false),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Katak (grid) ko'rinishi — rasm ustunroq turadi.
class MasterGridCard extends ConsumerWidget {
  const MasterGridCard({super.key, required this.master});
  final Master master;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      onTap: () => context.push(Routes.master(master.id)),
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
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.15,
                  child: _avatar(master),
                ),
                if (master.avgRating > 0)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: StarRating(value: master.avgRating, size: 11),
                    ),
                  ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: FavoriteButton(kind: FavKind.master, id: master.id),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(master.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.5)),
                  const SizedBox(height: 2),
                  Text(master.primarySkill,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.primary, fontSize: 11.5)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Pill(
                        label: master.isFree ? s('master.free_now') : s('master.busy'),
                        color: master.isFree ? AppColors.success : context.muted,
                        dense: true,
                      ),
                      if (master.workType.isTeam)
                        Pill(
                          label: s('master.team'),
                          icon: Icons.groups_rounded,
                          dense: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  StatCounters(
                      viewCount: master.viewCount,
                      likeCount: master.likeCount,
                      size: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MasterMiniCard extends ConsumerWidget {
  const MasterMiniCard({super.key, required this.master});
  final Master master;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      onTap: () => context.push(Routes.master(master.id)),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          boxShadow: context.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: _avatar(master, width: 64, height: 64),
            ),
            const SizedBox(height: 8),
            Text(master.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 2),
            Text(master.primarySkill,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: context.muted)),
            const SizedBox(height: 6),
            if (master.avgRating > 0) StarRating(value: master.avgRating),
            const SizedBox(height: 4),
            StatCounters(
                viewCount: master.viewCount, likeCount: master.likeCount, size: 10.5),
          ],
        ),
      ),
    );
  }
}
