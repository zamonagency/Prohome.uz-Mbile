import 'location.dart';
import 'paginated.dart';

class AppUser {
  const AppUser({
    required this.id,
    this.phone,
    this.email,
    this.firstName,
    this.lastName,
    this.profileImg,
    this.role = 'USER',
    this.status = 'ACTIVE',
    this.locationId,
    this.location,
    this.masterId,
  });

  final int id;
  final String? phone;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? profileImg;
  final String role;
  final String status;
  final int? locationId;
  final AppLocation? location;
  final int? masterId;

  String get fullName {
    final n = [firstName, lastName].where((e) => (e ?? '').trim().isNotEmpty).join(' ');
    return n.isEmpty ? (phone ?? 'Foydalanuvchi') : n;
  }

  String get initials {
    final f = (firstName ?? '').trim();
    final l = (lastName ?? '').trim();
    if (f.isEmpty && l.isEmpty) return 'U';
    return '${f.isNotEmpty ? f[0] : ''}${l.isNotEmpty ? l[0] : ''}'.toUpperCase();
  }

  bool get isMaster => role == 'MASTER' || masterId != null;

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: asInt(j['id']) ?? 0,
        phone: j['phone']?.toString(),
        email: j['email']?.toString(),
        firstName: j['firstName']?.toString(),
        lastName: j['lastName']?.toString(),
        profileImg: j['profileImg']?.toString(),
        role: asString(j['role'], 'USER'),
        status: asString(j['status'], 'ACTIVE'),
        locationId: asInt(j['locationId']),
        location: j['location'] is Map
            ? AppLocation.fromJson(Map<String, dynamic>.from(j['location']))
            : null,
        masterId: j['master'] is Map ? asInt(j['master']['id']) : asInt(j['masterId']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'profileImg': profileImg,
        'role': role,
        'status': status,
        'locationId': locationId,
      };
}
