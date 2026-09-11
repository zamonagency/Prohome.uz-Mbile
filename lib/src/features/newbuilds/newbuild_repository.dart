import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/paginated.dart';
import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import 'newbuild_model.dart';

class NewBuildRepository {
  NewBuildRepository(this._api);
  final ApiClient _api;

  static const _b2c = Env.b2cApiBaseUrl;

  Future<List<B2CProject>> projects() async {
    final res = await _api.get('/room/b2c/projects', baseUrl: _b2c, auth: false);
    final list = res is Map ? res['data'] : res;
    return (list is List ? list : const [])
        .whereType<Map>()
        .map((e) => B2CProject.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Paginated<B2CRoom>> rooms({
    int page = 1,
    int limit = 20,
    int? projectId,
    String? search,
    String? status,
    num? minPrice,
    num? maxPrice,
  }) async {
    final res = await _api.get('/room/b2c/rooms', baseUrl: _b2c, auth: false, query: {
      'page': page,
      'limit': limit,
      if (projectId != null) 'projectId': projectId,
      if (search?.isNotEmpty ?? false) 'search': search,
      if (status != null) 'status': status,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
    });
    return Paginated.parse(res, B2CRoom.fromJson);
  }

  Future<B2CRoom> roomDetail({int? id, int? roomNumber}) async {
    final res = await _api.get('/room/b2c/room-detail', baseUrl: _b2c, auth: false, query: {
      if (id != null) 'id': id,
      if (roomNumber != null) 'roomNumber': roomNumber,
    });
    return B2CRoom.fromJson(unwrap(res));
  }
}

final newBuildRepositoryProvider = Provider<NewBuildRepository>(
  (ref) => NewBuildRepository(ref.watch(apiClientProvider)),
);

final b2cProjectsProvider = FutureProvider<List<B2CProject>>(
  (ref) => ref.watch(newBuildRepositoryProvider).projects(),
);

final b2cRoomDetailProvider = FutureProvider.family<B2CRoom, int>(
  (ref, id) => ref.watch(newBuildRepositoryProvider).roomDetail(id: id),
);
