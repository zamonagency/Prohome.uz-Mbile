import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/settings_controller.dart';
import '../../core/providers.dart';

enum FavKind { estate, master, job, apartment }

extension FavKindX on FavKind {
  String get key => name;
  String get likePath => switch (this) {
        FavKind.estate => '/real-estates',
        FavKind.master => '/masters',
        FavKind.job => '/jobs',
        FavKind.apartment => '/apartments',
      };
}

/// Saqlanganlar lokal (offlayn ham ishlaydi). Login bo'lsa server "like" ham yuboriladi.
class FavoritesController extends StateNotifier<Set<String>> {
  FavoritesController(this._ref) : super({}) {
    _load();
  }

  final Ref _ref;
  static const _kKey = 'ph_favorites';

  SharedPreferences get _prefs => _ref.read(sharedPrefsProvider);

  void _load() {
    state = (_prefs.getStringList(_kKey) ?? const []).toSet();
  }

  String _id(FavKind kind, int id) => '${kind.key}:$id';

  bool contains(FavKind kind, int id) => state.contains(_id(kind, id));

  Future<bool> toggle(FavKind kind, int id) async {
    final k = _id(kind, id);
    final next = {...state};
    final added = !next.contains(k);
    if (added) {
      next.add(k);
    } else {
      next.remove(k);
    }
    state = next;
    await _prefs.setStringList(_kKey, next.toList());

    // Serverga "like" (best-effort, xatoni yutamiz).
    try {
      final api = _ref.read(apiClientProvider);
      await api.post('${kind.likePath}/$id/like');
    } catch (_) {}

    return added;
  }

  List<int> idsOf(FavKind kind) => state
      .where((e) => e.startsWith('${kind.key}:'))
      .map((e) => int.tryParse(e.split(':').last) ?? 0)
      .where((e) => e != 0)
      .toList();
}

final favoritesProvider =
    StateNotifierProvider<FavoritesController, Set<String>>(
        (ref) => FavoritesController(ref));
