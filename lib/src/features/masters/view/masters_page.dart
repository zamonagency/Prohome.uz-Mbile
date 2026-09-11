import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/settings_controller.dart';
import '../../../app/theme.dart';
import '../../../common/widgets/paged_list.dart';
import '../master_repository.dart';
import '../widgets/master_card.dart';

class MastersPage extends ConsumerStatefulWidget {
  const MastersPage({super.key});

  @override
  ConsumerState<MastersPage> createState() => _MastersPageState();
}

class _MastersPageState extends ConsumerState<MastersPage> {
  final _search = TextEditingController();
  int? _skillTypeId;
  bool _onlyFree = false;
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
    final skillTypes = ref.watch(skillTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s('cat.masters')),
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
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(s('master.free_now')),
                    selected: _onlyFree,
                    onSelected: (v) => setState(() => _onlyFree = v),
                    selectedColor: AppColors.primary,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                        color: _onlyFree ? Colors.white : null,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                ...skillTypes.maybeWhen(
                  data: (list) => list
                      .map((t) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(t.name),
                              selected: _skillTypeId == t.id,
                              onSelected: (_) => setState(() => _skillTypeId =
                                  _skillTypeId == t.id ? null : t.id),
                              showCheckmark: false,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                  color: _skillTypeId == t.id
                                      ? Colors.white
                                      : null,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600),
                            ),
                          ))
                      .toList(),
                  orElse: () => const <Widget>[],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: AppPagedList(
              key: ValueKey('$_query$_skillTypeId$_onlyFree'),
              fetch: (page) => ref.read(masterRepositoryProvider).list(
                    page: page,
                    search: _query.isEmpty ? null : _query,
                    skillTypeId: _skillTypeId,
                    onlyFree: _onlyFree,
                  ),
              gridDelegate: _grid
                  ? const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.62,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                    )
                  : null,
              itemBuilder: (_, m, __) =>
                  _grid ? MasterGridCard(master: m) : MasterCard(master: m),
              emptyIcon: Icons.handyman_outlined,
            ),
          ),
        ],
      ),
    );
  }
}
