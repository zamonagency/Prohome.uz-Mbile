import 'dart:async';

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

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({super.key, required this.phone, this.mode = 'login'});
  final String phone;
  final String mode; // 'login' | 'register'

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final _ctrl = TextEditingController();
  bool _busy = false;
  String? _error;
  int _secondsLeft = 60;
  Timer? _timer;

  OtpPurpose get _purpose =>
      widget.mode == 'register' ? OtpPurpose.register : OtpPurpose.login;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _resend() async {
    try {
      await ref
          .read(authControllerProvider.notifier)
          .sendOtp(widget.phone, _purpose);
      _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.read(stringsProvider)('auth.otp_sent'))),
        );
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _verify() async {
    final otp = _ctrl.text.trim();
    if (otp.length < 4) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (widget.mode == 'register') {
        await ref
            .read(authRepositoryProvider)
            .verifyOtp(widget.phone, otp, OtpPurpose.register);
        if (!mounted) return;
        final ok = await context.push<bool>(
            '${Routes.register}?phone=${Uri.encodeComponent(widget.phone)}&otp=$otp');
        if (ok == true && mounted) context.pop(true);
      } else {
        await ref
            .read(authControllerProvider.notifier)
            .loginWithOtp(widget.phone, otp);
        if (mounted) context.pop(true);
      }
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
      appBar: AppBar(title: Text(s('auth.otp_title'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          children: [
            Text('${prettyPhone(widget.phone)} ${s('auth.otp_sent')}',
                style: context.texts.bodyMedium
                    ?.copyWith(color: context.muted)),
            const SizedBox(height: 24),
            TextField(
              controller: _ctrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 10),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) {
                if (v.length == 6) _verify();
              },
              decoration: const InputDecoration(
                counterText: '',
                hintText: '••••••',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _busy ? null : _verify,
              child: _busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(s('auth.continue')),
            ),
            const SizedBox(height: 12),
            Center(
              child: _secondsLeft > 0
                  ? Text('${s('auth.otp_resend')} (00:${_secondsLeft.toString().padLeft(2, '0')})',
                      style: TextStyle(color: context.muted))
                  : TextButton(
                      onPressed: _resend, child: Text(s('auth.otp_resend'))),
            ),
          ],
        ),
      ),
    );
  }
}
