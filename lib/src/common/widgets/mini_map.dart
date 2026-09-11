import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';

/// OpenStreetMap asosidagi kichik xarita (web `react-leaflet` bilan mos).
class MiniMap extends StatelessWidget {
  const MiniMap({
    super.key,
    required this.lat,
    required this.lng,
    this.height = 180,
    this.label,
  });

  final double lat;
  final double lng;
  final double height;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final point = LatLng(lat, lng);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: point,
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
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
                    point: point,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on_rounded,
                        color: AppColors.danger, size: 40),
                  ),
                ]),
              ],
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: FloatingActionButton.small(
                heroTag: 'open-map-$lat$lng',
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                onPressed: () => _openExternal(point),
                child: const Icon(Icons.open_in_new_rounded, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openExternal(LatLng p) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${p.latitude},${p.longitude}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
