import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/settings_controller.dart';
import '../../app/theme.dart';

class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final items = <(IconData, String, String, Color)>[
      (Icons.apartment_rounded, s('cat.estates'), Routes.estates, AppColors.primary),
      (Icons.location_city_rounded, s('cat.newbuilds'), Routes.newbuilds, const Color(0xFF0F80FF)),
      (Icons.handyman_rounded, s('cat.masters'), Routes.masters, AppColors.accent),
      (Icons.work_outline_rounded, s('cat.jobs'), Routes.jobs, const Color(0xFF7F4DFF)),
      (Icons.business_rounded, s('cat.companies'), Routes.companies, const Color(0xFF10B782)),
      (Icons.article_outlined, s('cat.news'), Routes.news, const Color(0xFFE5484D)),
      (Icons.map_rounded, s('map.title'), Routes.map, const Color(0xFF14B8A6)),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(s('nav.catalog'))),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.05,
        children: items
            .map((it) => InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  onTap: () => context.push(it.$3),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      border: Border.all(color: context.border),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: it.$4.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(it.$1, color: it.$4, size: 26),
                        ),
                        Text(it.$2,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
