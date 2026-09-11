import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/settings_controller.dart';
import '../../../app/theme.dart';
import '../../../common/widgets/paged_list.dart';
import '../../auth/auth_controller.dart';
import '../real_estate_repository.dart';
import '../widgets/real_estate_card.dart';
import 'filter_sheet.dart';

class RealEstateListPage extends ConsumerStatefulWidget {
  const RealEstateListPage({
    super.key,
    this.initialSearch,
    this.title,
    this.initialPropertyType,
    this.initialDealType,
    this.initialFilter,
    this.openFilterOnStart = false,
    this.onlyMine = false,
  });
  final String? initialSearch;
  final String? title;
  final String? initialPropertyType;
  final String? initialDealType;
  /// Bosh sahifadagi filtr varag'idan to'liq holda kelsa — boshqa
  /// `initial*` maydonlardan ustun turadi.
  final RealEstateFilter? initialFilter;
  final bool openFilterOnStart;
  /// "Mening e'lonlarim" — faqat joriy foydalanuvchi e'lonlari.
  final bool onlyMine;

  @override
  ConsumerState<RealEstateListPage> createState() => _RealEstateListPageState();
}

class _RealEstateListPageState extends ConsumerState<RealEstateListPage> {
  late final _searchCtrl = TextEditingController(text: widget.initialSearch ?? '');
  RealEstateFilter _filter = const RealEstateFilter();
  bool _grid = true;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter?.copyWith(
          search: widget.initialSearch?.isNotEmpty ?? false ? widget.initialSearch : null,
        ) ??
        _filter.copyWith(
          search: widget.initialSearch?.isNotEmpty ?? false ? widget.initialSearch : null,
          propertyType: widget.initialPropertyType,
          dealType: widget.initialDealType,
        );
    if (widget.onlyMine) {
      final myId = ref.read(currentUserProvider)?.id;
      if (myId != null) _filter = _filter.copyWith(userId: myId);
    }
    if (widget.openFilterOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openFilter();
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applySearch() {
    setState(() => _filter = _filter.copyWith(search: _searchCtrl.text.trim()));
  }

  Future<void> _openFilter() async {
    final res = await FilterSheet.show(context, _filter);
    if (res != null) setState(() => _filter = res.copyWith(search: _searchCtrl.text.trim()));
  }

  int get _activeFilters => [
        _filter.dealType,
        _filter.propertyType,
        _filter.rooms,
        _filter.minPrice,
        _filter.maxPrice,
      ].where((e) => e != null).length;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ??
            (widget.onlyMine ? s('profile.my_listings') : s('cat.estates'))),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _applySearch(),
                    decoration: InputDecoration(
                      hintText: s('common.search'),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchCtrl.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                _applySearch();
                              },
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Badge(
                  isLabelVisible: _activeFilters > 0,
                  label: Text('$_activeFilters'),
                  child: Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _openFilter,
                      child: const SizedBox(
                        width: 52,
                        height: 52,
                        child: Icon(Icons.tune_rounded, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AppPagedList(
              key: ValueKey(_filter.toQuery().toString()),
              fetch: (page) => ref
                  .read(realEstateRepositoryProvider)
                  .list(page: page, filter: _filter),
              gridDelegate: _grid
                  ? const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.66,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                    )
                  : null,
              itemBuilder: (_, item, __) =>
                  _grid ? RealEstateMiniCard(item: item) : RealEstateCard(item: item),
              emptyIcon: Icons.home_work_outlined,
              emptyMessage: s('common.empty'),
            ),
          ),
        ],
      ),
    );
  }
}
