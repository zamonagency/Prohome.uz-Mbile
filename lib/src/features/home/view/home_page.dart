import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/settings_controller.dart';
import '../../../app/theme.dart';
import '../../../l10n/strings.dart';
import '../../../common/widgets/app_network_image.dart';
import '../../../common/widgets/common.dart';
import '../../../common/widgets/state_views.dart';
import '../../../core/utils/actions.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/auth_controller.dart';
import '../../jobs/widgets/job_card.dart';
import '../../masters/widgets/master_card.dart';
import '../../news/widgets/news_card.dart';
import '../../notifications/notifications_repository.dart';
import '../../realestate/real_estate_model.dart';
import '../../realestate/real_estate_repository.dart';
import '../../realestate/view/filter_sheet.dart';
import '../../realestate/widgets/real_estate_card.dart';
import '../home_repository.dart';
import '../nearby_estates_controller.dart';
import '../recently_viewed_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final user = ref.watch(currentUserProvider);
    final bundle = ref.watch(homeBundleProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(homeBundleProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header(userName: user?.firstName)),
              SliverToBoxAdapter(child: _SearchBar(s: s)),
              SliverToBoxAdapter(child: _CategoryChips(s: s)),
              SliverToBoxAdapter(child: _QuickActions(s: s)),
              ...bundle.when(
                loading: () => [
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 320, child: LoadingView()),
                  ),
                ],
                error: (e, _) => [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 320,
                      child: ErrorView(
                        error: e,
                        onRetry: () => ref.read(homeBundleProvider.notifier).refresh(),
                      ),
                    ),
                  ),
                ],
                data: (data) => _sections(context, ref, s, data),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _sections(
      BuildContext context, WidgetRef ref, AppStrings s, HomeBundle data) {
    final recent = ref.watch(recentlyViewedProvider);
    final nearby = ref.watch(nearbyEstatesProvider).maybeWhen(
        data: (list) => list, orElse: () => const <RealEstate>[]);

    return [
      SliverToBoxAdapter(child: _Hero(banners: data.banners, s: s)),

      SliverToBoxAdapter(child: _CategoryGrid(categories: data.categories)),

      if (data.stats.estates + data.stats.masters + data.stats.jobs > 0)
        SliverToBoxAdapter(child: _StatsStrip(stats: data.stats, s: s)),

      if (nearby.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: SectionHeader(
            title: s('home.sec_nearby'),
            seeAllLabel: s('common.view_all'),
            onSeeAll: () => context.push(Routes.estates),
          ),
        ),
        SliverToBoxAdapter(
          child: HScroller(
            height: 252,
            itemWidth: 172,
            itemCount: nearby.length,
            itemBuilder: (_, i) => RealEstateMiniCard(item: nearby[i]),
          ),
        ),
      ],

      if (recent.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: SectionHeader(title: s('home.sec_recent')),
        ),
        SliverToBoxAdapter(
          child: HScroller(
            height: 176,
            itemWidth: 152,
            itemCount: recent.length,
            itemBuilder: (_, i) => _RecentCard(entry: recent[i]),
          ),
        ),
      ],

      if (data.freshEstates.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: SectionHeader(
            title: s('home.sec_fresh_estates'),
            seeAllLabel: s('common.view_all'),
            onSeeAll: () => context.push(Routes.estates),
          ),
        ),
        SliverToBoxAdapter(
          child: HGridScroller(
            rows: 4,
            itemWidth: 172,
            itemHeight: 250,
            itemCount: data.freshEstates.length,
            itemBuilder: (_, i) => RealEstateMiniCard(item: data.freshEstates[i]),
          ),
        ),
      ],

      // Ustalar odatda kam sonli (top ustalar) bo'lgani uchun grid emas,
      // bitta qatorli — aks holda 1-2 ta karta yonma-yon emas, ustma-ust
      // "tushib" qolib, chala qatorga o'xshab ko'rinardi.
      if (data.topMasters.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: SectionHeader(
            title: s('home.sec_top_masters'),
            seeAllLabel: s('common.view_all'),
            onSeeAll: () => context.push(Routes.masters),
          ),
        ),
        SliverToBoxAdapter(
          child: HScroller(
            height: 262,
            itemWidth: 150,
            itemCount: data.topMasters.length,
            itemBuilder: (_, i) => MasterGridCard(master: data.topMasters[i]),
          ),
        ),
      ],

      if (data.jobs.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: SectionHeader(
            title: s('home.sec_jobs'),
            seeAllLabel: s('common.view_all'),
            onSeeAll: () => context.push(Routes.jobs),
          ),
        ),
        SliverToBoxAdapter(
          child: HGridScroller(
            itemWidth: 168,
            itemHeight: 224,
            itemCount: data.jobs.length,
            itemBuilder: (_, i) => JobGridCard(job: data.jobs[i]),
          ),
        ),
      ],

      if (data.news.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: SectionHeader(
            title: s('home.sec_news'),
            seeAllLabel: s('common.view_all'),
            onSeeAll: () => context.push(Routes.news),
          ),
        ),
        SliverToBoxAdapter(
          child: HScroller(
            height: 252,
            itemWidth: 264,
            itemCount: data.news.length,
            itemBuilder: (_, i) => NewsCard(post: data.news[i]),
          ),
        ),
      ],
    ];
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────
class _Header extends ConsumerWidget {
  const _Header({required this.userName});
  final String? userName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 6),
      child: Row(
        children: [
          Image.asset('assets/images/logo.png', width: 38, height: 38),
          const SizedBox(width: 10),
          Expanded(
            child: Text(userName ?? s('auth.guest'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          ),
          _RoundIconButton(
            icon: context.isDark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            onTap: () => ref
                .read(settingsProvider.notifier)
                .toggleTheme(Theme.of(context).brightness),
          ),
          const SizedBox(width: 6),
          _RoundIconButton(
            icon: Icons.notifications_none_rounded,
            showDot: ref.watch(unreadCountProvider).maybeWhen(
                data: (c) => c > 0, orElse: () => false),
            onTap: () => context.push(Routes.notifications),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap, this.showDot = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      shape: CircleBorder(side: BorderSide(color: context.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 20, color: context.colors.onSurface),
              if (showDot)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.colors.surface, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Search ──────────────────────────────────────────────────────────────────
/// Bosh sahifada o'zi yozish mumkin (hech qayerga olib ketmaydi) —
/// Enter/qidiruv tugmasi bosilsagina natijalar sahifasiga o'tadi.
/// Filtr ikonkasi esa alohida, minimalist filtr varag'ini ochadi.
class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.s});
  final AppStrings s;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final q = _ctrl.text.trim();
    if (q.isEmpty) return;
    // Uy, usta yoki ish — uchalasi ham qidiriladi (SearchPage ichida
    // sahifalarga bo'lib ko'rsatiladi), faqat ko'chmas mulk emas.
    context.push('${Routes.search}?q=${Uri.encodeComponent(q)}');
  }

  Future<void> _openFilter() async {
    final res = await FilterSheet.show(context, const RealEstateFilter());
    if (res == null || !mounted) return;
    final q = _ctrl.text.trim();
    context.push(Routes.estates,
        extra: q.isEmpty ? res : res.copyWith(search: q));
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 4, 8, 4),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: context.softShadow,
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _ctrl,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _submit(),
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  isDense: true,
                  isCollapsed: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: s('home.search_hint'),
                  hintStyle: TextStyle(color: context.muted, fontSize: 14),
                ),
              ),
            ),
            Container(width: 1, height: 22, color: context.border),
            const SizedBox(width: 4),
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: _openFilter,
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: Icon(Icons.tune_rounded, color: context.muted, size: 21),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tezkor amallar: e'lon qo'shish / usta bo'lish ──────────────────────────
class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.s});
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
      child: Row(
        children: [
          Expanded(
            child: _btn(
              context,
              icon: Icons.add_home_work_outlined,
              label: s('estate.add'),
              color: AppColors.primary,
              onTap: () => context.push(Routes.addListing),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _btn(
              context,
              icon: Icons.workspace_premium_outlined,
              label: s('intent.become_master'),
              color: const Color(0xFF9B5DE5),
              onTap: () => context.push(Routes.becomeMaster),
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w700, fontSize: 12.5)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Kompakt "ko'chmas mulk / yangi bino" pill'lari ─────────────────────────
class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.s});
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    final cats = <(IconData, String, String)>[
      (Icons.apartment_rounded, s('cat.estates'), Routes.estates),
      (Icons.location_city_rounded, s('cat.newbuilds'), Routes.newbuilds),
      (Icons.handyman_rounded, s('cat.masters'), Routes.masters),
      (Icons.work_outline_rounded, s('cat.jobs'), Routes.jobs),
      (Icons.business_rounded, s('cat.companies'), Routes.companies),
      (Icons.map_rounded, s('map.title'), Routes.map),
      (Icons.article_outlined, s('cat.news'), Routes.news),
    ];
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final c = cats[i];
          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => context.push(c.$3),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(999),
                boxShadow: context.softShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(c.$1, size: 17, color: AppColors.primary),
                  const SizedBox(width: 7),
                  Text(c.$2,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── 2 qatorli, gorizontal skrol qiladigan kategoriyalar (API) ──────────────
(IconData, Color) _categoryVisual(String key) => switch (key) {
      'APARTMENT' => (Icons.apartment_rounded, AppColors.primary),
      'HOUSE' => (Icons.house_rounded, const Color(0xFF0F80FF)),
      'OFFICE' => (Icons.business_center_rounded, const Color(0xFF7F4DFF)),
      'RETAIL' => (Icons.storefront_rounded, const Color(0xFF10B782)),
      'RENT' => (Icons.vpn_key_rounded, AppColors.accent),
      'NEW_BUILDING' => (Icons.location_city_rounded, const Color(0xFF14B8A6)),
      'MASTER' => (Icons.handyman_rounded, const Color(0xFFFF8A3D)),
      'JOB' => (Icons.work_outline_rounded, const Color(0xFFE5484D)),
      _ => (Icons.category_outlined, AppColors.primary),
    };

void _openCategory(BuildContext context, String key) {
  switch (key) {
    case 'APARTMENT':
    case 'HOUSE':
    case 'OFFICE':
    case 'RETAIL':
      context.push('${Routes.estates}?propertyType=$key');
      break;
    case 'RENT':
      context.push('${Routes.estates}?dealType=RENT');
      break;
    case 'NEW_BUILDING':
      context.push(Routes.newbuilds);
      break;
    case 'MASTER':
      context.push(Routes.masters);
      break;
    case 'JOB':
      context.push(Routes.jobs);
      break;
    default:
      context.push(Routes.estates);
  }
}

class _CategoryGrid extends StatefulWidget {
  const _CategoryGrid({required this.categories});
  final List<HomeCategory> categories;

  @override
  State<_CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<_CategoryGrid> {
  final _scroll = ScrollController();
  double _progress = 0;
  double _thumbFraction = 1;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    final total = pos.maxScrollExtent + pos.viewportDimension;
    setState(() {
      _progress = pos.maxScrollExtent <= 0
          ? 0
          : (pos.pixels / pos.maxScrollExtent).clamp(0, 1);
      _thumbFraction =
          total <= 0 ? 1 : (pos.viewportDimension / total).clamp(0.12, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categories;
    if (categories.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        children: [
          SizedBox(
            height: 176,
            child: GridView.builder(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 10,
                mainAxisExtent: 84,
              ),
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final c = categories[i];
                final (icon, color) = _categoryVisual(c.key);
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _openCategory(context, c.key),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 76,
                        child: Text(c.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          _ScrollTrack(progress: _progress, thumbFraction: _thumbFraction),
        ],
      ),
    );
  }
}

/// x-o'qi bo'yicha skrol borligini bildiradigan juda kichik, minimalist chiziq.
class _ScrollTrack extends StatelessWidget {
  const _ScrollTrack({required this.progress, required this.thumbFraction});
  final double progress;
  final double thumbFraction;

  @override
  Widget build(BuildContext context) {
    const trackWidth = 36.0;
    final thumbWidth = (trackWidth * thumbFraction).clamp(10.0, trackWidth);
    final left = (trackWidth - thumbWidth) * progress;
    return SizedBox(
      width: trackWidth,
      height: 4,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 80),
            left: left,
            child: Container(
              width: thumbWidth,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero banner ─────────────────────────────────────────────────────────────
class _Hero extends StatefulWidget {
  const _Hero({required this.banners, required this.s});
  final List<HomeBanner> banners;
  final AppStrings s;

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final banners = widget.banners;
    if (banners.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: _BrandHero(s: widget.s),
      );
    }
    return Column(
      children: [
        const SizedBox(height: 16),
        CarouselSlider.builder(
          itemCount: banners.length,
          options: CarouselOptions(
            height: 232,
            viewportFraction: 1,
            padEnds: false,
            autoPlay: banners.length > 1,
            autoPlayInterval: const Duration(seconds: 6),
            onPageChanged: (i, _) => setState(() => _i = i),
          ),
          itemBuilder: (ctx, i, _) {
            final b = banners[i];
            return GestureDetector(
              onTap: (b.link == null || b.link!.isEmpty)
                  ? null
                  : () => openUrlExternal(ctx, b.link!),
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(raw: b.image, fit: BoxFit.cover),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x22000000), Color(0xE00B0F17)],
                          stops: [0.35, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if ((b.title ?? '').trim().isNotEmpty)
                            Text(
                              b.title!.trim(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                                shadows: [
                                  Shadow(color: Colors.black87, blurRadius: 10),
                                ],
                              ),
                            ),
                          if ((b.link ?? '').isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text('Batafsil →',
                                  style: TextStyle(
                                      color: AppColors.primaryDeep,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (banners.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (k) {
              final active = k == _i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : context.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _BrandHero extends StatelessWidget {
  const _BrandHero({required this.s});
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ProHome',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(s('home.brand_tagline'),
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 13,
                  height: 1.4)),
        ],
      ),
    );
  }
}

// ─── Stats ───────────────────────────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.stats, required this.s});
  final HomeStats stats;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    final data = [
      (compactPrice(stats.estates), s('cat.estates')),
      (compactPrice(stats.masters), s('cat.masters')),
      (compactPrice(stats.jobs), s('cat.jobs')),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          boxShadow: context.softShadow,
        ),
        child: Row(
          children: [
            for (var k = 0; k < data.length; k++) ...[
              Expanded(
                child: Column(
                  children: [
                    Text(data[k].$1,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 19,
                            color: AppColors.primary)),
                    Text(data[k].$2,
                        style: TextStyle(fontSize: 11.5, color: context.muted)),
                  ],
                ),
              ),
              if (k < data.length - 1)
                Container(width: 1, height: 30, color: context.border),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Oxirgi ko'rilganlar ─────────────────────────────────────────────────────
class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.entry});
  final RecentEntry entry;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      onTap: () => context.push(entry.kind == RecentKind.master
          ? Routes.master(entry.id)
          : Routes.estate(entry.id)),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          boxShadow: context.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppNetworkImage(raw: entry.image, height: 84, width: double.infinity),
            ),
            const SizedBox(height: 8),
            Text(entry.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
            if (entry.subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(entry.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: context.muted)),
            ],
          ],
        ),
      ),
    );
  }
}
