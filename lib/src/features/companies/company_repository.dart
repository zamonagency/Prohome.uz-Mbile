import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/paginated.dart';
import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import '../realestate/real_estate_model.dart';
import 'company_model.dart';

class CompanyRepository {
  CompanyRepository(this._api);
  final ApiClient _api;

  Future<Paginated<Company>> list({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final res = await _api.get('/companies', query: {
      'page': page,
      'limit': limit,
      if (search?.isNotEmpty ?? false) 'search': search,
    });
    return Paginated.parse(res, Company.fromJson);
  }

  Future<Company> byId(int id) async {
    final res = await _api.get('/companies/$id');
    return Company.fromJson(unwrap(res));
  }

  Future<void> recordView(int id) async {
    try {
      await _api.post('/companies/$id/view');
    } catch (_) {}
  }

  Future<Paginated<Complex>> complexes({int page = 1, int limit = 20}) async {
    final res =
        await _api.get('/complexes', query: {'page': page, 'limit': limit});
    return Paginated.parse(res, Complex.fromJson);
  }

  Future<Paginated<RealEstate>> complexApartments(int id,
      {int page = 1, int limit = 50}) async {
    final res = await _api
        .get('/complexes/$id/apartments', query: {'page': page, 'limit': limit});
    return Paginated.parse(res, RealEstate.fromJson);
  }
}

final companyRepositoryProvider = Provider<CompanyRepository>(
  (ref) => CompanyRepository(ref.watch(apiClientProvider)),
);

final companyDetailProvider = FutureProvider.family<Company, int>((ref, id) async {
  final repo = ref.watch(companyRepositoryProvider);
  final c = await repo.byId(id);
  repo.recordView(id);
  return c;
});
