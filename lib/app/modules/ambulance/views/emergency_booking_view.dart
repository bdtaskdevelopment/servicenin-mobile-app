import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/emergency_controller.dart';

const _red = Color(0xFFE23744);

class EmergencyBookingView extends GetView<EmergencyController> {
  const EmergencyBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        children: [
          // Red header
          Container(
            color: _red,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 12),
                child: Row(
                  children: [
                    IconButton(
                      splashRadius: 22,
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: Colors.white),
                    ),
                    Text('Emergency Booking'.tr,
                        style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    const Spacer(),
                    GetBuilder<EmergencyController>(
                      builder: (con) => Text('-${con.countdown}s',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFFD9DC))),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Pre-filled banner
          Container(
            width: double.infinity,
            color: const Color(0xFFFDECEC),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Stay calm. We've pre-filled everything.".tr,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('Book an ambulance in 2 taps · Confirm to dispatch.'.tr,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Expanded(
            child: GetBuilder<EmergencyController>(
              builder: (con) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  children: [
                    _Field(
                      icon: Icons.location_on_outlined,
                      label: 'PICKUP'.tr,
                      value: con.pickup,
                      trailing: _pill('GPS'),
                    ),
                    const SizedBox(height: 12),
                    _Field(
                      icon: Icons.local_hospital_outlined,
                      label: 'TAKE TO'.tr,
                      value: con.takeTo,
                      sub: con.hospital,
                      chevron: true,
                    ),
                    const SizedBox(height: 12),
                    _Field(
                      icon: Icons.favorite_border_rounded,
                      label: 'PATIENT CONDITION'.tr,
                      value: con.conditionLabel,
                      dropdown: true,
                    ),
                    const SizedBox(height: 12),
                    _Field(
                      icon: Icons.airport_shuttle_rounded,
                      label: 'AMBULANCE'.tr,
                      value: con.ambulanceType,
                      sub: 'Recommended for selected condition'.tr,
                      dropdown: true,
                    ),
                    const SizedBox(height: 12),
                    _Field(
                      icon: Icons.call_outlined,
                      label: 'EMERGENCY CONTACT'.tr,
                      value: con.contact,
                      dropdown: true,
                    ),
                    const SizedBox(height: 18),
                    Text('CONDITION (TAP TO OVERRIDE)'.tr,
                        style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: EmergencyController.conditions.map((c) {
                        final sel = con.condition == c;
                        return GestureDetector(
                          onTap: () => con.selectCondition(c),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                              color: sel ? _red : AppColors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: sel
                                      ? _red
                                      : const Color(0xFFE2E8F0)),
                            ),
                            child: Text(c,
                                style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: sel
                                        ? Colors.white
                                        : const Color(0xFF334155))),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    const Divider(height: 1, color: Color(0xFFEDEFF2)),
                    const SizedBox(height: 14),
                    _summaryRow('Est. arrival'.tr, con.estArrival),
                    const SizedBox(height: 10),
                    _summaryRow('Distance'.tr, con.distance),
                    const SizedBox(height: 10),
                    _summaryRow('Est. fare'.tr, con.fare),
                  ],
                );
              },
            ),
          ),
          // Bottom action
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                SizedBox(
                  width: 54,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Icon(Icons.call_rounded, color: _red),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: controller.confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('HOLD to Confirm'.tr,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _pill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.circle, size: 7, color: Color(0xFF16A34A)),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF15803D))),
        ]),
      );

  static Widget _summaryRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF64748B))),
          Text(value,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        ],
      );
}

class _Field extends StatelessWidget {
  const _Field({
    required this.icon,
    required this.label,
    required this.value,
    this.sub,
    this.trailing,
    this.chevron = false,
    this.dropdown = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? sub;
  final Widget? trailing;
  final bool chevron;
  final bool dropdown;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: const Color(0xFFFDE4E4),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: _red, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                if (sub != null) ...[
                  const SizedBox(height: 1),
                  Text(sub!,
                      style: const TextStyle(
                          fontSize: 11.5, color: Color(0xFF94A3B8))),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (chevron)
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          if (dropdown)
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}
