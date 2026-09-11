/// Backend javoblari 3 xil ko'rinishda keladi:
///   [ ... ]                             (oddiy massiv)
///   { data: [...], meta: {...} }
///   { data: [...] }
class Paginated<T> {
  const Paginated({
    required this.items,
    this.page = 1,
    this.limit = 20,
    this.total = 0,
    this.totalPages = 1,
  });

  final List<T> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasMore => page < totalPages;

  static Paginated<T> parse<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw is List) {
      final list = raw
          .whereType<Map>()
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Paginated<T>(
        items: list,
        page: 1,
        limit: list.length,
        total: list.length,
        totalPages: 1,
      );
    }
    if (raw is Map) {
      final data = raw['data'];
      final meta = raw['meta'] is Map ? Map<String, dynamic>.from(raw['meta']) : null;
      final list = (data is List ? data : const [])
          .whereType<Map>()
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Paginated<T>(
        items: list,
        page: _int(meta?['page'], 1),
        limit: _int(meta?['limit'], list.length),
        total: _int(meta?['total'], list.length),
        totalPages: _int(meta?['totalPages'], 1),
      );
    }
    return Paginated<T>(items: const []);
  }

  static int _int(dynamic v, int fallback) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('${v ?? ''}') ?? fallback;
  }
}

/// `{ data: {...} }` yoki to'g'ridan-to'g'ri obyekt qaytaruvchi detail endpointlar.
Map<String, dynamic> unwrap(dynamic raw) {
  if (raw is Map && raw['data'] is Map) {
    return Map<String, dynamic>.from(raw['data']);
  }
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return <String, dynamic>{};
}

int? asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

double? asDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

String asString(dynamic v, [String fallback = '']) => v?.toString() ?? fallback;

bool asBool(dynamic v) => v == true || v == 'true' || v == 1;

List<String> asStringList(dynamic v) {
  if (v is List) return v.map((e) => e.toString()).toList();
  return const [];
}
