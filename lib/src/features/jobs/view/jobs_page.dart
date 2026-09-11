import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/settings_controller.dart';
import '../../../common/widgets/paged_list.dart';
import '../../realestate/real_estate_repository.dart' show GeoBounds;
import '../job_repository.dart';
import '../widgets/job_card.dart';

class JobsPage extends ConsumerStatefulWidget {
  const JobsPage({super.key, this.initialBbox, this.title});
  /// Xarita hududi bo'yicha ("shu yerdagi ish o'rinlari") filtrlash uchun.
  final GeoBounds? initialBbox;
  final String? title;

  @override
  ConsumerState<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends ConsumerState<JobsPage> {
  final _search = TextEditingController();
  String _query = '';
  bool _grid = true;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? s('cat.jobs')),
        actions: [
          IconButton(
            tooltip: _grid ? s('common.view_list') : s('common.view_grid'),
            icon: Icon(_grid ? Icons.view_list_rounded : Icons.grid_view_rounded),
            onPressed: () => setState(() => _grid = !_grid),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onSubmitted: (v) => setState(() => _query = v.trim()),
              decoration: InputDecoration(
                hintText: s('common.search'),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
              ),
            ),
          ),
          Expanded(
            child: AppPagedList(
              key: ValueKey(_query),
              fetch: (page) => ref.read(jobRepositoryProvider).list(
                    page: page,
                    search: _query.isEmpty ? null : _query,
                    bbox: widget.initialBbox,
                  ),
              gridDelegate: _grid
                  ? const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                    )
                  : null,
              itemBuilder: (_, j, __) => _grid ? JobGridCard(job: j) : JobCard(job: j),
              emptyIcon: Icons.work_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
