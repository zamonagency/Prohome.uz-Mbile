import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/settings_controller.dart';
import '../../app/theme.dart';
import '../realestate/real_estate_repository.dart';
import 'regions_data.dart';

class RegionDetailPage extends ConsumerStatefulWidget {
  const RegionDetailPage({super.key, required this.slug});
  final String slug;

  @override
  ConsumerState<RegionDetailPage> createState() => _RegionDetailPageState();
}

class _RegionDetailPageState extends ConsumerState<RegionDetailPage> {
  final _map = MapController();
  String? _selectedDistrict;

  UzRegion get region => regionBySlug(widget.slug);

  /// Xaritaning HOZIRGI ko'rinib turgan hududi (viewport) — surib/zoom
  /// qilib qo'ygan joyingiz bo'yicha qidiradi, statik viloyat nomi bo'yicha
  /// emas. Aynan shu GET /real-estates va /jobs'dagi swLat/swLng/neLat/neLng
  /// bilan ishlaydi (productionda tasdiqlangan).
  GeoBounds get _currentBounds {
    final b = _map.camera.visibleBounds;
    return GeoBounds(
      swLat: b.southWest.latitude,
      swLng: b.southWest.longitude,
      neLat: b.northEast.latitude,
      neLng: b.northEast.longitude,
    );
  }

  void _searchEstatesHere() {
    context.push(Routes.estates, extra: RealEstateFilter(bbox: _currentBounds));
  }

  void _searchJobsHere() {
    context.push(Routes.jobs, extra: _currentBounds);
  }

  void _focusDistrict(String name) {
    setState(() => _selectedDistrict = name);
    // Tuman nomi bo'yicha aniq koordinata bazamizda yo'q — shuning uchun
    // markazga biroz yaqinlashtirib, foydalanuvchi o'zi aniqlashtirib
    // sura oladi, so'ng "Shu hududda qidirish" HAQIQIY xarita chegarasini oladi.
    _map.move(region.center, 11);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final r = region;

    return Scaffold(
      appBar: AppBar(title: Text(r.name)),
      body: Column(
        children: [
          SizedBox(
            height: 280,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _map,
                  options: MapOptions(
                    initialCenter: r.center,
                    initialZoom: 9,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom |
                          InteractiveFlag.drag |
                          InteractiveFlag.doubleTapZoom,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'uz.prohome.b2c',
                    ),
                    MarkerLayer(markers: [
                      Marker(
                        point: r.center,
                        width: 44,
                        height: 44,
                        child: const Icon(Icons.location_on_rounded,
                            color: AppColors.danger, size: 44),
                      ),
                    ]),
                  ],
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  // MUHIM: "Shu hududda qidirish" matni (ayniqsa ru/en'da
                  // yanada uzunroq) tor `Expanded(flex:1)` ichiga sig'may,
                  // 2-3 qatorga bo'linib, tugmani cho'zib yuborardi. Endi
                  // uzunroq matnli tugma ko'proq joy oladi (flex 3:2) va
                  // matn hech qachon 2-qatorga tushmaydi (`maxLines: 1` +
                  // kerak bo'lsa "...") — eng kichik telefondan
                  // planshetgacha bir qatorda, chiroyli sig'adi.
                  // (Avvalgi `CrossAxisAlignment.stretch` + `FittedBox`
                  // kombinatsiyasi ba'zi hududlarda tugmalarni
                  // "ko'rinmas" balandlikka majburlab qo'yayotgan edi —
                  // shu sabab butunlay olib tashlandi.)
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _MapActionButton(
                          icon: Icons.home_work_outlined,
                          label: s('map.search_here'),
                          onTap: _searchEstatesHere,
                          filled: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: _MapActionButton(
                          icon: Icons.work_outline_rounded,
                          label: s('cat.jobs'),
                          onTap: _searchJobsHere,
                          filled: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(s('map.pick_district'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13.5)),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: r.districts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final d = r.districts[i];
                final sel = d == _selectedDistrict;
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _focusDistrict(d),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.primary.withValues(alpha: 0.10)
                          : context.colors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: sel ? AppColors.primary : context.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.place_outlined,
                            size: 18,
                            color: sel ? AppColors.primary : context.muted),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(d,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: sel ? AppColors.primary : null)),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            size: 20, color: context.muted),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Xarita ustidagi harakat tugmalari — matn hech qachon 2-qatorga
/// tushmaydi: `Flexible` + `maxLines: 1` + kerak bo'lsagina "..." bilan
/// kesiladi (`FittedBox` asosidagi avvalgi variant ba'zi hollarda
/// tugmani butunlay noto'g'ri — hatto ko'rinmas — o'lchamga majbur
/// qilib qo'yayotgan edi, shu sabab soddaroq, ishonchli usulga
/// almashtirildi).
class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.filled,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : context.colors.onSurface;
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 17, color: fg),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style:
                TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
        ),
      ],
    );
    return SizedBox(
      height: 48,
      child: filled
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8)),
              child: content,
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: content,
            ),
    );
  }
}
