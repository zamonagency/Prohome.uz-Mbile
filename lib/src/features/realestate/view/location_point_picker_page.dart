import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme.dart';

/// E'lon qo'shishda xarita nuqtasini (latitude/longitude) tanlash —
/// backendda bu ikkalasi ham MAJBURIY. Xaritani surib, markazdagi
/// pin bilan aniq nuqtani belgilaydi; "Joylashuvim" tugmasi GPS orqali
/// tezda o'sha yerga o'tkazadi.
class LocationPointPickerPage extends StatefulWidget {
  const LocationPointPickerPage({super.key, this.initial});
  final LatLng? initial;

  static Future<LatLng?> show(BuildContext context, {LatLng? initial}) {
    return Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPointPickerPage(initial: initial),
      ),
    );
  }

  @override
  State<LocationPointPickerPage> createState() => _LocationPointPickerPageState();
}

class _LocationPointPickerPageState extends State<LocationPointPickerPage> {
  late final _map = MapController();
  late LatLng _center = widget.initial ?? const LatLng(41.311081, 69.240562); // Toshkent
  bool _locating = false;

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Joylashuvga ruxsat berilmadi')));
        }
        return;
      }
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Joylashuv xizmati o\'chirilgan')));
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final p = LatLng(pos.latitude, pos.longitude);
      setState(() => _center = p);
      _map.move(p, 16);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Joylashuvni olib bo\'lmadi')));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xaritadan joyni belgilang'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_center),
            child: const Text('Tanlash', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 14,
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture) _center = pos.center;
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'uz.prohome.b2c',
              ),
            ],
          ),
          // Markazda qotib turadigan pin — xarita surilganda shu nuqta tanlanadi.
          const IgnorePointer(
            child: Padding(
              padding: EdgeInsets.only(bottom: 36),
              child: Icon(Icons.location_on_rounded,
                  color: AppColors.danger, size: 44),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 24,
            child: FloatingActionButton(
              heroTag: 'use-my-location',
              onPressed: _locating ? null : _useMyLocation,
              child: _locating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
