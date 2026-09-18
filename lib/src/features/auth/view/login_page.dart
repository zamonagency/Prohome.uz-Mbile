import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/settings_controller.dart';
import '../../../app/theme.dart';
import '../../../core/network/api_exception.dart';
import '../auth_controller.dart';
import '../auth_repository.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phone = TextEditingController(text: '+998 ');
  final _password = TextEditingController();
  bool _usePassword = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final phone = normalizePhone(_phone.text);
    if (!isValidPhone(phone)) {
      setState(() => _error = 'Telefon raqami noto‘g‘ri');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_usePassword) {
        await ref
            .read(authControllerProvider.notifier)
            .loginWithPassword(phone, _password.text);
        if (mounted) context.pop(true);
        return;
      }
      await ref
          .read(authControllerProvider.notifier)
          .sendOtp(phone, OtpPurpose.login);
      if (!mounted) return;
      final ok = await context.push<bool>(
          '${Routes.otp}?phone=${Uri.encodeComponent(phone)}&mode=login');
      if (ok == true && mounted) context.pop(true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            // Planshetda forma cheksiz cho'zilib ketmasin uchun.
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                const _Logo(),
                const SizedBox(height: 28),
                Text(s('auth.login'),
                    style: context.texts.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(s('home.search_hint'),
                    style: context.texts.bodyMedium
                        ?.copyWith(color: context.muted)),
                const SizedBox(height: 24),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                  ],
                  decoration: InputDecoration(
                    labelText: s('auth.phone'),
                    hintText: s('auth.phone_hint'),
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                ),
                if (_usePassword) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: s('auth.password'),
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style:
                          const TextStyle(color: AppColors.danger, fontSize: 13)),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _busy ? null : _continue,
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(_usePassword ? s('auth.login') : s('auth.continue')),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() {
                      _usePassword = !_usePassword;
                      _error = null;
                    }),
                    child: Text(_usePassword
                        ? s('auth.login_with_otp')
                        : s('auth.login_with_password')),
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: context.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(s('auth.no_account'),
                          style:
                              TextStyle(color: context.muted, fontSize: 12.5)),
                    ),
                    Expanded(child: Divider(color: context.border)),
                  ],
                ),
                const SizedBox(height: 16),

                // Avval oddiy matn-havola edi — "e'tibordan chetda"
                // qolib ketardi. Endi to'liq kenglikdagi, brend rangida
                // chizilgan (outlined) tugma — ko'zga aniq tashlanadi.
                OutlinedButton.icon(
                  onPressed: () => context.push(Routes.registerFlow),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 19),
                  label: Text(s('auth.register')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.4),
                  ),
                ),
                const SizedBox(height: 12),

                // "Usta bo'lish" — endi oddiy matn tugma emas, alohida
                // ajralib turadigan, ikonkali "promo" karta.
                _BecomeMasterCard(
                  label: s('intent.become_master'),
                  onTap: () => context.push(Routes.becomeMaster),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kirish sahifasidagi "Usta bo'lish" taklifi — oddiy matn havoladan
/// ko'ra ancha ko'zga tashlanadigan, brend-ikkilamchi rangdagi karta.
class _BecomeMasterCard extends StatelessWidget {
  const _BecomeMasterCard({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF9B5DE5);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.28)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: accent, fontWeight: FontWeight.w800, fontSize: 14.5)),
            ),
            const Icon(Icons.chevron_right_rounded, color: accent),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset('assets/images/logo.png', width: 36, height: 36),
        const SizedBox(width: 10),
        Text('ProHome',
            style: context.texts.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
      ],
    );
  }
}
