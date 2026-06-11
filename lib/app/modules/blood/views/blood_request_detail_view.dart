import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/blood_controller.dart';
import '../widgets/blood_widgets.dart';

const _red = Color(0xFFE11D48);
const _label = Color(0xFF14B8A6);

class BloodRequestDetailView extends GetView<BloodController> {
  const BloodRequestDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final req = controller.viewingRequest;
    if (req == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: SafeArea(
          child: Column(
            children: [
              _DetailHeader(subtitle: ''),
              Expanded(
                child: Center(
                  child: Text('Request not found'.tr,
                      style: const TextStyle(color: Color(0xFF94A3B8))),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final hospital = [req.hospitalName, req.hospitalAddress]
        .where((s) => s.isNotEmpty)
        .join(' · ');
    final contact = [req.contactDisplay, req.phone]
        .where((s) => s.isNotEmpty)
        .join(' · ');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            _DetailHeader(
                subtitle: req.id.isNotEmpty
                    ? 'BR-${req.id.substring(0, req.id.length < 6 ? req.id.length : 6).toUpperCase()}'
                    : ''),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                children: [
                  // Detail card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            BloodGroupBadge(group: req.bloodGroup, size: 52),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${req.unitsNeeded} unit${req.unitsNeeded > 1 ? 's' : ''} · ${req.bloodGroup}',
                                    style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A))),
                                const SizedBox(height: 6),
                                BloodSeverityPill(
                                    severity:
                                        severityFromUrgency(req.urgency)),
                              ],
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                        ),
                        _InfoRow(
                          icon: Icons.local_hospital_outlined,
                          label: 'Hospital'.tr,
                          value: hospital.isNotEmpty ? hospital : 'Not set'.tr,
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(
                          icon: Icons.person_outline_rounded,
                          label: 'Contact'.tr,
                          value: contact.isNotEmpty ? contact : 'Not provided'.tr,
                        ),
                        if (req.timeAgo.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _InfoRow(
                            icon: Icons.access_time_rounded,
                            label: 'Posted'.tr,
                            value: req.timeAgo,
                          ),
                        ],
                        if (req.notes.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(req.notes,
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    color: Color(0xFF475569),
                                    height: 1.4)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Eligibility banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9F7E6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF16A34A), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'If you are eligible and your group is compatible, reach out to the contact above.'.tr,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF166534),
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom action row
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Color(0xFF334155)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: GetBuilder<BloodController>(
                        builder: (con) => ElevatedButton(
                          onPressed: con.responding
                              ? null
                              : () => con.respondToRequest(req.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _red,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                _red.withValues(alpha: 0.6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: con.responding
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5, color: Colors.white),
                                )
                              : Text('Respond — I can donate'.tr,
                                  style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.subtitle});
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 10),
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
              Text('Blood request'.tr,
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 1),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFFDE4E4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 19, color: _red),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _label)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A))),
            ],
          ),
        ),
      ],
    );
  }
}
