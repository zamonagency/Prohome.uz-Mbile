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

  /// Yangi (hali ro'yxatdan o'tmagan) foydalanuvchi uchun — alohida,
  /// aniq tugma: SMS-kodni "register" maqsadida yuborib, OTP → RegisterPage
  /// (ism/familiya) oqimiga o'tkazadi.
  Future<void> _register() async {
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
      await ref
          .read(authControllerProvider.notifier)
          .sendOtp(phone, OtpPurpose.register);
      if (!mounted) return;
      final ok = await context.push<bool>(
          '${Routes.otp}?phone=${Uri.encodeComponent(phone)}&mode=register');
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
                  style: const TextStyle(color: AppColors.danger, fontSize: 13)),
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
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() {
                _usePassword = !_usePassword;
                _error = null;
              }),
              child: Text(_usePassword
                  ? s('auth.login_with_otp')
                  : s('auth.login_with_password')),
            ),
            const Divider(height: 32),
            // Row emas, Wrap — tor ekranda/katta shrift o'lchamida matn
            // sig'may qolib, tugma bosilmay qolishining oldini oladi.
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(s('auth.no_account'),
                    style: TextStyle(color: context.muted, fontSize: 13.5)),
                TextButton(
                  onPressed: _busy ? null : _register,
                  child: Text(s('auth.register')),
                ),
              ],
            ),
            Center(
              child: TextButton.icon(
                onPressed: () => context.push(Routes.becomeMaster),
                icon: const Icon(Icons.workspace_premium_outlined, size: 18),
                label: Text(s('intent.become_master')),
              ),
            ),
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
