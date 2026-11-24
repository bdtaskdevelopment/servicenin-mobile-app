import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/funeral_controller.dart';

const _forest = Color(0xFF2E6A5E);
const _mint = Color(0xFFE7F0ED);
const _lightTile = Color(0xFFF2F3F8);
const _navy = Color(0xFF0F172A);
const _labelColor = Color(0xFF334155);

class FuneralRequestView extends GetView<FuneralController> {
  const FuneralRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: GetBuilder<FuneralController>(
          builder: (con) => Column(
            children: [
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      splashRadius: 22,
                      onPressed: () => Get.back(),
                      icon: const Icon(LucideIcons.chevronLeft,
                          size: 22, color: Color(0xFF1A1A1A)),
                    ),
                    Expanded(
                      child: Text(
                        'Funeral request header'.tr,
                        style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: _navy),
                      ),
                    ),
                    _HeaderIconButton(
                      icon: LucideIcons.receiptText,
                      bg: _lightTile,
                      iconColor: _navy,
                      onTap: con.openMyRequests,
                    ),
                    const SizedBox(width: 10),
                    _HeaderIconButton(
                      icon: LucideIcons.headset,
                      bg: _mint,
                      iconColor: _forest,
                      onTap: con.openSupport,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    Row(
                      children: con.services.asMap().entries.map((e) {
                        final sel = con.selectedServiceId == e.value.id;
                        final icon =
                            e.key == 0 ? LucideIcons.handHeart : LucideIcons.users;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: e.key == con.services.length - 1 ? 0 : 10),
                            child: GestureDetector(
                              onTap: () => con.selectService(e.value.id),
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: sel ? _mint : AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: sel
                                        ? _forest
                                        : const Color(0xFFE2E8F0),
                                    width: sel ? 1.6 : 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(icon,
                                        size: 18,
                                        color: sel
                                            ? _forest
                                            : const Color(0xFF94A3B8)),
                                    const SizedBox(width: 7),
                                    Flexible(
                                      child: Text(
                                        e.value.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: sel ? _forest : _navy,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    _Label('Your information'.tr, bold: true, size: 13),
                    const SizedBox(height: 10),
                    _Label('NAME'.tr),
                    const SizedBox(height: 6),
                    _Field(con.name, 'Your full name'.tr, icon: LucideIcons.user),
                    const SizedBox(height: 12),
                    _Label('PHONE'.tr),
                    const SizedBox(height: 6),
                    _Field(con.phone, '01XXXXXXXXX',
                        kb: TextInputType.phone, icon: LucideIcons.phone),
                    const SizedBox(height: 12),
                    _Label("DECEASED'S GENDER".tr),
                    const SizedBox(height: 8),
                    _GenderPills(
                      options: con.genders,
                      selected: con.gender,
                      onSelected: con.setGender,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Flexible(
                          child: _Label('RELATIONSHIP TO DECEASED'.tr),
                        ),
                        const Text(' *',
                            style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE53E3E))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _Field(con.relationship, 'Relationship hint'.tr,
                        icon: LucideIcons.users),
                    const SizedBox(height: 12),
                    _Label('ADDRESS'.tr),
                    const SizedBox(height: 6),
                    _Field(
                      con.address,
                      'Home / hospital address'.tr,
                      icon: LucideIcons.mapPin,
                      trailing: GestureDetector(
                        onTap: con.pickAddress,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _forest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(LucideIcons.search,
                              size: 17, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Label('NOTES (OPTIONAL)'.tr),
                    const SizedBox(height: 6),
                    _Field(con.notes, 'Note hint'.tr, icon: LucideIcons.pencil),
                    const SizedBox(height: 16),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: _mint,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(LucideIcons.phone, size: 17, color: _forest),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                                'A coordinator will call within minutes to confirm timing, costs and arrange everything. No payment is taken online.'
                                    .tr,
                                style: const TextStyle(
                                    fontSize: 11.5, height: 1.5, color: _forest)),
                          ),
                        ],
                      ),
                    ),
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
                      backgroundColor: AppColors.brandOrange,
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
                                fontSize: 15, fontWeight: FontWeight.w800)),
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

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.bg,
    required this.iconColor,
    required this.onTap,
  });
  final IconData icon;
  final Color bg;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)),
        alignment: Alignment.center,
        child: Icon(icon, size: 19, color: iconColor),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.bold = false, this.size = 11.5});
  final String text;
  final bool bold;
  final double size;
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          fontSize: size,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
          color: _labelColor));
}

class _Field extends StatelessWidget {
  const _Field(this.controller, this.hint,
      {this.kb = TextInputType.text, this.icon, this.trailing});
  final TextEditingController controller;
  final String hint;
  final TextInputType kb;
  final IconData? icon;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: kb,
              style: const TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w600, color: _navy),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8)),
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 6), trailing!],
        ],
      ),
    );
  }
}

/// Deceased's-gender selector — solid forest fill when selected (distinct
/// from the orange-themed shared `GenderSelector` used elsewhere in the
/// app), matching this module's own mockup.
class _GenderPills extends StatelessWidget {
  const _GenderPills({
    required this.options,
    required this.selected,
    required this.onSelected,
  });
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(options.length, (i) {
        final option = options[i];
        final isSelected = option == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == options.length - 1 ? 0 : 10),
            child: GestureDetector(
              onTap: () => onSelected(option),
              child: Container(
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? _forest : AppColors.white,
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(
                    color: isSelected ? _forest : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  option.tr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : _navy,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
