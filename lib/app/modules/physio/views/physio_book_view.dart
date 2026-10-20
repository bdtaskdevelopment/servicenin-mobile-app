import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/physio_controller.dart';
import '../physio_palette.dart';

class PhysioBookView extends GetView<PhysioController> {
  const PhysioBookView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<PhysioController>(
          builder: (con) {
            final style = physioStyleFor(con.center?.id ?? '');
            final brown = style.accent;
            final tile = style.tile;
            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 16, 4),
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
                          Text('Checkout'.tr,
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                          Text(con.center?.name ?? '',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: brown,
                    onRefresh: con.refreshBookView,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                      children: [
                        _Label('CART'.tr),
                        const SizedBox(height: 10),
                        _CartSummary(con: con, accent: brown),
                        const SizedBox(height: 18),
                        _Label('VISIT TYPE'.tr),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _TypeCard(
                                icon: Icons.meeting_room_outlined,
                                label: 'Center visit'.tr,
                                selected: con.sessionType == 0,
                                accent: brown,
                                tile: tile,
                                onTap: () => con.setSessionType(0),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _TypeCard(
                                icon: Icons.home_outlined,
                                label: 'Home visit'.tr,
                                selected: con.sessionType == 1,
                                accent: brown,
                                tile: tile,
                                onTap: () => con.setSessionType(1),
                              ),
                            ),
                          ],
                        ),
                        // Only on the default (center) view — once the
                        // patient has actually picked Home visit, they've
                        // already seen/accepted that price, so the heads-up
                        // has done its job and stays out of the way.
                        if (con.sessionType == 0 && con.visitPriceDiffers) ...[
                          const SizedBox(height: 10),
                          _PriceDiffNote(con: con),
                        ],
                        if (con.sessionType == 1) ...[
                          const SizedBox(height: 18),
                          _Label('HOME ADDRESS'.tr),
                          const SizedBox(height: 10),
                          _TextBox(
                            controller: con.homeAddressCtrl,
                            hint: 'Where should the therapist visit?'.tr,
                            accent: brown,
                            onSearchTap: () => con.pickAddress(
                                ctrl: con.homeAddressCtrl, isHome: true),
                          ),
                        ] else ...[
                          const SizedBox(height: 18),
                          _Label('RESIDENTIAL ADDRESS'.tr),
                          const SizedBox(height: 10),
                          _TextBox(
                            controller: con.addressCtrl,
                            hint: 'Your home address'.tr,
                            accent: brown,
                            onSearchTap: () => con.pickAddress(
                                ctrl: con.addressCtrl, isHome: false),
                          ),
                        ],
                        const SizedBox(height: 18),
                        _Label('DATE'.tr),
                        const SizedBox(height: 10),
                        if (con.loadingDates && con.scheduleDates.isEmpty)
                          SnShimmer(
                            child: SizedBox(
                              height: 74,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 5,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 10),
                                itemBuilder: (_, __) => const SnBone(
                                    width: 76, height: 74, radius: 12),
                              ),
                            ),
                          )
                        else
                          FadeInUp(
                            from: 18,
                            duration: const Duration(milliseconds: 350),
                            child: SizedBox(
                              height: 74,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: con.scheduleDates.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 10),
                                itemBuilder: (_, i) {
                                  final d = con.scheduleDates[i];
                                  final sel = con.dateIndex == i;
                                  return GestureDetector(
                                    onTap: () => con.selectDate(i),
                                    child: Container(
                                      width: 76,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: sel ? brown : AppColors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: sel
                                                ? brown
                                                : const Color(0xFFE2E8F0)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(d.label,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: sel
                                                      ? Colors.white
                                                      : const Color(
                                                          0xFF64748B))),
                                          const SizedBox(height: 2),
                                          Text(d.dayShort,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w800,
                                                  color: sel
                                                      ? Colors.white
                                                      : const Color(
                                                          0xFF0F172A))),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        const SizedBox(height: 18),
                        _Label('TIME'.tr),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _pickEasyTime(context, con, brown),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time_rounded,
                                    size: 18, color: brown),
                                const SizedBox(width: 10),
                                Text(con.selectedTimeLabel,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A))),
                                const Spacer(),
                                Icon(Icons.keyboard_arrow_down_rounded,
                                    color: brown),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _Label('NOTES (OPTIONAL)'.tr),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            controller: con.notesCtrl,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Describe your concern (optional)…'.tr,
                              hintStyle:
                                  const TextStyle(color: Color(0xFF94A3B8)),
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _BottomBar(
                  total: con.cartTotal,
                  loading: con.booking,
                  accent: brown,
                  onTap: con.confirmBooking,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TextBox extends StatelessWidget {
  const _TextBox({
    required this.controller,
    required this.hint,
    this.accent,
    this.onSearchTap,
  });
  final TextEditingController controller;
  final String hint;
  // When set, shows a map-search icon that opens Google Places search
  // (PhysioAddressSearchView) — same pattern Home Service's address field
  // uses. The field stays freely editable either way; picking a result
  // just fills it.
  final Color? accent;
  final VoidCallback? onSearchTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (onSearchTap != null)
            IconButton(
              splashRadius: 18,
              onPressed: onSearchTap,
              icon: Icon(Icons.search_rounded,
                  size: 20, color: accent ?? const Color(0xFF94A3B8)),
              tooltip: 'Search on map'.tr,
            ),
        ],
      ),
    );
  }
}

