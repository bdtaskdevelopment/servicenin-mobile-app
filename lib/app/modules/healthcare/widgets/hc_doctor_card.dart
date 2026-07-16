import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/healthcare_controller.dart';

const _tile = Color(0xFFD9F7E6);

/// Shared doctor card used on the Healthcare home and the "all available" page.
class HcDoctorCard extends StatelessWidget {
  const HcDoctorCard({super.key, required this.doctor});
  final HcDoctor doctor;

  Widget _initialsBox() => Container(
        color: _tile,
        alignment: Alignment.center,
        child: Text(doctor.initials,
            style: TextStyle(
                color: doctor.color,
                fontSize: 16,
                fontWeight: FontWeight.w800)),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: doctor.photo.isNotEmpty
                      ? Image.network(
                          doctor.photo,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _initialsBox(),
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
                  child: Icon(Icons.check_circle,
                      size: 16, color: Color(0xFF16A34A)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('${doctor.specialty} · ${doctor.degree}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
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
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(doctor.fee,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF15803D))),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(doctor.slot,
                    style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15803D))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
