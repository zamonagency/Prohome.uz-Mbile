import 'paginated.dart';

class AppLocation {
  const AppLocation({
    required this.id,
    required this.name,
    this.type,
    this.parentId,
  });

  final int id;
  final String name;
  final String? type;
  final int? parentId;

  factory AppLocation.fromJson(Map<String, dynamic> j) => AppLocation(
        id: asInt(j['id']) ?? 0,
        name: asString(j['name']),
        type: j['type']?.toString(),
        parentId: asInt(j['parentId']),
      );

  // `id` bo'yicha tenglik — DropdownButtonFormField kabi joylarda turli
  // so'rovlardan kelgan (bir xil id'li, lekin boshqa instance) obyektlarni
  // ham "tanlangan" deb to'g'ri aniqlash uchun.
  @override
  bool operator ==(Object other) => other is AppLocation && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
