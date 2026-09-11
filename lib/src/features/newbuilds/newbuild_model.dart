import '../../common/models/paginated.dart';
import '../../core/utils/media.dart';

/// Yangi bino loyihasi (B2C "advanced" API).
class B2CProject {
  const B2CProject({
    required this.id,
    this.name = '',
    this.address = '',
    this.images = const [],
  });
  final int id;
  final String name;
  final String address;
  final List<String> images;

  String get cover => images.isEmpty ? '' : mediaUrl(images.first);

  factory B2CProject.fromJson(Map<String, dynamic> j) => B2CProject(
        id: asInt(j['id']) ?? 0,
        name: asString(j['name']),
        address: asString(j['address']),
        images: asStringList(j['images']),
      );
}

/// Loyihadagi xonadon.
class B2CRoom {
  const B2CRoom({
    required this.id,
    this.roomNumber = 0,
    this.floorNumber = 0,
    this.price = 0,
    this.size = 0,
    this.status = 'EMPTY',
    this.type = 'READY',
    this.projectName = '',
    this.projectAddress = '',
    this.block,
    this.images = const [],
    this.description,
    this.phoneNumber,
  });

  final int id;
  final int roomNumber;
  final int floorNumber;
  final num price;
  final num size;
  final String status;
  final String type;
  final String projectName;
  final String projectAddress;
  final String? block;
  final List<String> images;
  final String? description;
  final String? phoneNumber;

  String get cover => images.isEmpty ? '' : mediaUrl(images.first);
  List<String> get gallery => images.map(mediaUrl).toList();
  bool get isAvailable => status == 'EMPTY';

  factory B2CRoom.fromJson(Map<String, dynamic> j) {
    final imgs = j['images'] is List
        ? asStringList(j['images'])
        : asStringList(j['img']);
    return B2CRoom(
      id: asInt(j['id']) ?? 0,
      roomNumber: asInt(j['roomNumber']) ?? 0,
      floorNumber: asInt(j['floorNumber']) ?? 0,
      price: asDouble(j['price']) ?? 0,
      size: asDouble(j['size']) ?? 0,
      status: asString(j['status'], 'EMPTY'),
      type: asString(j['type'], 'READY'),
      projectName: asString(j['projectName']),
      projectAddress: asString(j['projectAddress']),
      block: (j['block'] ?? j['dom'])?.toString(),
      images: imgs,
      description: (j['description'] ?? j['desc'])?.toString(),
      phoneNumber: j['phoneNumber']?.toString(),
    );
  }
}
