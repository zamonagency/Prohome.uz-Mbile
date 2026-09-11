import '../../common/models/paginated.dart';
import '../../core/utils/media.dart';

class Complex {
  const Complex({
    required this.id,
    this.name = '',
    this.address = '',
    this.images = const [],
    this.latitude,
    this.longitude,
  });
  final int id;
  final String name;
  final String address;
  final List<String> images;
  final double? latitude;
  final double? longitude;

  String get cover => images.isEmpty ? '' : mediaUrl(images.first);

  factory Complex.fromJson(Map<String, dynamic> j) => Complex(
        id: asInt(j['id']) ?? 0,
        name: asString(j['nameUz'], asString(j['nameRu'], asString(j['name']))),
        address: asString(j['address']),
        images: asStringList(j['images']),
        latitude: asDouble(j['latitude']),
        longitude: asDouble(j['longitude']),
      );
}

class Company {
  const Company({
    required this.id,
    this.name = '',
    this.phone,
    this.logo,
    this.description,
    this.website,
    this.isVerified = false,
    this.viewCount = 0,
    this.complexes = const [],
  });

  final int id;
  final String name;
  final String? phone;
  final String? logo;
  final String? description;
  final String? website;
  final bool isVerified;
  final int viewCount;
  final List<Complex> complexes;

  String get logoUrl => mediaUrl(logo);

  factory Company.fromJson(Map<String, dynamic> j) => Company(
        id: asInt(j['id']) ?? 0,
        name: asString(j['name']),
        phone: j['phone']?.toString(),
        logo: j['logo']?.toString(),
        description: j['description']?.toString(),
        website: j['website']?.toString(),
        isVerified: asBool(j['isVerified']),
        viewCount: asInt(j['viewCount']) ?? 0,
        complexes: (j['complexes'] is List ? j['complexes'] as List : const [])
            .whereType<Map>()
            .map((e) => Complex.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}
