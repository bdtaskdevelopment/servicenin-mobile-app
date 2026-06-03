import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/healthcare_controller.dart';

const _green = Color(0xFF16A34A);
const _darkGreen = Color(0xFF0F7A52);

class FamilyView extends GetView<HealthcareController> {
  const FamilyView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    splashRadius: 22,
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: Color(0xFF1A1A1A)),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Family members',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      SizedBox(height: 1),
                      Text('Book & manage care for your family',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const Spacer(),
                  // Add button (top right)
                  GestureDetector(
                    onTap: () => _showAddSheet(con),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<HealthcareController>(
                builder: (con) => ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    ...con.family.map((m) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _MemberCard(member: m),
                        )),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _showAddSheet(con),
                      child: DottedAddTile(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSheet(HealthcareController con) {
    Get.bottomSheet(
      _AddFamilySheet(con: con),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member});
  final FamilyMember member;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: member.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14)),
            alignment: Alignment.center,
            child: Text(member.initials,
                style: TextStyle(
                    color: member.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name,
                    style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('${member.relation} · ${member.age} yrs · ${member.gender}',
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                color: const Color(0xFFFDE4E4),
                borderRadius: BorderRadius.circular(20)),
            child: Text(member.bloodGroup,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE11D48))),
          ),
        ],
      ),
    );
  }
}

class DottedAddTile extends StatelessWidget {
  const DottedAddTile({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: _green.withValues(alpha: 0.5),
            width: 1.2,
            strokeAlign: BorderSide.strokeAlignInside),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.add_rounded, color: _darkGreen, size: 20),
          SizedBox(width: 8),
          Text('Add family member',
              style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: _darkGreen)),
        ],
      ),
    );
  }
}

// ── Add family member bottom sheet ──────────────────────────────────
class _AddFamilySheet extends StatefulWidget {
  const _AddFamilySheet({required this.con});
  final HealthcareController con;

  @override
  State<_AddFamilySheet> createState() => _AddFamilySheetState();
}

class _AddFamilySheetState extends State<_AddFamilySheet> {
  final _name = TextEditingController();
  final _relation = TextEditingController();
  final _age = TextEditingController();
  String _gender = 'M';
  String _blood = 'B+';

  static const _groups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  bool get _valid => _name.text.trim().isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    _relation.dispose();
    _age.dispose();
    super.dispose();
  }

  void _save() {
    if (!_valid) return;
    widget.con.addFamilyMember(
      name: _name.text.trim(),
      relation: _relation.text.trim().isEmpty
          ? 'Family'
          : _relation.text.trim(),
      age: _age.text.trim().isEmpty ? '—' : _age.text.trim(),
      gender: _gender,
      bloodGroup: _blood,
    );
    Get.back();
  }

  Widget _genderBtn(String g) {
    final sel = _gender == g;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = g),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: sel ? _green : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sel ? _green : const Color(0xFFE2E8F0)),
          ),
          child: Text(g,
              style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: sel ? Colors.white : const Color(0xFF334155))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Add family member',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 16),
            const _Label('FULL NAME'),
            const SizedBox(height: 8),
            _Field(controller: _name, hint: 'e.g. Ayesha Ahmed', onChanged: (_) => setState(() {})),
            const SizedBox(height: 14),
            const _Label('RELATION'),
            const SizedBox(height: 8),
            _Field(controller: _relation, hint: 'e.g. Spouse, Son, Mother'),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('AGE'),
                      const SizedBox(height: 8),
                      _Field(
                          controller: _age,
                          hint: 'e.g. 29',
                          keyboard: TextInputType.number),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('GENDER'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _genderBtn('M'),
                          const SizedBox(width: 8),
                          _genderBtn('F'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const _Label('BLOOD GROUP'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _groups.map((g) {
                final sel = _blood == g;
                return GestureDetector(
                  onTap: () => setState(() => _blood = g),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: sel ? _green : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? _green : const Color(0xFFE2E8F0)),
                    ),
                    child: Text(g,
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: sel ? Colors.white : const Color(0xFF334155))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _valid ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFA7D8BC),
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Add member',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.5));
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.keyboard,
    this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboard;
  final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        onChanged: onChanged,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFFB6C0CC)),
        ),
      ),
    );
  }
}
