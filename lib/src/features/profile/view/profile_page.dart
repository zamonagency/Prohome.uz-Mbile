import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/settings_controller.dart';
import '../../../app/theme.dart';
import '../../../core/utils/media.dart';
import '../../../l10n/strings.dart';
import '../../auth/auth_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final user = ref.watch(currentUserProvider);
    final authed = ref.watch(isAuthenticatedProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s('nav.profile'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: context.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  backgroundImage: (user?.profileImg ?? '').isNotEmpty
                      ? NetworkImage(mediaUrl(user!.profileImg))
                      : null,
                  child: (user?.profileImg ?? '').isEmpty
                      ? Text(user?.initials ?? '👤',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary))
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(authed ? (user?.fullName ?? '') : s('auth.guest'),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(user?.phone ?? s('auth.need_login'),
                          style: TextStyle(color: context.muted, fontSize: 13)),
                    ],
                  ),
                ),
                if (authed)
                  IconButton(
                    onPressed: () => context.push(Routes.editProfile),
                    icon: const Icon(Icons.edit_outlined),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (!authed)
            ElevatedButton.icon(
              onPressed: () => context.push(Routes.login),
              icon: const Icon(Icons.login_rounded),
              label: Text(s('auth.login')),
            ),

          if (authed) ...[
            _tile(context, Icons.list_alt_rounded, s('profile.my_listings'),
                () => context.push('${Routes.estates}?mine=1')),
            _tile(context, Icons.notifications_none_rounded,
                s('profile.notifications'),
                () => context.push(Routes.notifications)),
            _tile(context, Icons.add_home_work_outlined, s('estate.add'),
                () => context.push(Routes.addListing)),
          ],

          const SizedBox(height: 12),
          _sectionLabel(context, s('profile.language')),
          _LangSelector(current: settings.lang),

          const SizedBox(height: 12),
          _sectionLabel(context, s('profile.theme')),
          _ThemeSelector(current: settings.themeMode, s: s),

          const SizedBox(height: 12),
          _sectionLabel(context, s('profile.currency')),
          _CurrencySelector(current: settings.currency),

          const SizedBox(height: 12),
          _tile(context, Icons.info_outline_rounded, s('profile.about'),
              () => showAboutDialog(
                    context: context,
                    applicationName: 'ProHome B2C',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© ProHome',
                  )),

          if (authed) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
              label: Text(s('auth.logout'),
                  style: const TextStyle(color: AppColors.danger)),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String t) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: Text(t,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: context.muted)),
      );

  Widget _tile(
          BuildContext context, IconData icon, String label, VoidCallback onTap) =>
      Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(label),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      );
}

class _LangSelector extends ConsumerWidget {
  const _LangSelector({required this.current});
  final AppLang current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      children: AppLang.values
          .map((l) => ChoiceChip(
                label: Text(l.label),
                selected: current == l,
                onSelected: (_) =>
                    ref.read(settingsProvider.notifier).setLang(l),
                selectedColor: AppColors.primary,
                showCheckmark: false,
                labelStyle: TextStyle(
                    color: current == l ? Colors.white : null,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5),
              ))
          .toList(),
    );
  }
}

class _CurrencySelector extends ConsumerWidget {
  const _CurrencySelector({required this.current});
  final AppCurrency current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = {
      AppCurrency.uzs: "so'm (UZS)",
      AppCurrency.usd: "dollar (USD)",
    };
    return Wrap(
      spacing: 8,
      children: items.entries
          .map((e) => ChoiceChip(
                label: Text(e.value),
                selected: current == e.key,
                onSelected: (_) =>
                    ref.read(settingsProvider.notifier).setCurrency(e.key),
                selectedColor: AppColors.primary,
                showCheckmark: false,
                labelStyle: TextStyle(
                    color: current == e.key ? Colors.white : null,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5),
              ))
          .toList(),
    );
  }
}

class _ThemeSelector extends ConsumerWidget {
  const _ThemeSelector({required this.current, required this.s});
  final ThemeMode current;
  final AppStrings s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = {
      ThemeMode.system: s('profile.theme_system'),
      ThemeMode.light: s('profile.theme_light'),
      ThemeMode.dark: s('profile.theme_dark'),
    };
    return Wrap(
      spacing: 8,
      children: items.entries
          .map((e) => ChoiceChip(
                label: Text(e.value),
                selected: current == e.key,
                onSelected: (_) =>
                    ref.read(settingsProvider.notifier).setThemeMode(e.key),
                selectedColor: AppColors.primary,
                showCheckmark: false,
                labelStyle: TextStyle(
                    color: current == e.key ? Colors.white : null,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5),
              ))
          .toList(),
    );
  }
}
