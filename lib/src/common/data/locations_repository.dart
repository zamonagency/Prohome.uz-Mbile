import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import '../models/location.dart';
import '../models/paginated.dart';

class LocationsRepository {
  LocationsRepository(this._api);
  final ApiClient _api;

  Future<List<AppLocation>> all() async {
    try {
      final res = await _api.get('/locations', auth: false, query: {'limit': 500});
      return Paginated.parse(res, AppLocation.fromJson).items;
    } catch (_) {
      return const [];
    }
  }

  Future<List<AppLocation>> top() async {
    try {
      final res = await _api.get('/locations/top', auth: false);
      final list = res is List ? res : (res is Map ? res['data'] : null);
      return (list is List ? list : const [])
          .whereType<Map>()
          .map((e) => AppLocation.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}

final locationsRepositoryProvider = Provider<LocationsRepository>(
  (ref) => LocationsRepository(ref.watch(apiClientProvider)),
);

final allLocationsProvider = FutureProvider<List<AppLocation>>(
  (ref) => ref.watch(locationsRepositoryProvider).all(),
);
