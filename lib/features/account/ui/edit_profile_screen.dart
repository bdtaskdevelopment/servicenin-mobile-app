// lib/features/account/ui/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/providers.dart';
import '../../../core/theme/app_theme.dart';

const _groups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
const _genders = ['Male', 'Female', 'Other'];

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _address;
  String _gender = 'Male';
  String _blood = 'B+';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final u = ref.read(authControllerProvider).user;
    _name = TextEditingController(text: u?.fullName ?? '');
    _email = TextEditingController(text: u?.email ?? '');
    _address = TextEditingController(text: u?.address ?? '');
    if (_genders.contains(u?.gender)) _gender = u!.gender!;
    if (_groups.contains(u?.bloodGroup)) _blood = u!.bloodGroup!;
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).updateProfile({
        'full_name': _name.text.trim(),
        'gender': _gender.toLowerCase(),
        'blood_group': _blood,
        'address': _address.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
        context.pop();
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not save profile')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      appBar: AppBar(title: const Text('Edit profile')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: _name, decoration: const InputDecoration(labelText: 'Full name', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        const Text('Gender', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink500)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: _genders.map((g) => ChoiceChip(label: Text(g), selected: _gender == g, onSelected: (_) => setState(() => _gender = g))).toList()),
        const SizedBox(height: 16),
        const Text('Blood group', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink500)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _groups.map((g) => ChoiceChip(label: Text(g), selected: _blood == g, onSelected: (_) => setState(() => _blood = g))).toList()),
        const SizedBox(height: 16),
        TextField(controller: _address, maxLines: 2, decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder())),
        const SizedBox(height: 24),
        FilledButton(onPressed: _busy ? null : _save, child: _busy ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save changes')),
      ]),
    );
  }
}
