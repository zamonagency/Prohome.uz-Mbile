import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme.dart';
import '../../core/utils/media.dart';

/// Barcha rasm ko'rsatilishi shu yerdan o'tadi:
/// - `raw` bo'sh bo'lsa placeholder;
/// - yuklanayotganda shimmer;
/// - xato bo'lsa "surat yo'q" holati.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.raw,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.radius = 0,
  });

  final String? raw;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = mediaUrl(raw);
    final child = url.isEmpty
        ? _Placeholder(width: width, height: height)
        : _RetryableImage(url: url, fit: fit, width: width, height: height);
    if (radius <= 0) return child;
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: child);
  }
}

/// Yuklashda xato bo'lsa, bosib qayta urinib ko'rish imkonini beradi —
/// sekin/beqaror tarmoqda rasm butunlay "buzilgan" ko'rinib qolmasin uchun.
class _RetryableImage extends StatefulWidget {
  const _RetryableImage({
    required this.url,
    required this.fit,
    this.width,
    this.height,
  });
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  State<_RetryableImage> createState() => _RetryableImageState();
}

class _RetryableImageState extends State<_RetryableImage> {
  int _attempt = 0;

  /// `double.infinity` (yoki NaN) kelsa `null` qaytaradi — aks holda
  /// `.round()` "Unsupported operation: Infinity" bilan quladi.
  int? _finitePx(double? v, double dpr) {
    if (v == null || !v.isFinite) return null;
    return (v * dpr).round();
  }

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return CachedNetworkImage(
      key: ValueKey('${widget.url}#$_attempt'),
      imageUrl: widget.url,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      // Ehtiyotkorlik bilan: ekranda kerakligidan kattaroq rasmni dekodlamaslik
      // uchun — tarmoq va render tezroq bo'ladi.
      memCacheWidth: _finitePx(widget.width, dpr),
      memCacheHeight: _finitePx(widget.height, dpr),
      fadeInDuration: const Duration(milliseconds: 180),
      placeholder: (_, __) => _Shimmer(width: widget.width, height: widget.height),
      errorWidget: (_, __, ___) => GestureDetector(
        onTap: () async {
          await CachedNetworkImage.evictFromCache(widget.url);
          if (mounted) setState(() => _attempt++);
        },
        child: _Placeholder(width: widget.width, height: widget.height, broken: true),
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  const _Shimmer({this.width, this.height});
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    // MUHIM: highlightColor baseColor'ga juda yaqin (yoki xira) bo'lsa,
    // "yaltillash" deyarli ko'rinmay qoladi va butun yuklanish davomida
    // rasm o'rnida oddiy qora/quyuq to'rtburchak turgandek tuyuladi —
    // aynan "rasmlar kelmayapti" shikoyatining asosiy sababi shu edi.
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = dark ? const Color(0xFF232A3A) : const Color(0xFFEDEFF3);
    final highlight = dark ? const Color(0xFF3D4A5F) : Colors.white;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: const Duration(milliseconds: 1200),
      child: Container(width: width, height: height, color: base),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.width, this.height, this.broken = false});
  final double? width;
  final double? height;
  final bool broken;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurfaceAlt
          : const Color(0xFFF0F2F5),
      alignment: Alignment.center,
      child: broken
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded, color: context.muted, size: 28),
                const SizedBox(height: 2),
                Text('Qayta urinish',
                    style: TextStyle(color: context.muted, fontSize: 10.5)),
              ],
            )
          : Icon(Icons.image_outlined, color: context.muted, size: 32),
    );
  }
}
