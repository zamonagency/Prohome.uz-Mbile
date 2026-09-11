import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/paginated.dart';
import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import '../realestate/real_estate_repository.dart' show GeoBounds;
import 'job_model.dart';

class JobRepository {
  JobRepository(this._api);
  final ApiClient _api;

  Future<Paginated<Job>> list({
    int page = 1,
    int limit = 20,
    String? search,
    int? skillTypeId,
    GeoBounds? bbox,
  }) async {
    final res = await _api.get('/jobs', query: {
      'page': page,
      'limit': limit,
      if (search?.isNotEmpty ?? false) 'search': search,
      if (skillTypeId != null) 'skillTypeId': skillTypeId,
      if (bbox != null) ...bbox.toQuery(),
    });
    return Paginated.parse(res, Job.fromJson);
  }

  Future<Job> byId(int id) async {
    final res = await _api.get('/jobs/$id');
    return Job.fromJson(unwrap(res));
  }

  Future<void> recordView(int id) async {
    try {
      await _api.post('/jobs/$id/view');
    } catch (_) {}
  }

  Future<Job> create(Map<String, dynamic> body) async {
    final res = await _api.post('/jobs', body: body);
    return Job.fromJson(unwrap(res));
  }
}

final jobRepositoryProvider = Provider<JobRepository>(
  (ref) => JobRepository(ref.watch(apiClientProvider)),
);

final jobDetailProvider = FutureProvider.family<Job, int>((ref, id) async {
  final repo = ref.watch(jobRepositoryProvider);
  final j = await repo.byId(id);
  repo.recordView(id);
  return j;
});
