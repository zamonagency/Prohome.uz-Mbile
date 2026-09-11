import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/settings_controller.dart';
import '../../../app/theme.dart';
import '../../../common/widgets/common.dart';
import '../../../common/widgets/money_text.dart';
import '../job_model.dart';

/// Ish e'lonlari uchun ham rasm/ikonka bilan grid ko'rinishi bo'lsin deb —
/// e'londa surat bo'lmagani uchun mutaxassislik ikonkasi katta chiqariladi.
class JobGridCard extends ConsumerWidget {
  const JobGridCard({super.key, required this.job});
  final Job job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      onTap: () => context.push(Routes.job(job.id)),
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
              aspectRatio: 1.5,
              child: Container(
                color: AppColors.primary.withValues(alpha: 0.10),
                alignment: Alignment.center,
                child: const Icon(Icons.work_outline_rounded,
                    color: AppColors.primary, size: 34),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 6),
                  if (job.price != null && job.price! > 0)
                    MoneyText(job.price,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            fontSize: 12.5))
                  else if (job.status == 'OPEN')
                    Pill(label: s('job.status_open'), color: AppColors.success, dense: true),
                  const SizedBox(height: 6),
                  StatCounters(
                      viewCount: job.viewCount, likeCount: job.likeCount, size: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JobCard extends ConsumerWidget {
  const JobCard({super.key, required this.job});
  final Job job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      onTap: () => context.push(Routes.job(job.id)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          boxShadow: context.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(job.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
                if (job.status == 'OPEN')
                  Pill(label: s('job.status_open'), color: AppColors.success, dense: true),
              ],
            ),
            const SizedBox(height: 6),
            Text(job.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, color: context.muted)),
            const SizedBox(height: 10),
            Row(
              children: [
                if (job.price != null && job.price! > 0) ...[
                  const Icon(Icons.payments_outlined,
                      size: 15, color: AppColors.primary),
                  const SizedBox(width: 4),
                  MoneyText(job.price,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontSize: 12.5)),
                  const SizedBox(width: 12),
                ],
                if (job.skillTypeName != null) ...[
                  Icon(Icons.handyman_outlined, size: 14, color: context.muted),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(job.skillTypeName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: context.muted)),
                  ),
                ],
                const Spacer(),
                if (job.locationName.isNotEmpty) ...[
                  Icon(Icons.place_outlined, size: 14, color: context.muted),
                  const SizedBox(width: 3),
                  Text(job.locationName,
                      style: TextStyle(fontSize: 12, color: context.muted)),
                ],
              ],
            ),
            const SizedBox(height: 8),
            StatCounters(viewCount: job.viewCount, likeCount: job.likeCount),
          ],
        ),
      ),
    );
  }
}
