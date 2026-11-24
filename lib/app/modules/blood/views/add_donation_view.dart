import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/blood_response_response.dart';
import '../controllers/add_donation_controller.dart';

const _red = Color(0xFFE5383B);
const _pinkTile = Color(0xFFFDECEC);
const _orange = Color(0xFFEA5A0C);

class AddDonationView extends GetView<AddDonationController> {
  const AddDonationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 10),
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
                      Text('Add donation'.tr,
                          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      const SizedBox(height: 1),
                      Text('Donation details & photo'.tr,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<AddDonationController>(
                builder: (con) => ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  children: [
                    _PhotoUploadCard(con: con),
                    const SizedBox(height: 14),
                    _PhotoThumbRow(con: con),
                    const SizedBox(height: 20),
                    _SectionLabel('WHICH REQUEST DID YOU DONATE FOR?'.tr),
                    const SizedBox(height: 10),
                    _ResponsePicker(con: con),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel('DATE'.tr),
                              const SizedBox(height: 10),
                              _DatePickerField(con: con),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel('BAGS'.tr),
                              const SizedBox(height: 10),
                              _BagsStepper(con: con),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _SectionLabel('YOUR FEELING (OPTIONAL)'.tr),
                    const SizedBox(height: 10),
                    _InputCard(controller: con.feeling, hint: 'How did it feel to donate blood?'.tr, maxLines: 3),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => con.setConsent(!con.consentMediaUse),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(con.consentMediaUse ? LucideIcons.squareCheck : LucideIcons.square,
                              size: 20, color: con.consentMediaUse ? _red : const Color(0xFF94A3B8)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('I allow ServiceNin to use this photo on social media & magazine'.tr,
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569), height: 1.4)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionLabel('SUGGESTION / QUESTION (OPTIONAL)'.tr),
                    const SizedBox(height: 10),
                    _InputCard(controller: con.suggestion, hint: 'Any suggestion or question for us?'.tr, maxLines: 3),
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
                child: GetBuilder<AddDonationController>(
                  builder: (con) => ElevatedButton.icon(
                    onPressed: con.busy ? null : con.submit,
                    icon: con.busy
                        ? const SizedBox.shrink()
                        : const Icon(LucideIcons.circleCheck, size: 18),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      disabledBackgroundColor: _orange.withValues(alpha: 0.5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    label: con.busy
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : Text('Save donation'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
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

class _PhotoUploadCard extends StatelessWidget {
  const _PhotoUploadCard({required this.con});
  final AddDonationController con;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: con.pickPhotos,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _red.withValues(alpha: 0.4), width: 1.3),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: _pinkTile, shape: BoxShape.circle),
              child: const Icon(LucideIcons.camera, size: 22, color: _red),
            ),
            const SizedBox(height: 10),
            Text('Upload donation photo'.tr,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            const SizedBox(height: 4),
            Text('${'From camera or gallery'.tr} · ${'up to'.tr} ${AddDonationController.maxPhotos} ${'photos'.tr}',
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }
}

class _PhotoThumbRow extends StatelessWidget {
  const _PhotoThumbRow({required this.con});
  final AddDonationController con;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(AddDonationController.maxPhotos, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == AddDonationController.maxPhotos - 1 ? 0 : 10),
            child: _PhotoSlot(con: con, index: i),
          ),
        );
      }),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({required this.con, required this.index});
  final AddDonationController con;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (index < con.photos.length) {
      final file = con.photos[index];
      return AspectRatio(
        aspectRatio: 1,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(file, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            ),
            Positioned(
              right: -6,
              top: -6,
              child: GestureDetector(
                onTap: () => con.removePhoto(index),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.4),
                  ),
                  child: const Icon(LucideIcons.x, size: 11, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }
    final isNextAdd = index == con.photos.length;
    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onTap: isNextAdd ? con.pickPhotos : null,
        child: Container(
          decoration: BoxDecoration(
            color: isNextAdd ? _pinkTile : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: isNextAdd ? const Icon(LucideIcons.imagePlus, size: 18, color: _red) : null,
        ),
      ),
    );
  }
}

class _ResponsePicker extends StatelessWidget {
  const _ResponsePicker({required this.con});
  final AddDonationController con;

  @override
  Widget build(BuildContext context) {
    final options = con.myDonatedResponses;
    return GestureDetector(
      onTap: () async {
        final picked = await showModalBottomSheet<BloodResponseEntry?>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => _ResponseSheet(options: options),
        );
        con.setLinkedResponse(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.fileText, size: 18, color: Color(0xFF94A3B8)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                  con.linkedResponse == null
                      ? 'Not linked to a specific request (optional)'.tr
                      : '${con.linkedResponse!.bloodGroup} · ${con.linkedResponse!.hospital}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: con.linkedResponse == null ? const Color(0xFFB6C0CC) : const Color(0xFF0F172A))),
            ),
            const Icon(LucideIcons.chevronDown, size: 18, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

class _ResponseSheet extends StatelessWidget {
  const _ResponseSheet({required this.options});
  final List<BloodResponseEntry> options;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select a request'.tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Not linked (optional)'.tr),
            onTap: () => Get.back<BloodResponseEntry?>(result: null),
          ),
          if (options.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('No completed donations on record yet'.tr,
                  style: const TextStyle(color: Color(0xFF94A3B8))),
            ),
          ...options.map((r) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${r.bloodGroup} · ${r.hospital}'),
                onTap: () => Get.back<BloodResponseEntry?>(result: r),
              )),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({required this.con});
  final AddDonationController con;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: con.donatedAt,
          firstDate: DateTime.now().subtract(const Duration(days: 3650)),
          lastDate: DateTime.now(),
          builder: (ctx, child) =>
              Theme(data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: _red)), child: child!),
        );
        if (picked != null) con.setDonatedAt(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.calendar, size: 17, color: Color(0xFF94A3B8)),
            const SizedBox(width: 8),
            Expanded(
              child: Text('${con.donatedAt.day}/${con.donatedAt.month}/${con.donatedAt.year}',
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            ),
          ],
        ),
      ),
    );
  }
}

class _BagsStepper extends StatelessWidget {
  const _BagsStepper({required this.con});
  final AddDonationController con;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: con.decBags,
            customBorder: const CircleBorder(),
            child: const Padding(padding: EdgeInsets.all(6), child: Icon(LucideIcons.minus, size: 18, color: Color(0xFF334155))),
          ),
          Text('${con.bags}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          InkWell(
            onTap: con.incBags,
            customBorder: const CircleBorder(),
            child: const Padding(padding: EdgeInsets.all(6), child: Icon(LucideIcons.plus, size: 18, color: _red)),
          ),
        ],
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({required this.controller, required this.hint, this.maxLines = 1});
  final TextEditingController controller;
  final String hint;
  final int maxLines;

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
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFB6C0CC)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
