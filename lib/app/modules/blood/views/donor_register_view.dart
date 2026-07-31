import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_google_map.dart';
import '../../../global_widget/sn_map.dart' show SnMapMarker;
import '../controllers/donor_register_controller.dart';

const _red = Color(0xFFE11D48);

/// "Register as a blood donor" form. Collects blood group, location and an
/// optional note, then POSTs to /blood/donors/register. On success the
/// controller moves to the OTP verification screen.
class DonorRegisterView extends GetView<DonorRegisterController> {
  const DonorRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: GetBuilder<DonorRegisterController>(
                builder: (con) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    children: [
                      const _Intro(),
                      const SizedBox(height: 22),
                      _SectionLabel('YOUR BLOOD GROUP'.tr),
                      const SizedBox(height: 12),
                      _GroupGrid(con: con),
                      const SizedBox(height: 22),
                      _SectionLabel('YOUR DETAILS'.tr),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _InputCard(
                              controller: con.age,
                              hint: 'Age'.tr,
                              keyboard: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: _InputCard(
                              controller: con.profession,
                              hint: 'Profession'.tr,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _SectionLabel('YOUR LOCATION'.tr),
                      const SizedBox(height: 12),
                      _LocationCard(con: con),
                      const SizedBox(height: 22),
                      _SectionLabel('NOTES (OPTIONAL)'.tr),
                      const SizedBox(height: 12),
                      _InputCard(
                        controller: con.notes,
                        hint:
                            'Anything donors should know — availability, conditions…'.tr,
                        maxLines: 4,
                      ),
                    ],
                  );
                },
              ),
            ),
            // ── Register button ──────────────────────────────────
            GetBuilder<DonorRegisterController>(
              builder: (con) => Container(
                color: AppColors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: con.busy ? null : con.register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      disabledBackgroundColor: _red.withValues(alpha: 0.45),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                        (con.isEditing ? 'Save changes' : 'Register as donor →')
                            .tr,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F8FA),
      padding: const EdgeInsets.fromLTRB(8, 6, 12, 10),
      child: Row(
        children: [
          IconButton(
            splashRadius: 22,
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: Color(0xFF1A1A1A)),
          ),
          GetBuilder<DonorRegisterController>(
            builder: (con) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text((con.isEditing ? 'Update donor profile' : 'Become a donor')
                  .tr,
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
              const SizedBox(height: 1),
              Text(
                  (con.isEditing
                          ? 'Update your details & availability'
                          : 'Join the donor network')
                      .tr,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            ],
          ),
          ),
        ],
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8333A), Color(0xFFC81E2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.volunteer_activism_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Save lives near you'.tr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(
                  'We\'ll send a one-time code to verify your account.'.tr,
                  style: const TextStyle(
                      color: Color(0xFFFFE0E2), fontSize: 12.5, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF94A3B8),
        letterSpacing: 0.8,
      ),
    );
  }
}

// ── Blood group grid ────────────────────────────────────────────────
class _GroupGrid extends StatelessWidget {
  const _GroupGrid({required this.con});
  final DonorRegisterController con;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: DonorRegisterController.groups.map((g) {
        final sel = con.group == g;
        return GestureDetector(
          onTap: () => con.setGroup(g),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: sel ? _red : AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: sel ? _red : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(g,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: sel ? Colors.white : const Color(0xFF1E293B))),
          ),
        );
      }).toList(),
    );
  }
}

// ── Location (interactive Google map + GPS) ─────────────────────────
class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.con});
  final DonorRegisterController con;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DonorRegisterController>(
      builder: (con) {
        final point = LatLng(con.lat, con.lng);
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEDEFF2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 160,
                  child: Stack(
                    children: [
                      SnGoogleMap(
                        key: ValueKey('donor-map-${con.mapVersion}'),
                        center: point,
                        zoom: 15,
                        showMyLocation: true,
                        markers: [
                          SnMapMarker(
                              point, _red, Icons.person_pin_circle_rounded),
                        ],
                        onTap: con.setLocationFromMapTap,
                      ),
                      if (con.loadingLocation)
                        const Positioned(
                          top: 8,
                          right: 8,
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.2, color: _red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
                child: Row(
                  children: [
                    const Icon(Icons.place_rounded, size: 16, color: _red),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        con.locationLabel.isNotEmpty
                            ? con.locationLabel
                            : 'GPS · ${con.lat.toStringAsFixed(4)}, ${con.lng.toStringAsFixed(4)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: con.useCurrentLocation,
                      icon: const Icon(Icons.my_location_rounded, size: 18),
                      label: Text('Use current location'.tr,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF16A34A)),
                    ),
                  ),
                  Container(
                      width: 1, height: 20, color: const Color(0xFFEDEFF2)),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: con.openLocationSearch,
                      icon: const Icon(Icons.search_rounded, size: 18),
                      label: Text('Search'.tr,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      style: TextButton.styleFrom(foregroundColor: _red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Input card (notes) ──────────────────────────────────────────────
class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboard,
  });
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFFB6C0CC)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
