import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/settings_controller.dart';
import '../../../app/theme.dart';
import '../../../common/widgets/common.dart';
import '../../../common/widgets/favorite_button.dart';
import '../../../common/widgets/money_text.dart';
import '../../../common/widgets/state_views.dart';
import '../../../core/utils/actions.dart';
import '../../../core/utils/formatters.dart';
import '../../favorites/favorites_controller.dart';
import '../job_repository.dart';

class JobDetailPage extends ConsumerWidget {
  const JobDetailPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(jobDetailProvider(id));
    final s = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s('cat.jobs')),
        actions: [FavoriteButton(kind: FavKind.job, id: id, compact: false)],
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
            error: e, onRetry: () => ref.invalidate(jobDetailProvider(id))),
        data: (job) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(job.title,
                style: context.texts.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (job.status == 'OPEN')
                  Pill(label: s('job.status_open'), color: AppColors.success),
                if (job.skillTypeName != null) Pill(label: job.skillTypeName!),
                if (job.locationName.isNotEmpty)
                  Pill(label: job.locationName, color: context.muted),
              ],
            ),
            if (job.price != null && job.price! > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.payments_outlined,
                        color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text('${s('job.budget')}: ',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15)),
                    MoneyText(job.price,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text(s('estate.description'), style: context.texts.titleMedium),
            const SizedBox(height: 6),
            Text(job.description,
                style: context.texts.bodyMedium
                    ?.copyWith(height: 1.5, color: context.muted)),
            const SizedBox(height: 18),
            if (job.skills.isNotEmpty) ...[
              Text(s('master.skills'), style: context.texts.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: job.skills.map((e) => Pill(label: e)).toList(),
              ),
              const SizedBox(height: 18),
            ],
            Row(
              children: [
                Icon(Icons.visibility_outlined, size: 15, color: context.muted),
                const SizedBox(width: 4),
                Text('${job.viewCount}',
                    style: TextStyle(color: context.muted, fontSize: 12)),
                const Spacer(),
                Text(formatDate(job.createdAt),
                    style: TextStyle(color: context.muted, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (job) => job.contactPhone.isEmpty
            ? null
            : SafeArea(
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: ElevatedButton.icon(
                  onPressed: () => dialPhone(context, job.contactPhone),
                  icon: const Icon(Icons.call_rounded, size: 20),
                  label: Text('${s('job.respond')} · ${job.contactPhone}'),
                ),
              ),
        orElse: () => null,
      ),
    );
  }
}
