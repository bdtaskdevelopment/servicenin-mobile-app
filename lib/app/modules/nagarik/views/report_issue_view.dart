import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/nagarik_controller.dart';
import 'nagarik_view.dart' show SupportIconButton;

const _green = Color(0xFF15803C);
const _greenLight = Color(0xFFE9F5ED);
const _orange = Color(0xFFF16621);
const _navy = Color(0xFF0F172A);
const _sub = Color(0xFF94A3B8);

class ReportIssueView extends GetView<NagarikController> {
  const ReportIssueView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body: SafeArea(
        child: GetBuilder<NagarikController>(
          builder: (con) => Column(
            children: [
              // Header
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      splashRadius: 22,
                      onPressed: () => Get.back(),
                      icon: const Icon(LucideIcons.chevronLeft,
                          size: 22, color: _navy),
                    ),
                    Text('Report an issue'.tr,
                        style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: _navy)),
                    const Spacer(),
                    SupportIconButton(con: con),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                  children: [
                    _Label('Category'.tr),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.0,
                      children: con.categories.map((c) {
                        final sel = con.selectedCategoryKey == c.key;
                        final (bg, fg) = nagarikCategoryColor(c.key);
                        return GestureDetector(
                          onTap: () => con.setCategoryKey(c.key),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: sel ? _greenLight : AppColors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: sel
                                          ? _green
                                          : const Color(0xFFEDEFF2),
                                      width: sel ? 1.6 : 1),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: bg,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Icon(nagarikCategoryIcon(c.key),
                                          size: 20, color: fg),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(c.displayLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: _navy)),
                                  ],
                                ),
                              ),
                              if (sel)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: AppColors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(LucideIcons.circleCheck,
                                        size: 18, color: _green),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    _Label('Title'.tr),
                    const SizedBox(height: 10),
                    _Input(
                        controller: con.reportTitle,
                        hint: 'Short summary, e.g. Blocked drain on Road 7'.tr,
                        icon: LucideIcons.type),
                    const SizedBox(height: 18),
                    _Label('Describe the issue'.tr),
                    const SizedBox(height: 10),
                    _Input(
                        controller: con.reportDescription,
                        hint: 'What\'s wrong, how long it\'s been there…'.tr,
                        maxLines: 4),
                    const SizedBox(height: 18),
                    _Label('Location'.tr),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _Input(
                              controller: con.reportAddress,
                              hint: 'Address, e.g. Road 7, Dhanmondi'.tr,
                              icon: LucideIcons.mapPin),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: con.pickAddress,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(LucideIcons.search,
                                color: Colors.white, size: 19),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _WardField(con: con),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _Label('Photos (as proof)'.tr),
                        const SizedBox(width: 6),
                        Text(
                            '(${con.reportImages.length}/${NagarikController.maxReportImages}${' photos'.tr})',
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: _sub)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _PhotoEvidence(con: con),
                    const SizedBox(height: 18),
                    _Label('PRIORITY', caps: true),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(con.priorities.length, (i) {
                        final sel = con.priorityIndex == i;
                        final style = _priorityStyle(i);
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: i == con.priorities.length - 1 ? 0 : 10),
                            child: GestureDetector(
                              onTap: () => con.setPriority(i),
                              child: Container(
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: sel ? style.solid : style.tint,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color:
                                            sel ? Colors.white : style.solid,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      con.priorities[i]['label']!.toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: sel
                                              ? Colors.white
                                              : style.solid),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              // Submit
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: con.submittingReport ? null : con.submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: con.submittingReport
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.4, color: Colors.white),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.send, size: 18),
                              const SizedBox(width: 10),
                              Text('Submit your Issue'.tr,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
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

class _PriorityStyle {
  const _PriorityStyle(this.tint, this.solid);
  final Color tint;
  final Color solid;
}

_PriorityStyle _priorityStyle(int i) {
  switch (i) {
    case 0: // Low
      return const _PriorityStyle(Color(0xFFE9F1FD), Color(0xFF1D6FD9));
    case 2: // Urgent
      return const _PriorityStyle(Color(0xFFFFEFEF), Color(0xFFE4484D));
    default: // Medium
      return const _PriorityStyle(Color(0xFFFEF3C7), Color(0xFFB86E00));
  }
}

class _WardField extends StatelessWidget {
  const _WardField({required this.con});
  final NagarikController con;

  @override
  Widget build(BuildContext context) {
    final ward = con.selectedWard;
    return GestureDetector(
      onTap: () => _showWardPicker(context, con),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2)),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.landmark, size: 18, color: _sub),
            const SizedBox(width: 10),
            Expanded(
              child: ward == null
                  ? RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: 'Select ward number'.tr,
                              style: const TextStyle(
                                  fontSize: 14.5, color: Color(0xFFB8C0CC))),
                          const TextSpan(
                              text: ' *',
                              style: TextStyle(
                                  fontSize: 14.5,
                                  color: Color(0xFFE4484D),
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    )
                  : Text(
                      '${'Ward'.tr} $ward',
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: _navy),
                    ),
            ),
            const Icon(LucideIcons.chevronDown, size: 18, color: _sub),
          ],
        ),
      ),
    );
  }
}

