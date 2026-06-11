import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/funeral_controller.dart';

const _charcoal = Color(0xFF332F2C);

class FuneralRequestView extends GetView<FuneralController> {
  const FuneralRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(
        child: GetBuilder<FuneralController>(
          builder: (con) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
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
                        Text('Request service'.tr,
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 1),
                        Text('A coordinator will call you'.tr,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    _Label('SERVICE NEEDED'.tr),
                    const SizedBox(height: 10),
                    ...con.services.map((s) {
                      final sel = con.selectedServiceKey == s.key;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () => con.selectService(s.key),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: sel
                                      ? _charcoal
                                      : const Color(0xFFEDEFF2),
                                  width: sel ? 1.6 : 1.2),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                    sel
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    size: 22,
                                    color: sel
                                        ? _charcoal
                                        : const Color(0xFFCBD5E1)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(s.label,
                                          style: const TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF0F172A))),
                                      if (s.priceLabel.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(s.priceLabel,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFFC2410C))),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    _Label('DECEASED DETAILS'.tr),
                    const SizedBox(height: 10),
                    _Field(con.deceasedName, 'NAME OF THE DECEASED'.tr,
                        'Full name'.tr),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _Field(con.deceasedAge, 'AGE'.tr, 'e.g. 78'.tr,
                              kb: TextInputType.number),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _GenderField(con: con)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _Field(con.deathTime, 'TIME OF DEATH'.tr,
                        'YYYY-MM-DD HH:MM'),
                    const SizedBox(height: 12),
                    _Field(con.placeOfDeath, 'PLACE OF DEATH'.tr,
                        'e.g. Dhaka Medical College'.tr),
                    const SizedBox(height: 12),
                    _Field(con.causeOfDeath, 'CAUSE OF DEATH (OPTIONAL)'.tr,
                        'e.g. Old age'.tr),
                    const SizedBox(height: 16),
                    _Label('LOCATION OF BODY'.tr),
                    const SizedBox(height: 10),
                    _Field(con.address, 'ADDRESS'.tr,
                        'Home / hospital address'.tr),
                    const SizedBox(height: 12),
                    _Field(con.wardNo, 'WARD NO (OPTIONAL)'.tr, 'e.g. 10'.tr),
                    const SizedBox(height: 12),
                    _Field(con.scheduledAt, 'PREFERRED TIME (OPTIONAL)'.tr,
                        'YYYY-MM-DD HH:MM'),
                    const SizedBox(height: 16),
                    _Label('YOUR CONTACT'.tr),
                    const SizedBox(height: 10),
                    _Field(con.contactName, 'CONTACT NAME'.tr, 'Your name'.tr),
                    const SizedBox(height: 12),
                    _Field(con.contactPhone, 'CONTACT PHONE'.tr,
                        '+8801XXXXXXXXX',
                        kb: TextInputType.phone),
                    const SizedBox(height: 16),
                    Text(
                        'A coordinator will call within minutes to confirm timing, costs and arrange everything. No payment is taken online.'
                            .tr,
                        style: TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: Colors.black.withValues(alpha: 0.45))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: con.submitting ? null : con.submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _charcoal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: con.submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.4, color: Colors.white),
                          )
                        : Text('Submit request'.tr,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
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

class _Field extends StatelessWidget {
  const _Field(this.controller, this.label, this.hint,
      {this.kb = TextInputType.text});
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType kb;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.6)),
          TextField(
            controller: controller,
            keyboardType: kb,
            style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFB0AEB8)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderField extends StatelessWidget {
  const _GenderField({required this.con});
  final FuneralController con;
  @override
  Widget build(BuildContext context) {
    Widget btn(String g, String label) {
      final sel = con.gender == g;
      return Expanded(
        child: GestureDetector(
          onTap: () => con.setGender(g),
          child: Container(
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: sel ? _charcoal : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: sel ? _charcoal : const Color(0xFFE2E8F0)),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: sel ? Colors.white : const Color(0xFF334155))),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GENDER'.tr,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.6)),
          const SizedBox(height: 6),
          Row(
            children: [
              btn('male', 'Male'.tr),
              const SizedBox(width: 8),
              btn('female', 'Female'.tr),
            ],
          ),
        ],
      ),
    );
  }
}
