import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/settings_controller.dart';
import '../../../app/theme.dart';
import '../../../core/network/api_exception.dart';
import '../../masters/master_model.dart';
import '../../masters/master_repository.dart';
import '../auth_controller.dart';
import '../auth_repository.dart';

class BecomeMasterPage extends ConsumerStatefulWidget {
  const BecomeMasterPage({super.key});

  @override
  ConsumerState<BecomeMasterPage> createState() => _BecomeMasterPageState();
}

class _BecomeMasterPageState extends ConsumerState<BecomeMasterPage> {
  final _phone = TextEditingController(text: '+998 ');
  final _otp = TextEditingController();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _experience = TextEditingController();
  final _salary = TextEditingController();
  final _bio = TextEditingController();

  SkillType? _skillType;
  final Set<int> _selectedSkillIds = {};
  bool _otpSent = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_phone, _otp, _first, _last, _experience, _salary, _bio]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _sendOtp() async {
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
      setState(() => _otpSent = true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    if (_otp.text.trim().length < 4) {
      setState(() => _error = 'Tasdiqlash kodini kiriting');
      return;
    }
    if (_first.text.trim().isEmpty) {
      setState(() => _error = 'Ismni kiriting');
      return;
    }
    if (_last.text.trim().isEmpty) {
      setState(() => _error = 'Familiyani kiriting');
      return;
    }
    if (_skillType == null) {
      setState(() => _error = 'Mutaxassislikni tanlang');
      return;
    }
    final experience = int.tryParse(_experience.text);
    if (experience == null) {
      setState(() => _error = 'Tajribani (yil) kiriting');
      return;
    }
    if (_selectedSkillIds.isEmpty) {
      setState(() => _error = 'Kamida bitta ko‘nikma tanlang');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).registerAsMaster(
            phone: normalizePhone(_phone.text),
            otp: _otp.text.trim(),
            firstName: _first.text.trim(),
            lastName: _last.text.trim(),
            experience: experience,
            skillTypeId: _skillType!.id,
            skillIds: _selectedSkillIds.toList(),
            salary: num.tryParse(_salary.text),
            bio: _bio.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tabriklaymiz! Siz usta sifatida ro‘yxatdan o‘tdingiz.')),
      );
      context.pop(true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final skills = ref.watch(skillTypesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s('intent.become_master'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Usta bo‘ling',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text(
                  'Mijozlar sizni topsin — mutaxassisligingiz, tajribangiz va narxingizni kiriting.',
                  style: TextStyle(color: Colors.white, fontSize: 12.5, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          TextField(
            controller: _phone,
            enabled: !_otpSent,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]'))],
            decoration: InputDecoration(
              labelText: s('auth.phone'),
              hintText: s('auth.phone_hint'),
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 10),

          if (!_otpSent)
            ElevatedButton(
              onPressed: _busy ? null : _sendOtp,
              child: _busy
                  ? const _Spin()
                  : Text(s('auth.continue')),
            ),

          if (_otpSent) ...[
            TextField(
              controller: _otp,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: s('auth.otp_title'),
                counterText: '',
                prefixIcon: const Icon(Icons.sms_outlined),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _tf(_first, s('auth.first_name'))),
                const SizedBox(width: 12),
                Expanded(child: _tf(_last, s('auth.last_name'))),
              ],
            ),
            const SizedBox(height: 10),
            skills.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (list) => DropdownButtonFormField<SkillType>(
                initialValue: _skillType,
                isExpanded: true,
                decoration: InputDecoration(labelText: s('master.skills')),
                items: list
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                    .toList(),
                onChanged: (v) => setState(() {
                  _skillType = v;
                  _selectedSkillIds.clear();
                }),
              ),
            ),
            if (_skillType != null) ...[
              const SizedBox(height: 10),
              _SkillPicker(
                typeId: _skillType!.id,
                selected: _selectedSkillIds,
                onChanged: (ids) => setState(() {
                  _selectedSkillIds
                    ..clear()
                    ..addAll(ids);
                }),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _tf(_experience, 'Tajriba (yil)', number: true)),
                const SizedBox(width: 12),
                Expanded(child: _tf(_salary, 'Narx (so‘m)', number: true)),
              ],
            ),
            const SizedBox(height: 10),
            _tf(_bio, s('estate.description'), maxLines: 4),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _busy ? null : _submit,
              child: _busy ? const _Spin() : Text(s('auth.register')),
            ),
          ],

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style: const TextStyle(color: AppColors.danger, fontSize: 13)),
          ],
        ],
      ),
    );
  }

  Widget _tf(TextEditingController c, String label,
      {bool number = false, int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      inputFormatters:
          number ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(labelText: label),
    );
  }
}

/// Tanlangan kasb turi (`SkillType`) ichidagi aniq ko'nikmalar — backend
/// kamida bitta `skillIds` talab qiladi.
class _SkillPicker extends ConsumerWidget {
  const _SkillPicker({
    required this.typeId,
    required this.selected,
    required this.onChanged,
  });
  final int typeId;
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skills = ref.watch(skillsByTypeProvider(typeId));
    return skills.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aniq ko‘nikmalar (kamida bittasi)',
                style: TextStyle(fontSize: 12.5, color: context.muted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: list.map((sk) {
                final isSelected = selected.contains(sk.id);
                return FilterChip(
                  label: Text(sk.name),
                  selected: isSelected,
                  onSelected: (v) {
                    final next = {...selected};
                    if (v) {
                      next.add(sk.id);
                    } else {
                      next.remove(sk.id);
                    }
                    onChanged(next);
                  },
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class _Spin extends StatelessWidget {
  const _Spin();
  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
}
