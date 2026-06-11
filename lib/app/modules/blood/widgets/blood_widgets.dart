import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/blood_request_response.dart';
import '../../../data/models/response/donor_response.dart';
import '../controllers/blood_controller.dart';

const _red = Color(0xFFE11D48);

/// Maps the API `urgency` string to the local severity enum.
BloodSeverity severityFromUrgency(String urgency) {
  switch (urgency.toLowerCase()) {
    case 'critical':
    case 'emergency':
      return BloodSeverity.critical;
    case 'routine':
    case 'normal':
    case 'low':
      return BloodSeverity.routine;
    case 'urgent':
    default:
      return BloodSeverity.urgent;
  }
}

/// A blood-request card driven by the API (`/api/v1/blood/requests`).
class BloodRequestApiCard extends StatelessWidget {
  const BloodRequestApiCard({super.key, required this.req, this.onView});
  final BloodRequestEntry req;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    final hospital = [req.hospitalName, req.hospitalAddress]
        .where((s) => s.isNotEmpty)
        .join(' · ');
    return GestureDetector(
      onTap: onView,
      child: Container(
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
                BloodGroupBadge(group: req.bloodGroup),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '${req.unitsNeeded} unit${req.unitsNeeded > 1 ? 's' : ''} · ${req.bloodGroup}',
                            style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A)),
                          ),
                          BloodSeverityPill(
                              severity: severityFromUrgency(req.urgency)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(hospital.isNotEmpty ? hospital : 'Hospital not set'.tr,
                          style: const TextStyle(
                              fontSize: 12.5, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (req.timeAgo.isNotEmpty)
                  Text(req.timeAgo,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded,
                    size: 16, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(req.contactDisplay,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12.5, color: Color(0xFF64748B))),
                ),
                const SizedBox(width: 8),
                Text('View →'.tr,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE11D48))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft background + text colour for a donor's badge level.
({Color bg, Color fg}) _badgeStyle(String level) {
  switch (level.toLowerCase()) {
    case 'platinum':
      return (bg: Color(0xFFE5E9F0), fg: Color(0xFF475569));
    case 'gold':
      return (bg: Color(0xFFFEF3C7), fg: Color(0xFFB45309));
    case 'silver':
      return (bg: Color(0xFFF1F5F9), fg: Color(0xFF64748B));
    case 'bronze':
      return (bg: Color(0xFFFCE7D9), fg: Color(0xFFC2410C));
    default:
      return (bg: Color(0xFFF1F5F9), fg: Color(0xFF64748B));
  }
}

/// A donor card used in the "Requests near you" section and the all-donors
/// screen. Shows the donor's group, name, area and a call action.
class DonorCard extends StatelessWidget {
  const DonorCard(
      {super.key, required this.donor, this.onCall, this.onView});
  final DonorEntry donor;
  final VoidCallback? onCall;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    final name = donor.fullName.isNotEmpty ? donor.fullName : 'ServiceNin Donor';
    final badge = _badgeStyle(donor.badgeLevel);
    return GestureDetector(
      onTap: onView,
      child: Container(
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
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: _red.withValues(alpha: 0.12),
                    shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(donor.initials,
                    style: const TextStyle(
                        color: _red,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                        ),
                        if (donor.isVerified) ...[
                          const SizedBox(width: 5),
                          const Icon(Icons.verified_rounded,
                              size: 15, color: Color(0xFF16A34A)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                        donor.address.isNotEmpty
                            ? donor.address
                            : 'Location not shared'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              BloodGroupBadge(group: donor.bloodGroup),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.water_drop_outlined,
                  size: 15, color: Color(0xFF94A3B8)),
              const SizedBox(width: 5),
              Text('${donor.totalDonations} donations',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF64748B))),
              if (donor.badgeLevel.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: badge.bg, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                      donor.badgeLevel[0].toUpperCase() +
                          donor.badgeLevel.substring(1),
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: badge.fg)),
                ),
              ],
              const Spacer(),
              if (donor.isAvailable)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, size: 7, color: Color(0xFF16A34A)),
                    const SizedBox(width: 4),
                    Text('Available'.tr,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15803D))),
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
              Expanded(
                child: Text(
                    donor.lastDonatedLabel.isNotEmpty
                        ? donor.lastDonatedLabel
                        : 'New donor'.tr,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
              ),
              GestureDetector(
                onTap: onView,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text('View →'.tr,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF334155))),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onCall,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                      color: _red, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.call_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text('Call'.tr,
                          style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

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
                child: Text('View →'.tr,
                    style: const TextStyle(
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
