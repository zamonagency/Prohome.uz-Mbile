import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/paginated.dart';
import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import 'master_model.dart';

class MasterRepository {
  MasterRepository(this._api);
  final ApiClient _api;

  Future<Paginated<Master>> list({
    int page = 1,
    int limit = 20,
    String? search,
    int? skillTypeId,
    bool? onlyFree,
    MasterWorkType? workType,
  }) async {
    final res = await _api.get('/masters', query: {
      'page': page,
      'limit': limit,
      if (search?.isNotEmpty ?? false) 'search': search,
      if (skillTypeId != null) 'skillTypeId': skillTypeId,
      if (onlyFree == true) 'isFree': true,
      if (workType != null) 'workType': workType.isTeam ? 'TEAM' : 'INDIVIDUAL',
    });
    return Paginated.parse(res, Master.fromJson);
  }

  Future<Master> byId(int id) async {
    final res = await _api.get('/masters/$id');
    return Master.fromJson(unwrap(res));
  }

  Future<void> recordView(int id) async {
    try {
      await _api.post('/masters/$id/view');
    } catch (_) {}
  }

  Future<List<Master>> top() async {
    try {
      final res = await _api.get('/masters/top');
      final list = res is List ? res : (res is Map ? res['data'] : null);
      return (list is List ? list : const [])
          .whereType<Map>()
          .map((e) => Master.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<SkillType>> skillTypes() async {
    try {
      final res = await _api.get('/skill-types', query: {'status': 'ACTIVE'});
      final list = res is List ? res : (res is Map ? res['data'] : null);
      return (list is List ? list : const [])
          .whereType<Map>()
          .map((e) => SkillType.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Tanlangan kasb turiga (`skillTypeId`) tegishli aniq ko'nikmalar —
  /// usta ro'yxatdan o'tishda kamida bittasi tanlanishi shart.
  Future<List<Skill>> skillsByType(int typeId) async {
    try {
      final res = await _api.get('/skills',
          query: {'typeId': typeId, 'status': 'ACTIVE', 'limit': 100});
      final list = res is List ? res : (res is Map ? res['data'] : null);
      return (list is List ? list : const [])
          .whereType<Map>()
          .map((e) => Skill.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Ro'yxatdan o'tgandan keyin narxni (salary) qo'shish uchun —
  /// `/auth/master/register` bu maydonni qabul qilmaydi, shu sabab
  /// alohida, eng oxirida, best-effort tarzda yuboriladi.
  Future<void> patchMe({num? salary}) async {
    if (salary == null) return;
    try {
      final me = await _api.get('/masters/me/profile');
      final id = asInt(me is Map ? me['id'] : null);
      if (id == null) return;
      await _api.patch('/masters/$id', body: {'salary': salary});
    } catch (_) {
      // Best-effort — muvaffaqiyatsiz bo'lsa ham ro'yxatdan o'tish tugallangan.
    }
  }

  Future<Paginated<MasterRating>> ratings(int masterId,
      {int page = 1, int limit = 20}) async {
    final res = await _api
        .get('/ratings/master/$masterId', query: {'page': page, 'limit': limit});
    return Paginated.parse(res, MasterRating.fromJson);
  }
}

final masterRepositoryProvider = Provider<MasterRepository>(
  (ref) => MasterRepository(ref.watch(apiClientProvider)),
);

final masterDetailProvider = FutureProvider.family<Master, int>((ref, id) async {
  final repo = ref.watch(masterRepositoryProvider);
  final m = await repo.byId(id);
  repo.recordView(id);
  return m;
});

final skillTypesProvider = FutureProvider<List<SkillType>>(
  (ref) => ref.watch(masterRepositoryProvider).skillTypes(),
);

final skillsByTypeProvider = FutureProvider.family<List<Skill>, int>(
  (ref, typeId) => ref.watch(masterRepositoryProvider).skillsByType(typeId),
);
