import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/settings_controller.dart';
import '../../../app/theme.dart';
import '../../../common/widgets/state_views.dart';
import '../../jobs/job_model.dart';
import '../../jobs/job_repository.dart';
import '../../jobs/widgets/job_card.dart';
import '../../masters/master_model.dart';
import '../../masters/master_repository.dart';
import '../../masters/widgets/master_card.dart';
import '../../realestate/real_estate_model.dart';
import '../../realestate/real_estate_repository.dart';
import '../../realestate/widgets/real_estate_card.dart';
import '../favorites_controller.dart';

Future<T?> _safe<T>(Future<T> future) => future.then<T?>((v) => v).catchError((_) => null);

final _favEstatesProvider =
    FutureProvider.autoDispose<List<RealEstate>>((ref) async {
  final ids = ref.watch(favoritesProvider.notifier).idsOf(FavKind.estate);
  final repo = ref.watch(realEstateRepositoryProvider);
  final results = await Future.wait(ids.map((id) => _safe(repo.byId(id))));
  return results.whereType<RealEstate>().toList();
});

final _favMastersProvider =
    FutureProvider.autoDispose<List<Master>>((ref) async {
  final ids = ref.watch(favoritesProvider.notifier).idsOf(FavKind.master);
  final repo = ref.watch(masterRepositoryProvider);
  final results = await Future.wait(ids.map((id) => _safe(repo.byId(id))));
  return results.whereType<Master>().toList();
});

final _favJobsProvider = FutureProvider.autoDispose<List<Job>>((ref) async {
  final ids = ref.watch(favoritesProvider.notifier).idsOf(FavKind.job);
  final repo = ref.watch(jobRepositoryProvider);
  final results = await Future.wait(ids.map((id) => _safe(repo.byId(id))));
  return results.whereType<Job>().toList();
});

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(favoritesProvider);
    final s = ref.watch(stringsProvider);
    final estates = ref.watch(_favEstatesProvider);
    final masters = ref.watch(_favMastersProvider);
    final jobs = ref.watch(_favJobsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s('nav.favorites')),
          bottom: TabBar(
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: s('cat.estates')),
              Tab(text: s('cat.masters')),
              Tab(text: s('cat.jobs')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _tab<RealEstate>(
              context, ref, estates,
              (e) => RealEstateCard(item: e),
              () => ref.invalidate(_favEstatesProvider),
              s('fav.empty'),
              Routes.estates,
            ),
            _tab<Master>(
              context, ref, masters,
              (m) => MasterCard(master: m),
              () => ref.invalidate(_favMastersProvider),
              s('fav.empty'),
              Routes.masters,
            ),
            _tab<Job>(
              context, ref, jobs,
              (j) => JobCard(job: j),
              () => ref.invalidate(_favJobsProvider),
              s('fav.empty'),
              Routes.jobs,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab<T>(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<T>> async,
    Widget Function(T) builder,
    VoidCallback onRefresh,
    String emptyMsg,
    String browseRoute,
  ) {
    return async.when(
      loading: () => const SkeletonList(count: 4),
      error: (e, _) => ErrorView(error: e, onRetry: onRefresh),
      data: (list) => list.isEmpty
          ? EmptyView(
              icon: Icons.favorite_border_rounded,
              message: emptyMsg,
              action: OutlinedButton(
                onPressed: () => context.push(browseRoute),
                child: Text(ref.read(stringsProvider)('common.view_all')),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => onRefresh(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => builder(list[i]),
              ),
            ),
    );
  }
}
