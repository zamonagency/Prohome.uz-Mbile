import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/network/api_exception.dart';
import '../auth_controller.dart';
import '../auth_repository.dart';

/// Yangi, yagona sahifadagi 4 bosqichli ro'yxatdan o'tish oqimi:
/// TELEFON → KOD → MA'LUMOT → XAVFSIZLIK. Avval bu 3 ta alohida
/// sahifaga (LoginPage → OtpPage → RegisterPage) bo'lingan edi va
/// foydalanuvchi qayerda ekanini bilmasdi — endi yagona joyda,
/// bosqichlar ko'rsatkichi bilan.
class RegisterFlowPage extends ConsumerStatefulWidget {
  const RegisterFlowPage({super.key});

  @override
  ConsumerState<RegisterFlowPage> createState() => _RegisterFlowPageState();
}

class _RegisterFlowPageState extends ConsumerState<RegisterFlowPage> {
  static const _stepLabels = ['TELEFON', 'KOD', "MA'LUMOT", 'XAVFSIZLIK'];

  final _localPhone = TextEditingController();
  final _otp = TextEditingController();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _password = TextEditingController();

  int _step = 0;
  bool _busy = false;
  String? _error;
  int _secondsLeft = 0;

  String get _fullPhone => normalizePhone('+998${_localPhone.text}');

  @override
  void dispose() {
    for (final c in [_localPhone, _otp, _first, _last, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _secondsLeft = 60);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || _secondsLeft <= 1) {
        if (mounted) setState(() => _secondsLeft = 0);
        return false;
      }
      setState(() => _secondsLeft--);
      return true;
    });
  }

  Future<void> _sendOtp() async {
    if (!isValidPhone(_fullPhone)) {
      setState(() => _error = "Telefon raqamini to'liq kiriting");
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .sendOtp(_fullPhone, OtpPurpose.register);
      if (!mounted) return;
      setState(() => _step = 1);
      _startResendTimer();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resendOtp() async {
    try {
      await ref
          .read(authControllerProvider.notifier)
          .sendOtp(_fullPhone, OtpPurpose.register);
      _startResendTimer();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otp.text.trim();
    if (otp.length < 4) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .verifyOtp(_fullPhone, otp, OtpPurpose.register);
      if (!mounted) return;
      setState(() => _step = 2);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _goToSecurity() {
    if (_first.text.trim().isEmpty) {
      setState(() => _error = 'Ismingizni kiriting');
      return;
    }
    setState(() {
      _error = null;
      _step = 3;
    });
  }

  Future<void> _finish() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).register(
            phone: _fullPhone,
            otp: _otp.text.trim(),
            firstName: _first.text.trim(),
            lastName: _last.text.trim(),
            password: _password.text.isEmpty ? null : _password.text,
          );
      if (mounted) context.pop(true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() {
        _error = null;
        _step--;
      });
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _back,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            // Planshetda forma cheksiz cho'zilib ketmasin uchun.
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                _StepIndicator(labels: _stepLabels, current: _step),
                const SizedBox(height: 30),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(0.04, 0), end: Offset.zero)
                          .animate(anim),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _buildStep(context),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(_error!,
                      style: const TextStyle(
                          color: AppColors.danger, fontSize: 13)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case 0:
        return _PhoneStep(
          controller: _localPhone,
          busy: _busy,
          onSubmit: _sendOtp,
          onLoginTap: () => context.pop(),
        );
      case 1:
        return _OtpStep(
          controller: _otp,
          phone: _fullPhone,
          busy: _busy,
          secondsLeft: _secondsLeft,
          onSubmit: _verifyOtp,
          onResend: _resendOtp,
        );
      case 2:
        return _InfoStep(
          first: _first,
          last: _last,
          onSubmit: _goToSecurity,
        );
      default:
        return _SecurityStep(
          password: _password,
          busy: _busy,
          onSubmit: _finish,
        );
    }
  }
}

// ─── Bosqichlar ko'rsatkichi ────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.labels, required this.current});
  final List<String> labels;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          Expanded(
            child: _StepDot(
              index: i + 1,
              label: labels[i],
              state: i < current
                  ? _StepState.done
                  : i == current
                      ? _StepState.active
                      : _StepState.upcoming,
            ),
          ),
          if (i < labels.length - 1)
            Expanded(
              child: SizedBox(
                height: 30,
                child: Center(
                  child: Container(
                    height: 2,
                    color: i < current ? AppColors.primary : context.border,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

enum _StepState { done, active, upcoming }

class _StepDot extends StatelessWidget {
  const _StepDot({required this.index, required this.label, required this.state});
  final int index;
  final String label;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final active = state != _StepState.upcoming;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? AppColors.primary : context.border,
              width: 1.6,
            ),
          ),
          child: state == _StepState.done
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 17)
              : Text(
                  '$index',
                  style: TextStyle(
                    color: active ? Colors.white : context.muted,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
            color: state == _StepState.upcoming
                ? context.muted
                : AppColors.primary,
          ),
        ),
      ],
    );
  }
}

