import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/settings_controller.dart';
import '../../../app/theme.dart';
import '../../../common/widgets/app_network_image.dart';
import '../../../common/widgets/image_gallery.dart';
import '../../../common/widgets/state_views.dart';
import '../../../core/utils/actions.dart';
import '../company_repository.dart';

class CompanyDetailPage extends ConsumerWidget {
  const CompanyDetailPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(companyDetailProvider(id));
    final s = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s('cat.companies'))),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
            error: e, onRetry: () => ref.invalidate(companyDetailProvider(id))),
        data: (c) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AppNetworkImage(
                      raw: c.logoUrl, width: 76, height: 76, fit: BoxFit.contain),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(c.name,
                                style: context.texts.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                          ),
                          if (c.isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified_rounded,
                                color: AppColors.primary, size: 18),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${c.complexes.length} ta turar-joy majmuasi',
                          style: TextStyle(color: context.muted, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            if ((c.description ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(c.description!.trim(),
                  style: context.texts.bodyMedium
                      ?.copyWith(height: 1.5, color: context.muted)),
            ],
            if (c.complexes.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(s('cat.newbuilds'), style: context.texts.titleMedium),
              const SizedBox(height: 10),
              ...c.complexes.map((cx) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      border: Border.all(color: context.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (cx.cover.isNotEmpty)
                          RoundedImage(raw: cx.cover, height: 150),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cx.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              if (cx.address.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(cx.address,
                                    style: TextStyle(
                                        fontSize: 12, color: context.muted)),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (c) => (c.phone ?? '').isEmpty
            ? null
            : SafeArea(
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => dialPhone(context, c.phone!),
                        icon: const Icon(Icons.call_rounded, size: 20),
                        label: Text('${s('common.call')} · ${c.phone}'),
                      ),
                    ),
                    if ((c.website ?? '').isNotEmpty) ...[
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () => openUrlExternal(context, c.website!),
                        child: const Icon(Icons.language_rounded),
                      ),
                    ],
                  ],
                ),
              ),
        orElse: () => null,
      ),
    );
  }
}
