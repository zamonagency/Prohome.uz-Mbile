import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../realestate/real_estate_model.dart';
import '../realestate/real_estate_repository.dart';

/// Birinchi marta ochilganda joylashuvga ruxsat so'raydi (agar hali
/// so'ralmagan/rad etilmagan bo'lsa) — ruxsat berilsa, atrofdagi
/// e'lonlarni ko'rsatish uchun ishlatiladi. Har qanday xatoda/rad
/// etilganda ham ilova oddiy ishlashda davom etadi (`null` qaytadi).
final currentPositionProvider = FutureProvider<Position?>((ref) async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      return null;
    }
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 8),
      ),
    );
  } catch (_) {
    return null;
  }
});

/// Joylashuv ma'lum bo'lsa — shu atrofdagi (taxminan 15km, `bbox`) va
/// ENG YAQINIDAN boshlab saralangan (`near` — lat/lng, backendda
/// Haversine masofa bo'yicha) e'lonlar. Ikkalasi birga: uzoqroqqa
/// chegara qo'yiladi, ichida esa haqiqiy masofa bo'yicha tartiblanadi.
final nearbyEstatesProvider = FutureProvider<List<RealEstate>>((ref) async {
  final pos = await ref.watch(currentPositionProvider.future);
  if (pos == null) return const [];
  try {
    final res = await ref.watch(realEstateRepositoryProvider).list(
          limit: 10,
          filter: RealEstateFilter(
            bbox: GeoBounds.aroundKm(pos.latitude, pos.longitude, 15),
            near: GeoPoint(pos.latitude, pos.longitude),
          ),
        );
    return res.items;
  } catch (_) {
    return const [];
  }
});
