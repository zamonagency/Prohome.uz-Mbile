import '../config/env.dart';

/// Backend turli ko'rinishdagi media yo'llarini qaytaradi:
///   - to'liq URL ("http...")               → o'zgarishsiz (localhost bo'lsa almashadi)
///   - "/uploads/x.jpg"                      → mediaBase + path
///   - "images/123.jpg" / "123.jpg"          → mediaBase + '/' + path
String mediaUrl(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  var s = raw.trim();
  if (s.startsWith('http://') || s.startsWith('https://')) {
    return s.replaceFirst(
      RegExp(r'^https?://localhost(:\d+)?'),
      Env.mediaBaseUrl,
    );
  }
  if (s.startsWith('/')) return '${Env.mediaBaseUrl}$s';
  return '${Env.mediaBaseUrl}/$s';
}

/// Chat media `GET /image/{fayl}` orqali olinadi.
String chatMediaUrl(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  final s = raw.trim();
  if (s.startsWith('blob:') || s.startsWith('data:')) return s;
  if (s.startsWith('http')) {
    return s.replaceFirst(
        RegExp(r'^https?://localhost(:\d+)?'), Env.mediaBaseUrl);
  }
  final file = s.split(RegExp(r'[\\/]')).last;
  return '${Env.mediaBaseUrl}/image/$file';
}

String firstImage(List? images, {String fallback = ''}) {
  if (images == null || images.isEmpty) return fallback;
  return mediaUrl(images.first?.toString());
}
