import '../../common/models/location.dart';
import '../../common/models/paginated.dart';
import '../../common/models/user.dart';
import '../../core/utils/media.dart';

class PropertyMedia {
  const PropertyMedia({required this.id, required this.url, this.isMain = false, this.type = 'IMAGE'});
  final int id;
  final String url;
  final bool isMain;
  final String type;

  bool get isVideo => type == 'VIDEO';
  String get fullUrl => mediaUrl(url);

  factory PropertyMedia.fromJson(Map<String, dynamic> j) => PropertyMedia(
        id: asInt(j['id']) ?? 0,
        url: asString(j['url']),
        isMain: asBool(j['isMain']),
        type: asString(j['mediaType'], 'IMAGE'),
      );
}

class RealEstate {
  const RealEstate({
    required this.id,
    required this.title,
    this.description,
    this.price = 0,
    this.propertyType = 'APARTMENT',
    this.dealType = 'SALE',
    this.sellerType = 'INDIVIDUAL',
    this.contactPhone = '',
    this.companyName,
    this.companyLogo,
    this.areaSize = 0,
    this.roomCount = 0,
    this.floor,
    this.totalFloors,
    this.plotSize,
    this.latitude,
    this.longitude,
    this.viewCount = 0,
    this.likeCount = 0,
    this.status = 'ACTIVE',
    this.location,
    this.user,
    this.media = const [],
    this.createdAt,
    this.similar = const [],
  });

  final int id;
  final String title;
  final String? description;
  final num price;
  final String propertyType;
  final String dealType;
  final String sellerType;
  final String contactPhone;
  final String? companyName;
  final String? companyLogo;
  final num areaSize;
  final int roomCount;
  final int? floor;
  final int? totalFloors;
  final num? plotSize;
  final double? latitude;
  final double? longitude;
  final int viewCount;
  final int likeCount;
  final String status;
  final AppLocation? location;
  final AppUser? user;
  final List<PropertyMedia> media;
  final String? createdAt;
  /// Shu e'longa o'xshash (bir xil toifa/bitim turi, imkon qadar bir xil
  /// joylashuvdan) e'lonlar — detail javobida allaqachon kelib turadi.
  final List<RealEstate> similar;

  bool get isRent => dealType == 'RENT';
  bool get hasGeo => latitude != null && longitude != null;

  String get cover {
    if (media.isEmpty) return '';
    final main = media.firstWhere(
      (m) => m.isMain && !m.isVideo,
      orElse: () => media.firstWhere((m) => !m.isVideo,
          orElse: () => media.first),
    );
    return main.fullUrl;
  }

  List<String> get gallery =>
      media.where((m) => !m.isVideo).map((m) => m.fullUrl).toList();

  String get locationName => location?.name ?? companyName ?? '';

  factory RealEstate.fromJson(Map<String, dynamic> j) => RealEstate(
        id: asInt(j['id']) ?? 0,
        title: asString(j['title']),
        description: j['description']?.toString(),
        price: asDouble(j['price']) ?? 0,
        propertyType: asString(j['propertyType'], 'APARTMENT'),
        dealType: asString(j['dealType'], 'SALE'),
        sellerType: asString(j['sellerType'], 'INDIVIDUAL'),
        contactPhone: asString(j['contactPhone']),
        companyName: j['companyName']?.toString(),
        companyLogo: j['companyLogo']?.toString(),
        areaSize: asDouble(j['areaSize']) ?? 0,
        roomCount: asInt(j['roomCount']) ?? 0,
        floor: asInt(j['floor']),
        totalFloors: asInt(j['totalFloors']),
        plotSize: asDouble(j['plotSize']),
        latitude: asDouble(j['latitude']),
        longitude: asDouble(j['longitude']),
        viewCount: asInt(j['viewCount']) ?? 0,
        likeCount: asInt(j['likeCount']) ?? 0,
        status: asString(j['status'], 'ACTIVE'),
        location: j['location'] is Map
            ? AppLocation.fromJson(Map<String, dynamic>.from(j['location']))
            : null,
        user: j['user'] is Map
            ? AppUser.fromJson(Map<String, dynamic>.from(j['user']))
            : null,
        media: (j['media'] is List ? j['media'] as List : const [])
            .whereType<Map>()
            .map((e) => PropertyMedia.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        createdAt: j['createdAt']?.toString(),
        similar: (j['similar'] is List ? j['similar'] as List : const [])
            .whereType<Map>()
            .map((e) => RealEstate.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}
