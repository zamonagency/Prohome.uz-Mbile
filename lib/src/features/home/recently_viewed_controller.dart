import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/settings_controller.dart';
import '../masters/master_model.dart';
import '../realestate/real_estate_model.dart';

enum RecentKind { estate, master }

/// Foydalanuvchi oxirgi ochib ko'rgan ko'chmas mulk / usta — faqat qurilmada
/// saqlanadi (server yozuvi shart emas).
class RecentEntry {
  const RecentEntry({
    required this.kind,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
  });

  final RecentKind kind;
  final int id;
  final String title;
  final String subtitle;
  final String image;

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'image': image,
      };

  factory RecentEntry.fromJson(Map<String, dynamic> j) => RecentEntry(
        kind: j['kind'] == 'master' ? RecentKind.master : RecentKind.estate,
        id: (j['id'] as num?)?.toInt() ?? 0,
        title: (j['title'] ?? '').toString(),
        subtitle: (j['subtitle'] ?? '').toString(),
        image: (j['image'] ?? '').toString(),
      );

  String get _dedupeKey => '${kind.name}:$id';
}

class RecentlyViewedController extends StateNotifier<List<RecentEntry>> {
  RecentlyViewedController(this._prefs) : super(const []) {
    _load();
  }

  final SharedPreferences _prefs;
  static const _kKey = 'ph_recently_viewed';
  static const _max = 20;

  void _load() {
    final raw = _prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = (jsonDecode(raw) as List)
          .whereType<Map>()
          .map((e) => RecentEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      state = list;
    } catch (_) {
      // eskirgan/buzilgan format — e'tiborsiz qoldiramiz
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(
        _kKey, jsonEncode(state.map((e) => e.toJson()).toList()));
  }

  Future<void> _track(RecentEntry entry) async {
    final next = [
      entry,
      ...state.where((e) => e._dedupeKey != entry._dedupeKey),
    ].take(_max).toList();
    state = next;
    await _persist();
  }

  Future<void> trackEstate(RealEstate item) => _track(RecentEntry(
        kind: RecentKind.estate,
        id: item.id,
        title: item.title,
        subtitle: item.locationName,
        image: item.cover,
      ));

  Future<void> trackMaster(Master item) => _track(RecentEntry(
        kind: RecentKind.master,
        id: item.id,
        title: item.name,
        subtitle: item.primarySkill,
        image: item.avatar,
      ));
}

final recentlyViewedProvider =
    StateNotifierProvider<RecentlyViewedController, List<RecentEntry>>(
        (ref) => RecentlyViewedController(ref.watch(sharedPrefsProvider)));
