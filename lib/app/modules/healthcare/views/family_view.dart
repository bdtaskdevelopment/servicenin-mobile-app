import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/healthcare_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/healthcare_controller.dart';

const _teal = Color(0xFF0D9383);
const _tealTint = Color(0xFFE6F5F4);
const _orange = Color(0xFFF16621);

const List<Color> _memberPalette = [
  Color(0xFF0D9383),
  Color(0xFFEC4899),
  Color(0xFF6366F1),
  Color(0xFF14B8A6),
  Color(0xFFF59E0B),
];

class FamilyView extends GetView<HealthcareController> {
  const FamilyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    splashRadius: 22,
                    onPressed: () => Get.back(),
                    icon: const Icon(LucideIcons.chevronLeft,
                        size: 22, color: Color(0xFF0F172A)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Family members'.tr,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 1),
                      Text('Book & manage care for your family'.tr,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<HealthcareController>(
                builder: (con) => con.loadingFamily && con.family.isEmpty
                    ? const SnListSkeleton(
                        count: 4,
                        showTrailing: false,
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 24))
                    : con.family.isEmpty
                        ? _EmptyFamily(con: con)
                        : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    ...con.family.toList().asMap().entries.map(
                          (e) => FadeInUp(
                            from: 18,
                            duration: const Duration(milliseconds: 350),
                            delay: Duration(
                                milliseconds: 70 * (e.key < 6 ? e.key : 6)),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _MemberCard(member: e.value, con: con),
                            ),
                          ),
                        ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _showAddSheet(con),
                      child: const DottedAddTile(),
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

  void _showAddSheet(HealthcareController con) => _openAddSheet(con);
}

void _openAddSheet(HealthcareController con) {
  Get.bottomSheet(
    _AddFamilySheet(con: con),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _EmptyFamily extends StatelessWidget {
  const _EmptyFamily({required this.con});
  final HealthcareController con;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const SizedBox(height: 60),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _teal,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: _teal.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: const Icon(LucideIcons.users, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => _openAddSheet(con),
          child: const DottedAddTile(),
        ),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member, required this.con});
  final HcFamilyMember member;
  final HealthcareController con;

  void _showEditSheet() {
    Get.bottomSheet(
      _AddFamilySheet(con: con, existing: member),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color =
        _memberPalette[member.name.hashCode.abs() % _memberPalette.length];
    final meta = [
      if (member.relation.isNotEmpty) member.relation,
      if (member.age > 0) '${member.age} yrs',
      if (member.gender.isNotEmpty) member.gender,
    ].join(' · ');
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
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14)),
            alignment: Alignment.center,
            child: Text(member.initials,
                style: TextStyle(
                    color: color,
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
                Text(meta,
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          if (member.bloodGroup.isNotEmpty) ...[
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
          IconButton(
            onPressed: _showEditSheet,
            tooltip: 'Edit'.tr,
            icon: const Icon(LucideIcons.squarePen,
                color: Color(0xFF334155), size: 19),
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
        color: _tealTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: _teal.withValues(alpha: 0.5),
            width: 1.2,
            strokeAlign: BorderSide.strokeAlignInside),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.userPlus, color: _teal, size: 19),
          const SizedBox(width: 8),
          Text('Add family member'.tr,
              style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: _teal)),
        ],
      ),
    );
  }
}

// ── Add/edit family member bottom sheet ──────────────────────────────
class _AddFamilySheet extends StatefulWidget {
  const _AddFamilySheet({required this.con, this.existing});
  final HealthcareController con;

  /// When set, the sheet edits this member instead of creating a new one.
  final HcFamilyMember? existing;

  @override
  State<_AddFamilySheet> createState() => _AddFamilySheetState();
}

class _AddFamilySheetState extends State<_AddFamilySheet> {
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _relation =
      TextEditingController(text: widget.existing?.relation);
  late final _age = TextEditingController(
      text:
          widget.existing != null && widget.existing!.age > 0
              ? '${widget.existing!.age}'
              : null);
  late String _gender =
      widget.existing?.gender.toLowerCase() == 'female' ? 'F' : 'M';
  late String _blood =
      widget.existing?.bloodGroup.isNotEmpty == true
          ? widget.existing!.bloodGroup
          : 'B+';

  bool get _isEdit => widget.existing != null;

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
    final name = _name.text.trim();
    final relation =
        _relation.text.trim().isEmpty ? 'Family' : _relation.text.trim();
    final age = _age.text.trim();
    final gender = _gender == 'M' ? 'male' : 'female';
    if (_isEdit) {
      widget.con.updateFamilyMember(
        id: widget.existing!.id,
        name: name,
        relation: relation,
        age: age,
        gender: gender,
        bloodGroup: _blood,
      );
    } else {
      widget.con.addFamilyMember(
        name: name,
        relation: relation,
        age: age,
        gender: gender,
        bloodGroup: _blood,
      );
    }
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
            color: sel ? _teal : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sel ? _teal : const Color(0xFFE2E8F0)),
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
          20, 12, 20, 20 + MediaQuery.of(context).padding.bottom),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                      _isEdit ? 'Edit family member'.tr : 'Add family member'.tr,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF4F5FA),
                        borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: const Icon(LucideIcons.x,
                        size: 16, color: Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Label('FULL NAME'.tr),
            const SizedBox(height: 8),
            _Field(controller: _name, hint: 'e.g. Ayesha Ahmed'.tr, onChanged: (_) => setState(() {})),
            const SizedBox(height: 14),
            _Label('RELATION'.tr),
            const SizedBox(height: 8),
            _Field(controller: _relation, hint: 'e.g. Spouse, Son, Mother'.tr),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('AGE'.tr),
                      const SizedBox(height: 8),
                      _Field(
                          controller: _age,
                          hint: 'e.g. 29'.tr,
                          keyboard: TextInputType.number),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('GENDER'.tr),
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
            _Label('BLOOD GROUP'.tr),
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
                      color: sel ? _teal : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? _teal : const Color(0xFFE2E8F0)),
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
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFF7C4AC),
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(_isEdit ? 'Save changes'.tr : 'Add member'.tr,
                    style:
                        const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
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
