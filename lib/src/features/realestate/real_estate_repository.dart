import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/paginated.dart';
import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import 'real_estate_model.dart';

class RealEstateFilter {
  const RealEstateFilter({
    this.search,
    this.dealType,
    this.propertyType,
    this.minPrice,
    this.maxPrice,
    this.rooms,
    this.locationId,
    this.sort,
    this.userId,
    this.bbox,
  });

  final String? search;
  final String? dealType;
  final String? propertyType;
  final num? minPrice;
  final num? maxPrice;
  final int? rooms;
  final int? locationId;
  final String? sort;
  /// Faqat shu foydalanuvchining e'lonlari ("Mening e'lonlarim").
  final int? userId;
  /// Xarita/yaqin atrofdagi e'lonlar uchun bounding box.
  final GeoBounds? bbox;

  Map<String, dynamic> toQuery() => {
        if (search?.isNotEmpty ?? false) 'search': search,
        if (dealType != null) 'dealType': dealType,
        if (propertyType != null) 'propertyType': propertyType,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (rooms != null) 'roomCount': rooms,
        if (locationId != null) 'locationId': locationId,
        if (sort != null) 'sort': sort,
        if (userId != null) 'userId': userId,
        if (bbox != null) ...bbox!.toQuery(),
      };

  RealEstateFilter copyWith({
    String? search,
    Object? dealType = _sentinel,
    Object? propertyType = _sentinel,
    Object? minPrice = _sentinel,
    Object? maxPrice = _sentinel,
    Object? rooms = _sentinel,
    Object? locationId = _sentinel,
    String? sort,
    Object? userId = _sentinel,
    Object? bbox = _sentinel,
  }) {
    return RealEstateFilter(
      search: search ?? this.search,
      dealType: dealType == _sentinel ? this.dealType : dealType as String?,
      propertyType:
          propertyType == _sentinel ? this.propertyType : propertyType as String?,
      minPrice: minPrice == _sentinel ? this.minPrice : minPrice as num?,
      maxPrice: maxPrice == _sentinel ? this.maxPrice : maxPrice as num?,
      rooms: rooms == _sentinel ? this.rooms : rooms as int?,
      locationId: locationId == _sentinel ? this.locationId : locationId as int?,
      sort: sort ?? this.sort,
      userId: userId == _sentinel ? this.userId : userId as int?,
      bbox: bbox == _sentinel ? this.bbox : bbox as GeoBounds?,
    );
  }

  bool get isEmpty =>
      (search?.isEmpty ?? true) &&
      dealType == null &&
      propertyType == null &&
      minPrice == null &&
      maxPrice == null &&
      rooms == null &&
      locationId == null;

  static const _sentinel = Object();
}

/// Xarita ko'rinishi / "yaqin atrofda" qidiruv uchun to'rtburchak hudud.
class GeoBounds {
  const GeoBounds({
    required this.swLat,
    required this.swLng,
    required this.neLat,
    required this.neLng,
  });

  /// Berilgan markaz atrofida (km radiusda) taxminiy to'rtburchak hosil qiladi.
  factory GeoBounds.aroundKm(double lat, double lng, double radiusKm) {
    final dLat = radiusKm / 111.0;
    final dLng = radiusKm / (111.0 * cos(lat * pi / 180));
    return GeoBounds(
      swLat: lat - dLat,
      swLng: lng - dLng,
      neLat: lat + dLat,
      neLng: lng + dLng,
    );
  }

  final double swLat;
  final double swLng;
  final double neLat;
  final double neLng;

  Map<String, dynamic> toQuery() => {
        'swLat': swLat,
        'swLng': swLng,
        'neLat': neLat,
        'neLng': neLng,
      };
}

class RealEstateRepository {
  RealEstateRepository(this._api);
  final ApiClient _api;

  Future<Paginated<RealEstate>> list({
    int page = 1,
    int limit = 20,
    RealEstateFilter filter = const RealEstateFilter(),
  }) async {
    final res = await _api.get('/real-estates', query: {
      'page': page,
      'limit': limit,
      ...filter.toQuery(),
    });
    return Paginated.parse(res, RealEstate.fromJson);
  }

  Future<RealEstate> byId(int id) async {
    final res = await _api.get('/real-estates/$id');
    return RealEstate.fromJson(unwrap(res));
  }

  Future<void> recordView(int id) async {
    try {
      await _api.post('/real-estates/$id/view');
    } catch (_) {}
  }

  Future<RealEstate> create(Map<String, dynamic> body) async {
    final res = await _api.post('/real-estates', body: body);
    return RealEstate.fromJson(unwrap(res));
  }

  /// Rasm yuklash — WebP'ga backend tomonidan avtomatik aylantiriladi.
  Future<void> uploadImage(int id, List<int> bytes, String filename,
      {bool isMain = false}) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    await _api.multipart('/real-estates/$id/media/image?isMain=$isMain', form: form);
  }

  Future<Paginated<RealEstate>> mine(int userId, {int page = 1, int limit = 20}) async {
    final res = await _api.get('/real-estates',
        query: {'page': page, 'limit': limit, 'userId': userId});
    return Paginated.parse(res, RealEstate.fromJson);
  }
}

final realEstateRepositoryProvider = Provider<RealEstateRepository>(
  (ref) => RealEstateRepository(ref.watch(apiClientProvider)),
);

final realEstateDetailProvider =
    FutureProvider.family<RealEstate, int>((ref, id) async {
  final repo = ref.watch(realEstateRepositoryProvider);
  final item = await repo.byId(id);
  repo.recordView(id);
  return item;
});
