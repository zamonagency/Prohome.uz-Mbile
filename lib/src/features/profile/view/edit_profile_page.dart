import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/settings_controller.dart';
import '../../../common/widgets/location_picker.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/auth_controller.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final _first = TextEditingController(
      text: ref.read(currentUserProvider)?.firstName ?? '');
  late final _last = TextEditingController(
      text: ref.read(currentUserProvider)?.lastName ?? '');
  // Ilgari bu doim `null` bilan boshlanardi — saqlangan hudud hech qachon
  // ko'rsatilmasdi. Endi joriy foydalanuvchining `locationId`sidan boshlanadi.
  late int? _locationId = ref.read(currentUserProvider)?.locationId;
  bool _busy = false;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await ref.read(authControllerProvider.notifier).updateProfile({
        'firstName': _first.text.trim(),
        'lastName': _last.text.trim(),
        if (_locationId != null) 'locationId': _locationId,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil yangilandi')),
        );
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(s('profile.edit'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _first,
            decoration: InputDecoration(labelText: s('auth.first_name')),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _last,
            decoration: InputDecoration(labelText: s('auth.last_name')),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          LocationField(
            locationId: _locationId,
            onChanged: (l) => setState(() => _locationId = l.id),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _busy ? null : _save,
            child: _busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(s('common.save')),
          ),
        ],
      ),
    );
  }
}
