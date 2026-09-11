import 'package:flutter/material.dart';

import '../models/paginated.dart';
import 'state_views.dart';

typedef PageFetcher<T> = Future<Paginated<T>> Function(int page);

/// Cheksiz skroll + pull-to-refresh bilan universal ro'yxat/grid.
/// Tashqi paket ishlatmaydi — to'liq mustaqil.
class AppPagedList<T> extends StatefulWidget {
  const AppPagedList({
    super.key,
    required this.fetch,
    required this.itemBuilder,
    this.pageSize = 20,
    this.padding = const EdgeInsets.all(16),
    this.separatorHeight = 12,
    this.gridDelegate,
    this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
  });

  final PageFetcher<T> fetch;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final int pageSize;
  final EdgeInsets padding;
  final double separatorHeight;
  final SliverGridDelegate? gridDelegate;
  final String? emptyMessage;
  final IconData emptyIcon;

  @override
  State<AppPagedList<T>> createState() => AppPagedListState<T>();
}

class AppPagedListState<T> extends State<AppPagedList<T>> {
  final _scroll = ScrollController();
  final List<T> _items = [];

  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  bool _firstDone = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _loadNext();
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >=
        _scroll.position.maxScrollExtent - 480) {
      _loadNext();
    }
  }

  Future<void> _loadNext() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      final res = await widget.fetch(_page);
      if (!mounted) return;
      setState(() {
        _items.addAll(res.items);
        _hasMore = res.hasMore && res.items.length >= widget.pageSize;
        _page++;
        _error = null;
        _firstDone = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _firstDone = true;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> refresh() async {
    setState(() {
      _items.clear();
      _page = 1;
      _hasMore = true;
      _error = null;
      _firstDone = false;
    });
    await _loadNext();
  }

  @override
  Widget build(BuildContext context) {
    if (!_firstDone && _loading) {
      return const SkeletonList(count: 6);
    }
    if (_items.isEmpty && _error != null) {
      return ErrorView(error: _error!, onRetry: refresh);
    }
    if (_items.isEmpty) {
      return RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: EmptyView(
                  icon: widget.emptyIcon, message: widget.emptyMessage),
            ),
          ],
        ),
      );
    }

    final footer = _loading
        ? const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.2)),
          )
        : (_error != null
            ? Center(
                child: TextButton(
                    onPressed: _loadNext,
                    child: const Text('Qayta urinish')),
              )
            : const SizedBox(height: 8));

    return RefreshIndicator(
      onRefresh: refresh,
      child: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverPadding(
            padding: widget.padding,
            sliver: widget.gridDelegate != null
                ? SliverGrid(
                    gridDelegate: widget.gridDelegate!,
                    delegate: SliverChildBuilderDelegate(
                      (c, i) => widget.itemBuilder(c, _items[i], i),
                      childCount: _items.length,
                    ),
                  )
                : SliverList.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: widget.separatorHeight),
                    itemBuilder: (c, i) =>
                        widget.itemBuilder(c, _items[i], i),
                  ),
          ),
          SliverToBoxAdapter(child: footer),
        ],
      ),
    );
  }
}
