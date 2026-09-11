import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/settings_controller.dart';
import '../../app/theme.dart';
import '../data/locations_repository.dart';
import '../models/location.dart';

/// Hududlar ro'yxati tekis (30+ ta) dropdown'da hammasi bir xil ko'rinib,
/// kerakligini topish qiyin bo'lgani uchun — qidiruvli, kattaroq, bosish
/// oson bo'lgan pastdan chiqadigan varaq bilan almashtirildi.
Future<AppLocation?> showLocationPicker(BuildContext context, {int? currentId}) {
  return showModalBottomSheet<AppLocation>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _LocationPickerSheet(currentId: currentId),
  );
}

class _LocationPickerSheet extends ConsumerStatefulWidget {
  const _LocationPickerSheet({this.currentId});
  final int? currentId;

  @override
  ConsumerState<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends ConsumerState<_LocationPickerSheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final locations = ref.watch(allLocationsProvider);
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(s('filter.region'),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 17)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _search,
                autofocus: false,
                onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: s('common.search'),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: locations.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(child: Text(s('common.error'))),
                data: (list) {
                  final filtered = _query.isEmpty
                      ? list
                      : list
                          .where((l) => l.name.toLowerCase().contains(_query))
                          .toList();
                  if (filtered.isEmpty) {
                    return Center(child: Text(s('common.empty')));
                  }
                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: context.border),
                    itemBuilder: (_, i) {
                      final l = filtered[i];
                      final selected = l.id == widget.currentId;
                      return ListTile(
                        title: Text(l.name,
                            style: TextStyle(
                                fontWeight:
                                    selected ? FontWeight.w800 : FontWeight.w500)),
                        trailing: selected
                            ? const Icon(Icons.check_circle_rounded,
                                color: AppColors.primary)
                            : null,
                        onTap: () => Navigator.of(context).pop(l),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// EditProfilePage/AddListingPage kabi joylarda ishlatiladigan, tanlangan
/// hududni ko'rsatuvchi va bosilganda pikerni ochadigan tayyor maydon.
class LocationField extends ConsumerWidget {
  const LocationField({
    super.key,
    required this.locationId,
    required this.onChanged,
    this.required = false,
  });
  final int? locationId;
  final ValueChanged<AppLocation> onChanged;
  final bool required;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final locations = ref.watch(allLocationsProvider);
    final name = locations.maybeWhen(
      data: (list) {
        for (final l in list) {
          if (l.id == locationId) return l.name;
        }
        return null;
      },
      orElse: () => null,
    );
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final picked = await showLocationPicker(context, currentId: locationId);
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: required ? '${s('filter.region')} *' : s('filter.region'),
          suffixIcon: const Icon(Icons.expand_more_rounded),
        ),
        child: Text(
          name ?? s('map.pick_region'),
          style: TextStyle(color: name == null ? context.muted : null),
        ),
      ),
    );
  }
}
