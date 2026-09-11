import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/settings_controller.dart';
import '../../../app/theme.dart';
import '../../../common/widgets/paged_list.dart';
import '../news_repository.dart';
import '../widgets/news_card.dart';

class NewsPage extends ConsumerStatefulWidget {
  const NewsPage({super.key});

  @override
  ConsumerState<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends ConsumerState<NewsPage> {
  int? _categoryId;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final cats = ref.watch(newsCategoriesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(s('cat.news'))),
      body: Column(
        children: [
          cats.maybeWhen(
            data: (list) => list.isEmpty
                ? const SizedBox(height: 8)
                : SizedBox(
                    height: 46,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      children: [
                        _chip(s('common.all'), _categoryId == null,
                            () => setState(() => _categoryId = null)),
                        ...list.map((c) => _chip(c.name, _categoryId == c.id,
                            () => setState(() => _categoryId = c.id))),
                      ],
                    ),
                  ),
            orElse: () => const SizedBox(height: 8),
          ),
          Expanded(
            child: AppPagedList(
              key: ValueKey(_categoryId),
              fetch: (page) => ref
                  .read(newsRepositoryProvider)
                  .list(page: page, categoryId: _categoryId),
              itemBuilder: (_, post, __) => NewsCard(post: post),
              emptyIcon: Icons.article_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(
          label: Text(label),
          selected: active,
          onSelected: (_) => onTap(),
          showCheckmark: false,
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
              color: active ? Colors.white : null,
              fontWeight: FontWeight.w600,
              fontSize: 12.5),
        ),
      );
}
