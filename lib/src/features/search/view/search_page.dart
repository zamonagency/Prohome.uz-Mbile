import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/settings_controller.dart';
import '../../../common/widgets/paged_list.dart';
import '../../jobs/job_repository.dart';
import '../../jobs/widgets/job_card.dart';
import '../../masters/master_repository.dart';
import '../../masters/widgets/master_card.dart';
import '../../realestate/real_estate_repository.dart';
import '../../realestate/widgets/real_estate_card.dart';

/// Bosh sahifadagi qidiruv qatori aynan shu yerga olib keladi — "Uy, usta
/// yoki ish qidiring" degan va'daga mos, uchala turdagi natijalarni ham
/// bitta joyda, sahifalarga bo'lib ko'rsatadi.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, this.initialQuery});
  final String? initialQuery;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final _ctrl = TextEditingController(text: widget.initialQuery ?? '');
  String _query = '';

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery?.trim() ?? '';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _ctrl,
            autofocus: widget.initialQuery == null,
            textInputAction: TextInputAction.search,
            onSubmitted: (v) => setState(() => _query = v.trim()),
            decoration: InputDecoration(
              isDense: true,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: s('home.search_hint'),
            ),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: s('cat.estates')),
              Tab(text: s('cat.masters')),
              Tab(text: s('cat.jobs')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AppPagedList(
              key: ValueKey('estate$_query'),
              fetch: (page) => ref.read(realEstateRepositoryProvider).list(
                    page: page,
                    filter: RealEstateFilter(search: _query.isEmpty ? null : _query),
                  ),
              itemBuilder: (_, item, __) => RealEstateCard(item: item),
              emptyIcon: Icons.home_work_outlined,
              emptyMessage: s('common.empty'),
            ),
            AppPagedList(
              key: ValueKey('master$_query'),
              fetch: (page) => ref.read(masterRepositoryProvider).list(
                    page: page,
                    search: _query.isEmpty ? null : _query,
                  ),
              itemBuilder: (_, m, __) => MasterCard(master: m),
              emptyIcon: Icons.handyman_outlined,
              emptyMessage: s('common.empty'),
            ),
            AppPagedList(
              key: ValueKey('job$_query'),
              fetch: (page) => ref.read(jobRepositoryProvider).list(
                    page: page,
                    search: _query.isEmpty ? null : _query,
                  ),
              itemBuilder: (_, j, __) => JobCard(job: j),
              emptyIcon: Icons.work_outline_rounded,
              emptyMessage: s('common.empty'),
            ),
          ],
        ),
      ),
    );
  }
}