class _PriceDiffNote extends StatelessWidget {
  const _PriceDiffNote({required this.con});
  final PhysioController con;

  // Neutral ash/grey — an informational note, not a warning, so it
  // shouldn't compete with the center's own accent color (which the rest
  // of this page uses for anything actionable).
  static const _ink = Color(0xFF64748B);
  static const _bg = Color(0xFFF1F5F9);

  @override
  Widget build(BuildContext context) {
    final homeTotal = con.cartTotalFor('home');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: _ink),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${'Switching to Home visit changes the price to'.tr} ৳$homeTotal — ${'home visits include the therapist\'s travel cost, so the rate can differ from visiting the center.'.tr}',
              style: const TextStyle(fontSize: 11.5, color: _ink, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// A scrollable hour/minute wheel instead of the Material clock dial —
/// easier to use for most people than dragging clock hands.
Future<void> _pickEasyTime(
    BuildContext context, PhysioController con, Color accent) async {
  final today = con.isTodaySelected();
  // Never let the wheel open already parked on a time that's no longer
  // pickable — that reads as "Done did nothing" to the user.
  var initial = con.selectedTimeOfDay;
  if (today && con.isPastTimeOfDay(initial)) {
    initial = con.earliestSelectableTimeToday();
  }
  var temp = initial;
  final now = DateTime.now();
  await showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 6, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select time'.tr,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                  TextButton(
                    onPressed: () {
                      if (con.isTodaySelected() &&
                          con.isPastTimeOfDay(temp)) {
                        SnackHelper.error(
                            'অতীতের সময় বুক করা যাবে না, বর্তমান বা পরবর্তী সময় বেছে নিন');
                        return;
                      }
                      con.selectTime(temp);
                      Navigator.pop(ctx);
                    },
                    child: Text('Done'.tr,
                        style: TextStyle(
                            color: accent, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 216,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(
                    now.year, now.month, now.day, initial.hour, initial.minute),
                use24hFormat: false,
                onDateTimeChanged: (dt) {
                  temp = TimeOfDay(hour: dt.hour, minute: dt.minute);
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.con, required this.accent});
  final PhysioController con;
  final Color accent;

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
          ...con.cartItems.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                          '${e.key.name}${e.value > 1 ? ' × ${e.value}' : ''}',
                          style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A))),
                    ),
                    const SizedBox(width: 8),
                    Text(
                        '৳${e.key.priceFor(con.sessionType == 1 ? 'home' : 'center') * e.value}',
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: accent)),
                  ],
                ),
              )),
          const Divider(height: 1, color: Color(0xFFEDEFF2)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total'.tr,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
              Row(
                children: [
                  if (con.cartHasDiscount) ...[
                    Text('৳${con.cartOriginalTotal}',
                        style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFFEF4444),
                            decoration: TextDecoration.lineThrough)),
                    const SizedBox(width: 6),
                  ],
                  Text('৳${con.cartTotal}',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: con.cartHasDiscount
                              ? const Color(0xFF047857)
                              : accent)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.6));
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.accent,
    required this.tile,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final Color accent;
  final Color tile;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected ? tile : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? accent : const Color(0xFFE2E8F0),
              width: selected ? 1.6 : 1.2),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 24, color: selected ? accent : const Color(0xFF64748B)),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF334155))),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar(
      {required this.total,
      required this.onTap,
      required this.accent,
      this.loading = false});
  final int total;
  final VoidCallback onTap;
  final Color accent;
  final bool loading;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total'.tr,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              Text('৳$total',
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: loading ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: Colors.white),
                    )
                  : Text('Confirm booking'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
