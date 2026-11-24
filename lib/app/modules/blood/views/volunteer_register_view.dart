import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_google_map.dart';
import '../../../global_widget/sn_map.dart' show SnMapMarker;
import '../../auth/views/steps/step_location.dart';
import '../../auth/widgets/select_field.dart';
import '../../auth/widgets/selection_bottom_sheet.dart';
import '../controllers/blood_volunteer_controller.dart';

const _red = Color(0xFFE5383B);
const _orange = Color(0xFFEA5A0C);

class VolunteerRegisterView extends GetView<BloodVolunteerController> {
  const VolunteerRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(8, 6, 12, 10),
              child: Row(
                children: [
                  IconButton(
                    splashRadius: 22,
                    onPressed: () => Get.back(),
                    icon: const Icon(LucideIcons.chevronLeft, size: 22, color: Color(0xFF0F172A)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Become a volunteer'.tr,
                          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      const SizedBox(height: 1),
                      Text('Join our volunteer team'.tr,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<BloodVolunteerController>(
                builder: (con) => ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  children: [
                    _SectionLabel('YOUR INFO'.tr),
                    const SizedBox(height: 10),
                    _InputCard(controller: con.fullName, hint: 'Full name'.tr),
                    const SizedBox(height: 10),
                    _InputCard(controller: con.phone, hint: '01XXXXXXXXX', keyboard: TextInputType.phone),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SelectField(
                            label: 'Blood group'.tr,
                            leadingIcon: LucideIcons.droplet,
                            centerText: true,
                            value: con.group.isEmpty ? null : con.group,
                            placeholder: 'Select'.tr,
                            onTap: () async {
                              final v = await SelectionBottomSheet.show(
                                  'Blood group'.tr, BloodVolunteerController.groups,
                                  selected: con.group);
                              if (v != null) con.setGroup(v);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _InputCard(controller: con.age, hint: 'e.g. 22'.tr, keyboard: TextInputType.number),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _InputCard(controller: con.profession, hint: 'Profession / institution'.tr),
                    const SizedBox(height: 20),
                    _SectionLabel('YOUR AREA'.tr),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SelectField(
                            label: 'Thana'.tr,
                            leadingIcon: LucideIcons.mapPin,
                            centerText: true,
                            value: con.thana.isEmpty ? null : con.thana,
                            placeholder: 'Select'.tr,
                            onTap: () async {
                              final v = await SelectionBottomSheet.show(
                                  'Thana'.tr, StepLocation.thanas,
                                  selected: con.thana);
                              if (v != null) con.setThana(v);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _InputCard(controller: con.ward, hint: 'Ward'.tr),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _LocationCard(con: con),
                    const SizedBox(height: 20),
                    _SectionLabel('WHICH ROLES WOULD YOU LIKE TO HELP WITH?'.tr),
                    const SizedBox(height: 10),
                    _RolesWrap(con: con),
                    const SizedBox(height: 20),
                    _SectionLabel('DO YOU DONATE BLOOD?'.tr),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _YesNoChip(label: 'Yes'.tr, selected: con.isDonor, onTap: () => con.setIsDonor(true))),
                        const SizedBox(width: 10),
                        Expanded(child: _YesNoChip(label: 'No'.tr, selected: !con.isDonor, onTap: () => con.setIsDonor(false))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _SectionLabel('WHEN DID YOU LAST DONATE?'.tr),
                    const SizedBox(height: 10),
                    _LastDonatedChips(con: con),
                    const SizedBox(height: 20),
                    _SectionLabel('HOW MANY TIMES HAVE YOU DONATED?'.tr),
                    const SizedBox(height: 10),
                    _InputCard(controller: con.donationCount, hint: 'e.g. 5'.tr, keyboard: TextInputType.number),
                  ],
                ),
              ),
            ),
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: GetBuilder<BloodVolunteerController>(
                  builder: (con) => ElevatedButton.icon(
                    onPressed: con.busy ? null : con.submit,
                    icon: const Icon(LucideIcons.send, size: 17),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      disabledBackgroundColor: _orange.withValues(alpha: 0.5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    label: Text('Submit form'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.6));
}

class _InputCard extends StatelessWidget {
  const _InputCard({required this.controller, required this.hint, this.keyboard});
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFB6C0CC)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

class _RolesWrap extends StatelessWidget {
  const _RolesWrap({required this.con});
  final BloodVolunteerController con;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: BloodVolunteerController.roleKeys.map((key) {
        final sel = con.selectedRoles.contains(key);
        return GestureDetector(
          onTap: () => con.toggleRole(key),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sel ? _red : const Color(0xFFE2E8F0), width: sel ? 1.4 : 1),
            ),
            child: Text((BloodVolunteerController.roleLabels[key] ?? key).tr,
                style: TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: sel ? _red : const Color(0xFF334155))),
          ),
        );
      }).toList(),
    );
  }
}

class _YesNoChip extends StatelessWidget {
  const _YesNoChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _red : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? _red : const Color(0xFFE2E8F0)),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: selected ? Colors.white : const Color(0xFF334155))),
      ),
    );
  }
}

class _LastDonatedChips extends StatelessWidget {
  const _LastDonatedChips({required this.con});
  final BloodVolunteerController con;

  static const _options = {
    'never': 'Never donated',
    'over_3_months': 'Over 3 months ago',
    'within_3_months': 'Within 3 months',
    'unsure': 'Not sure',
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _options.entries.map((e) {
        final sel = con.lastDonatedCategory == e.key;
        return GestureDetector(
          onTap: () => con.setLastDonatedCategory(e.key),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: sel ? _red : AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sel ? _red : const Color(0xFFE2E8F0)),
            ),
            child: Text(e.value.tr,
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: sel ? Colors.white : const Color(0xFF334155))),
          ),
        );
      }).toList(),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.con});
  final BloodVolunteerController con;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BloodVolunteerController>(
      builder: (con) {
        final point = LatLng(con.lat, con.lng);
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 140,
                  child: Stack(
                    children: [
                      SnGoogleMap(
                        key: ValueKey('volunteer-map-${con.mapVersion}'),
                        center: point,
                        zoom: 14,
                        showMyLocation: true,
                        markers: [SnMapMarker(point, _red, LucideIcons.mapPin)],
                        onTap: (_) {},
                      ),
                      if (con.loadingLocation)
                        const Positioned(
                          top: 8,
                          right: 8,
                          child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: _red)),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                child: Row(
                  children: [
                    const Icon(LucideIcons.mapPin, size: 15, color: _red),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                          con.locationLabel.isNotEmpty
                              ? con.locationLabel
                              : 'GPS · ${con.lat.toStringAsFixed(4)}, ${con.lng.toStringAsFixed(4)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