void _showWardPicker(BuildContext context, NagarikController con) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _WardPickerSheet(con: con),
  );
}

class _WardPickerSheet extends StatefulWidget {
  const _WardPickerSheet({required this.con});
  final NagarikController con;

  @override
  State<_WardPickerSheet> createState() => _WardPickerSheetState();
}

class _WardPickerSheetState extends State<_WardPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wards = NagarikController.dnccWards
        .where((w) => _query.isEmpty || w.toString().contains(_query))
        .toList();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: 14 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Select ward number'.tr,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _navy)),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                        color: Color(0xFFF1F2F7), shape: BoxShape.circle),
                    child: const Icon(LucideIcons.x, size: 16, color: _navy),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
                '${NagarikController.wardCorporationName.tr} · ${NagarikController.dnccWards.length}${' wards'.tr}',
                style: const TextStyle(fontSize: 12.5, color: _sub)),
            const SizedBox(height: 14),
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.search, size: 17, color: _sub),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (v) => setState(() => _query = v.trim()),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: 'Search ward number'.tr,
                        hintStyle:
                            const TextStyle(fontSize: 14, color: _sub),
                      ),
                      style: const TextStyle(fontSize: 14, color: _navy),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: wards.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text('No matching places found.'.tr,
                          style:
                              const TextStyle(fontSize: 13.5, color: _sub)),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(bottom: 4),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemCount: wards.length,
                      itemBuilder: (_, i) {
                        final w = wards[i];
                        final sel = widget.con.selectedWard == w;
                        return GestureDetector(
                          onTap: () {
                            widget.con.setWard(w);
                            Get.back();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: sel ? _green : const Color(0xFFF4F5FA),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$w',
                              style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: sel ? Colors.white : _navy),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoEvidence extends StatelessWidget {
  const _PhotoEvidence({required this.con});
  final NagarikController con;

  @override
  Widget build(BuildContext context) {
    final images = con.reportImages;
    final max = NagarikController.maxReportImages;
    return Row(
      children: List.generate(max, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == max - 1 ? 0 : 12),
            child: _PhotoSlot(con: con, index: i, hasImage: i < images.length),
          ),
        );
      }),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot(
      {required this.con, required this.index, required this.hasImage});
  final NagarikController con;
  final int index;
  final bool hasImage;

  @override
  Widget build(BuildContext context) {
    if (hasImage) {
      final file = con.reportImages[index];
      return AspectRatio(
        aspectRatio: 1,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(file, fit: BoxFit.cover, width: double.infinity),
            ),
            Positioned(
              right: -6,
              top: -6,
              child: GestureDetector(
                onTap: () => con.removeReportImage(index),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(LucideIcons.x,
                      size: 13, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }
    final isNextAdd = index == con.reportImages.length;
    if (isNextAdd) {
      return GestureDetector(
        onTap: con.pickReportImages,
        child: AspectRatio(
          aspectRatio: 1,
          child: DottedBorderBox(
            color: _green,
            borderRadius: 14,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.imagePlus, color: _green, size: 20),
                const SizedBox(height: 4),
                Text('Add photo'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: _green)),
              ],
            ),
          ),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2)),
        ),
      ),
    );
  }
}

/// A lightweight dashed-border box (no extra package) used for the "add
/// photo" tile so it reads as a drop target, matching the mockup.
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox(
      {super.key,
      required this.child,
      required this.color,
      this.borderRadius = 14});
  final Widget child;
  final Color color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: color, radius: borderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4FAF6),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
        Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    const dashWidth = 5.0;
    const dashGap = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
            metric.extractPath(distance, next.clamp(0, metric.length)),
            paint);
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.caps = false});
  final String text;
  final bool caps;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: caps
            ? const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _sub,
                letterSpacing: 0.6)
            : const TextStyle(
                fontSize: 14.5, fontWeight: FontWeight.w800, color: _navy),
      );
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.icon,
  });
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Row(
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Padding(
              padding: EdgeInsets.only(top: maxLines > 1 ? 10 : 0),
              child: Icon(icon, size: 17, color: _sub),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              style: const TextStyle(fontSize: 14.5, color: _navy),
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFB8C0CC)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
