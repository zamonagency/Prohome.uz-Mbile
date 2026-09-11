import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/settings_controller.dart';
import '../../app/theme.dart';
import '../../features/favorites/favorites_controller.dart';

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({
    super.key,
    required this.kind,
    required this.id,
    this.compact = true,
  });

  final FavKind kind;
  final int id;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(favoritesProvider);
    final isFav = ref.read(favoritesProvider.notifier).contains(kind, id);
    final s = ref.read(stringsProvider);

    final icon = AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
      child: Icon(
        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        key: ValueKey(isFav),
        color: isFav ? AppColors.danger : (compact ? Colors.white : context.muted),
        size: compact ? 20 : 24,
      ),
    );

    Future<void> toggle() async {
      final added = await ref.read(favoritesProvider.notifier).toggle(kind, id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(added ? s('fav.added') : s('fav.removed')),
          duration: const Duration(milliseconds: 1200),
        ));
    }

    if (compact) {
      return Material(
        color: Colors.black.withValues(alpha: 0.32),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: toggle,
          child: Padding(padding: const EdgeInsets.all(7), child: icon),
        ),
      );
    }
    return IconButton(onPressed: toggle, icon: icon);
  }
}
