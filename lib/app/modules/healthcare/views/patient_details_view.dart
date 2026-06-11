import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/booking_controller.dart';
import '../widgets/booking_stepper.dart';

const _green = Color(0xFF0F7A52);
const _tile = Color(0xFFD9F7E6);

class PatientDetailsView extends GetView<BookingController> {
  const PatientDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<BookingController>(
          builder: (con) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 16, 4),
                  child: Row(
                    children: [
                      IconButton(
                        splashRadius: 22,
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: Color(0xFF1A1A1A)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Patient details'.tr,
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                          Text('From your ServiceNin profile'.tr,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ],
                  ),
                ),
                const BookingStepper(current: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                    children: [
                      Row(
                        children: [
                          _Label('WHO IS THIS FOR?'.tr),
                          const SizedBox(width: 8),
                          _V2Badge('saved family · v2'.tr),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(con.patients.length, (i) {
                        final p = con.patients[i];
                        final sel = con.selectedPatient == i;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => con.selectPatient(i),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: sel
                                        ? _green
                                        : const Color(0xFFE2E8F0),
                                    width: sel ? 1.6 : 1.2),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                        color: _tile,
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    alignment: Alignment.center,
                                    child: Text(p.initials,
                                        style: const TextStyle(
                                            color: _green,
                                            fontWeight: FontWeight.w800)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('${p.name} · ${p.relation}',
                                            style: const TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F172A))),
                                        const SizedBox(height: 2),
                                        Text(p.info,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF94A3B8))),
                                      ],
                                    ),
                                  ),
                                  _Radio(selected: sel),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      GestureDetector(
                        onTap: () => _showAddPatientSheet(con),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add, size: 18, color: _green),
                              const SizedBox(width: 6),
                              Text('Add a family member'.tr,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _green)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _Label('REASON FOR VISIT'.tr),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: con.reasonCtrl,
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText: 'Describe symptoms (optional)…'.tr,
                                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                border: InputBorder.none,
                                isCollapsed: true,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: con.reasonChips
                                  .map((c) => GestureDetector(
                                        onTap: () => con.setReason(c),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 7),
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Text(c,
                                              style: const TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF334155))),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: con.uploadingAttachment
                            ? null
                            : con.pickAttachment,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.photo_camera_outlined,
                                    color: Color(0xFF64748B), size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Attach reports'.tr,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A))),
                                    const SizedBox(height: 2),
                                    Text(
                                        con.attachmentName.isNotEmpty
                                            ? con.attachmentName
                                            : 'Prescriptions, lab tests (optional)'.tr,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: con.attachmentName.isNotEmpty
                                                ? _green
                                                : const Color(0xFF94A3B8))),
                                  ],
                                ),
                              ),
                              con.uploadingAttachment
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.2, color: _green),
                                    )
                                  : Icon(
                                      con.attachmentName.isNotEmpty
                                          ? Icons.check_circle
                                          : Icons.chevron_right_rounded,
                                      color: con.attachmentName.isNotEmpty
                                          ? _green
                                          : const Color(0xFF94A3B8)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: con.booking
                          ? null
                          : (con.isPaid
                              ? con.patientContinue
                              : con.confirmBooking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: con.booking
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.4, color: Colors.white),
                            )
                          : Text(
                              con.isPaid
                                  ? 'Continue to payment →'.tr
                                  : 'Continue booking'.tr,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

void _showAddPatientSheet(BookingController con) {
  Get.bottomSheet(
    _AddPatientSheet(con: con),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _AddPatientSheet extends StatefulWidget {
  const _AddPatientSheet({required this.con});
  final BookingController con;

  @override
  State<_AddPatientSheet> createState() => _AddPatientSheetState();
}

class _AddPatientSheetState extends State<_AddPatientSheet> {
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
    widget.con.addFamilyPatient(
      name: _name.text.trim(),
      relation: _relation.text.trim().isEmpty ? 'Family' : _relation.text.trim(),
      age: _age.text.trim(),
      gender: _gender == 'M' ? 'male' : 'female',
      bloodGroup: _blood,
    );
    Get.back();
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
            Text('Add a family member'.tr,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 16),
            _Label('FULL NAME'.tr),
            const SizedBox(height: 8),
            _SheetField(
                controller: _name,
                hint: 'e.g. Rokeya Begum'.tr,
                onChanged: (_) => setState(() {})),
            const SizedBox(height: 14),
            _Label('RELATION'.tr),
            const SizedBox(height: 8),
            _SheetField(controller: _relation, hint: 'e.g. Mother, Son'.tr),
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
                      _SheetField(
                          controller: _age,
                          hint: 'e.g. 61'.tr,
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
                      color: sel ? _green : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? _green : const Color(0xFFE2E8F0)),
                    ),
                    child: Text(g,
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color:
                                sel ? Colors.white : const Color(0xFF334155))),
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
                child: Text('Add member'.tr,
                    style:
                        const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
          ),
        ),
    );
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
}

class _SheetField extends StatelessWidget {
  const _SheetField({
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

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.6));
}

class _V2Badge extends StatelessWidget {
  const _V2Badge(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(20)),
      child: Text('● $text',
          style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFFB45309))),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});
  final bool selected;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? _green : Colors.transparent,
        border: Border.all(
            color: selected ? _green : const Color(0xFFCBD5E1), width: 2),
      ),
      child: selected
          ? const Icon(Icons.circle, size: 8, color: Colors.white)
          : null,
    );
  }
}
