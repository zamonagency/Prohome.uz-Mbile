import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/paginated.dart';
import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import 'news_model.dart';

class NewsRepository {
  NewsRepository(this._api);
  final ApiClient _api;

  Future<Paginated<NewsPost>> list({
    int page = 1,
    int limit = 20,
    int? categoryId,
    String? search,
  }) async {
    final res = await _api.get('/news', query: {
      'page': page,
      'limit': limit,
      'status': 'PUBLISHED',
      if (categoryId != null) 'categoryId': categoryId,
      if (search?.isNotEmpty ?? false) 'search': search,
    });
    return Paginated.parse(res, NewsPost.fromJson);
  }

  Future<NewsPost> byId(int id) async {
    final res = await _api.get('/news/$id');
    return NewsPost.fromJson(unwrap(res));
  }

  Future<List<NewsCategory>> categories() async {
    try {
      final res = await _api.get('/news/categories');
      final list = res is List ? res : (res is Map ? res['data'] : null);
      return (list is List ? list : const [])
          .whereType<Map>()
          .map((e) => NewsCategory.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}

final newsRepositoryProvider = Provider<NewsRepository>(
  (ref) => NewsRepository(ref.watch(apiClientProvider)),
);

final newsDetailProvider = FutureProvider.family<NewsPost, int>(
  (ref, id) => ref.watch(newsRepositoryProvider).byId(id),
);

final newsCategoriesProvider = FutureProvider<List<NewsCategory>>(
  (ref) => ref.watch(newsRepositoryProvider).categories(),
);
