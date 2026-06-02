import 'package:flutter/material.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/blood_controller.dart';

/// Square blood-group badge (e.g. "B+") with a soft red background.
class BloodGroupBadge extends StatelessWidget {
  const BloodGroupBadge({super.key, required this.group, this.size = 44});
  final String group;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFDE4E4),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(group,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFFE11D48))),
    );
  }
}

/// Severity pill (Critical / Urgent / Routine) with a leading colored dot.
class BloodSeverityPill extends StatelessWidget {
  const BloodSeverityPill({super.key, required this.severity});
  final BloodSeverity severity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: severity.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(color: severity.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(severity.label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: severity.color)),
        ],
      ),
    );
  }
}

/// A nearby blood-request card used on the Blood Bank screen and the
/// "Requests near you" list.
class BloodRequestCard extends StatelessWidget {
  const BloodRequestCard({super.key, required this.req, this.onView});
  final BloodRequest req;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BloodGroupBadge(group: req.group),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${req.units} unit${req.units > 1 ? 's' : ''} · ${req.group}',
                          style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(width: 8),
                        BloodSeverityPill(severity: req.severity),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text('${req.hospital} · ${req.area}',
                        style: const TextStyle(
                            fontSize: 12.5, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                      text: req.distance,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A)),
                      children: const [
                        TextSpan(
                            text: ' km',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2563EB))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(req.timeAgo,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            children: [
              const Icon(Icons.people_alt_outlined,
                  size: 16, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Text('${req.responded} donors responded',
                  style: const TextStyle(
                      fontSize: 12.5, color: Color(0xFF64748B))),
              const Spacer(),
              GestureDetector(
                onTap: onView,
                child: const Text('View →',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE11D48))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
