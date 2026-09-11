import '../../common/models/location.dart';
import '../../common/models/paginated.dart';
import '../../common/models/user.dart';

class Job {
  const Job({
    required this.id,
    required this.title,
    this.description = '',
    this.price,
    this.contactPhone = '',
    this.status = 'OPEN',
    this.viewCount = 0,
    this.likeCount = 0,
    this.location,
    this.user,
    this.skillTypeName,
    this.skills = const [],
    this.createdAt,
  });

  final int id;
  final String title;
  final String description;
  final num? price;
  final String contactPhone;
  final String status;
  final int viewCount;
  final int likeCount;
  final AppLocation? location;
  final AppUser? user;
  final String? skillTypeName;
  final List<String> skills;
  final String? createdAt;

  String get locationName => location?.name ?? '';

  factory Job.fromJson(Map<String, dynamic> j) {
    final skillType =
        j['skillType'] is Map ? Map<String, dynamic>.from(j['skillType']) : null;
    return Job(
      id: asInt(j['id']) ?? 0,
      title: asString(j['title']),
      description: asString(j['description']),
      price: asDouble(j['price']),
      contactPhone: asString(j['contactPhone']),
      status: asString(j['status'], 'OPEN'),
      viewCount: asInt(j['viewCount']) ?? 0,
      likeCount: asInt(j['likeCount']) ?? 0,
      location: j['location'] is Map
          ? AppLocation.fromJson(Map<String, dynamic>.from(j['location']))
          : null,
      user: j['user'] is Map
          ? AppUser.fromJson(Map<String, dynamic>.from(j['user']))
          : null,
      skillTypeName: skillType?['name']?.toString(),
      skills: (j['skills'] is List ? j['skills'] as List : const [])
          .whereType<Map>()
          .map((e) {
            final s = e['skill'] is Map ? e['skill'] : e;
            return (s is Map ? s['name'] : '').toString();
          })
          .where((e) => e.isNotEmpty)
          .toList(),
      createdAt: j['createdAt']?.toString(),
    );
  }
}