// ─── Umumiy qismlar ─────────────────────────────────────────────────────────
class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: context.texts.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(subtitle,
            style: context.texts.bodyMedium?.copyWith(color: context.muted)),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Gradient asosidagi asosiy amal tugmasi — bosqichlar bo'ylab bir xil.
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.busy = false,
    this.icon = Icons.arrow_forward_rounded,
  });
  final String label;
  final VoidCallback? onTap;
  final bool busy;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: busy ? null : onTap,
          child: Center(
            child: busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.2, color: Colors.white),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15.5)),
                      if (icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(icon, color: Colors.white, size: 19),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── 1. Telefon ─────────────────────────────────────────────────────────────
class _PhoneStep extends StatelessWidget {
  const _PhoneStep({
    required this.controller,
    required this.busy,
    required this.onSubmit,
    required this.onLoginTap,
  });
  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSubmit;
  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _StepHeader(
          title: 'Akkaunt yaratish',
          subtitle: 'Boshlash uchun telefon raqamingizni kiriting',
        ),
        Text('Telefon raqam',
            style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: context.muted)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: context.isDark
                ? AppColors.darkSurfaceAlt
                : const Color(0xFFF1F3F6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16, right: 10),
                child: Text('+998',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
              Container(width: 1, height: 22, color: context.border),
              Expanded(
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    filled: false,
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    hintText: '90 900 90 90',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _PrimaryButton(label: 'Kod yuborish', busy: busy, onTap: onSubmit),
        const SizedBox(height: 20),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Akkauntingiz bormi?',
                  style: TextStyle(color: context.muted, fontSize: 13.5)),
              TextButton(onPressed: onLoginTap, child: const Text('Kirish')),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── 2. Kod ─────────────────────────────────────────────────────────────────
class _OtpStep extends StatefulWidget {
  const _OtpStep({
    required this.controller,
    required this.phone,
    required this.busy,
    required this.secondsLeft,
    required this.onSubmit,
    required this.onResend,
  });
  final TextEditingController controller;
  final String phone;
  final bool busy;
  final int secondsLeft;
  final VoidCallback onSubmit;
  final VoidCallback onResend;

  @override
  State<_OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<_OtpStep> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepHeader(
          title: 'Tasdiqlash kodi',
          subtitle: '${prettyPhone(widget.phone)} raqamiga yuborilgan '
              '6 xonali kodni kiriting',
        ),
        TextField(
          controller: widget.controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 10),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) {
            if (v.length == 6) widget.onSubmit();
          },
          decoration: const InputDecoration(counterText: '', hintText: '••••••'),
        ),
        const SizedBox(height: 18),
        _PrimaryButton(
            label: 'Davom etish', busy: widget.busy, onTap: widget.onSubmit),
        const SizedBox(height: 16),
        Center(
          child: widget.secondsLeft > 0
              ? Text(
                  'Kodni qayta yuborish (00:${widget.secondsLeft.toString().padLeft(2, '0')})',
                  style: TextStyle(color: context.muted, fontSize: 13),
                )
              : TextButton(
                  onPressed: widget.onResend,
                  child: const Text('Kodni qayta yuborish'),
                ),
        ),
      ],
    );
  }
}

// ─── 3. Ma'lumot ────────────────────────────────────────────────────────────
class _InfoStep extends StatelessWidget {
  const _InfoStep({required this.first, required this.last, required this.onSubmit});
  final TextEditingController first;
  final TextEditingController last;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _StepHeader(
          title: "Ma'lumotlaringiz",
          subtitle: 'Ism va familiyangizni kiriting',
        ),
        TextField(
          controller: first,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Ism'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: last,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Familiya'),
        ),
        const SizedBox(height: 22),
        _PrimaryButton(label: 'Davom etish', onTap: onSubmit),
      ],
    );
  }
}

// ─── 4. Xavfsizlik ──────────────────────────────────────────────────────────
class _SecurityStep extends StatefulWidget {
  const _SecurityStep(
      {required this.password, required this.busy, required this.onSubmit});
  final TextEditingController password;
  final bool busy;
  final VoidCallback onSubmit;

  @override
  State<_SecurityStep> createState() => _SecurityStepState();
}

class _SecurityStepState extends State<_SecurityStep> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _StepHeader(
          title: 'Xavfsizlik',
          subtitle:
              'Ixtiyoriy — akkauntingizni parol bilan ham himoyalashingiz mumkin',
        ),
        TextField(
          controller: widget.password,
          autofocus: true,
          obscureText: _obscure,
          decoration: InputDecoration(
            labelText: 'Parol (ixtiyoriy)',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(_obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        const SizedBox(height: 22),
        _PrimaryButton(
          label: "Ro'yxatdan o'tish",
          icon: Icons.check_rounded,
          busy: widget.busy,
          onTap: widget.onSubmit,
        ),
      ],
    );
  }
}
