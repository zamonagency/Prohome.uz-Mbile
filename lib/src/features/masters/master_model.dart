import '../../common/models/paginated.dart';
import '../../common/models/user.dart';
import '../../core/utils/media.dart';

class MasterSkill {
  const MasterSkill({required this.id, required this.name});
  final int id;
  final String name;

  factory MasterSkill.fromEntry(Map<String, dynamic> j) {
    final skill = j['skill'] is Map ? Map<String, dynamic>.from(j['skill']) : j;
    return MasterSkill(
      id: asInt(skill['id']) ?? 0,
      name: asString(skill['name']),
    );
  }
}

class MasterRating {
  const MasterRating({
    required this.id,
    required this.rating,
    this.comment,
    this.authorName = '',
    this.createdAt,
  });
  final int id;
  final int rating;
  final String? comment;
  final String authorName;
  final String? createdAt;

  factory MasterRating.fromJson(Map<String, dynamic> j) {
    final u = j['user'] is Map ? Map<String, dynamic>.from(j['user']) : null;
    return MasterRating(
      id: asInt(j['id']) ?? 0,
      rating: asInt(j['rating']) ?? 0,
      comment: j['comment']?.toString(),
      authorName: u == null
          ? 'Foydalanuvchi'
          : [u['firstName'], u['lastName']]
              .where((e) => (e ?? '').toString().trim().isNotEmpty)
              .join(' '),
      createdAt: j['createdAt']?.toString(),
    );
  }
}

class Master {
  const Master({
    required this.id,
    this.profileImg,
    this.experience = 0,
    this.bio,
    this.salary,
    this.latitude,
    this.longitude,
    this.workImgs = const [],
    this.isFree = false,
    this.likeCount = 0,
    this.viewCount = 0,
    this.user,
    this.skills = const [],
    this.ratings = const [],
  });

  final int id;
  final String? profileImg;
  final int experience;
  final String? bio;
  final num? salary;
  final double? latitude;
  final double? longitude;
  final List<String> workImgs;
  final bool isFree;
  final int likeCount;
  final int viewCount;
  final AppUser? user;
  final List<MasterSkill> skills;
  final List<MasterRating> ratings;

  String get name => user?.fullName ?? 'Usta';
  String get avatar => mediaUrl(profileImg ?? user?.profileImg);
  List<String> get portfolio => workImgs.map(mediaUrl).toList();
  String get phone => user?.phone ?? '';
  String get primarySkill => skills.isNotEmpty ? skills.first.name : 'Usta';

  double get avgRating {
    if (ratings.isEmpty) return 0;
    final sum = ratings.fold<int>(0, (a, b) => a + b.rating);
    return sum / ratings.length;
  }

  factory Master.fromJson(Map<String, dynamic> j) => Master(
        id: asInt(j['id']) ?? 0,
        profileImg: j['profileImg']?.toString(),
        experience: asInt(j['experience']) ?? 0,
        bio: j['bio']?.toString(),
        salary: asDouble(j['salary']),
        latitude: asDouble(j['latitude']),
        longitude: asDouble(j['longitude']),
        workImgs: asStringList(j['workImgs']),
        isFree: asBool(j['isFree']),
        likeCount: asInt(j['likeCount']) ?? 0,
        viewCount: asInt(j['viewCount']) ?? 0,
        user: j['user'] is Map
            ? AppUser.fromJson(Map<String, dynamic>.from(j['user']))
            : null,
        skills: (j['skills'] is List ? j['skills'] as List : const [])
            .whereType<Map>()
            .map((e) => MasterSkill.fromEntry(Map<String, dynamic>.from(e)))
            .toList(),
        ratings: (j['ratings'] is List ? j['ratings'] as List : const [])
            .whereType<Map>()
            .map((e) => MasterRating.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class SkillType {
  const SkillType({required this.id, required this.name});
  final int id;
  final String name;
  factory SkillType.fromJson(Map<String, dynamic> j) => SkillType(
        id: asInt(j['id']) ?? 0,
        name: asString(j['name']),
      );
}

/// `SkillType` (kasb turi, masalan "Umumiy ta'mir") ichidagi aniq
/// ko'nikma (masalan "Ko'chirish"). Usta ro'yxatdan o'tishda kamida
/// bitta `Skill` tanlashi shart (`GET /skills?typeId=`).
class Skill {
  const Skill({required this.id, required this.name, required this.typeId});
  final int id;
  final String name;
  final int typeId;
  factory Skill.fromJson(Map<String, dynamic> j) => Skill(
        id: asInt(j['id']) ?? 0,
        name: asString(j['name']),
        typeId: asInt(j['typeId']) ?? 0,
      );
}
