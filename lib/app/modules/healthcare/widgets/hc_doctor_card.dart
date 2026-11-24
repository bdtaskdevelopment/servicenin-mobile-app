import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/healthcare_controller.dart';

const _teal = Color(0xFF0D9383);
const _tealTint = Color(0xFFE6F5F4);
const _green = Color(0xFF12A14F);

/// Shared doctor card used on the Healthcare home and the "all available" page.
class HcDoctorCard extends StatelessWidget {
  const HcDoctorCard({super.key, required this.doctor});
  final HcDoctor doctor;

  Widget _initialsBox() => Container(
        color: _tealTint,
        alignment: Alignment.center,
        child: Text(doctor.initials,
            style: const TextStyle(
                color: _teal, fontSize: 16, fontWeight: FontWeight.w800)),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: doctor.photo.isNotEmpty
                      ? Image.network(
                          doctor.photo,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _initialsBox(),
                          loadingBuilder: (_, child, progress) =>
                              progress == null ? child : _initialsBox(),
                        )
                      : _initialsBox(),
                ),
              ),
              const Positioned(
                right: -2,
                bottom: -2,
                child: CircleAvatar(
                  radius: 9,
                  backgroundColor: Colors.white,
                  child: Icon(LucideIcons.badgeCheck, size: 16, color: _teal),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(doctor.name,
                          style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                    ),
                    Text(doctor.fee,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _teal)),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${doctor.specialty} · ${doctor.degree}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE7F6ED),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, size: 6, color: _green),
                      const SizedBox(width: 5),
                      Text(doctor.slot,
                          style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: _green)),
                    ],
                  ),
                ),
                if (doctor.video) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text('Video'.tr,
                        style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7C3AED))),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
