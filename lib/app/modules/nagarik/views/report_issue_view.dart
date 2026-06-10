import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/nagarik_controller.dart';

const _orange = Color(0xFFF15A24);
const _tile = Color(0xFFFCE6CB);

class ReportIssueView extends GetView<NagarikController> {
  const ReportIssueView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<NagarikController>(
          builder: (con) => Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      splashRadius: 22,
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: Color(0xFF1A1A1A)),
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Report an issue',
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        SizedBox(height: 1),
                        Text('Goes directly to DNCC',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                  children: [
                    const _Label('CATEGORY'),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.15,
                      children: con.categories.map((c) {
                        final sel = con.selectedCategoryKey == c.key;
                        return GestureDetector(
                          onTap: () => con.setCategoryKey(c.key),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: sel ? _tile : AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: sel
                                      ? _orange
                                      : const Color(0xFFE2E8F0),
                                  width: sel ? 1.6 : 1.2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(nagarikCategoryIcon(c.icon),
                                    size: 24,
                                    color: sel
                                        ? _orange
                                        : const Color(0xFF334155)),
                                const SizedBox(height: 8),
                                Text(c.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: sel
                                            ? const Color(0xFF0F172A)
                                            : const Color(0xFF334155))),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    const _Label('TITLE'),
                    const SizedBox(height: 10),
                    _Input(
                        controller: con.reportTitle,
                        hint: 'Short summary, e.g. Blocked drain on Road 7'),
                    const SizedBox(height: 18),
                    const _Label('DESCRIBE THE ISSUE'),
                    const SizedBox(height: 10),
                    _Input(
                        controller: con.reportDescription,
                        hint: 'What\'s wrong, how long it\'s been there…',
                        maxLines: 4),
                    const SizedBox(height: 18),
                    const _Label('LOCATION'),
                    const SizedBox(height: 10),
                    _Input(
                        controller: con.reportAddress,
                        hint: 'Address, e.g. Road 7, Dhanmondi'),
                    const SizedBox(height: 12),
                    _Input(
                        controller: con.reportWard,
                        hint: 'Ward no (optional), e.g. 14',
                        keyboard: TextInputType.number),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const _Label('PHOTO EVIDENCE'),
                        const SizedBox(width: 8),
                        Text(
                            '(${con.reportImages.length}/${NagarikController.maxReportImages})',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB0B6C0))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _PhotoEvidence(con: con),
                    const SizedBox(height: 18),
                    const _Label('PRIORITY'),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(con.priorities.length, (i) {
                        final sel = con.priorityIndex == i;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: i == con.priorities.length - 1 ? 0 : 10),
                            child: GestureDetector(
                              onTap: () => con.setPriority(i),
                              child: Container(
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: sel ? _tile : AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: sel
                                          ? _orange
                                          : const Color(0xFFE2E8F0),
                                      width: sel ? 1.6 : 1.2),
                                ),
                                child: Text(con.priorities[i]['label']!,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: sel
                                            ? _orange
                                            : const Color(0xFF334155))),
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
                    onPressed:
                        con.submittingReport ? null : con.submitReport,
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
                        : const Text('Submit to DNCC',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
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

class _PhotoEvidence extends StatelessWidget {
  const _PhotoEvidence({required this.con});
  final NagarikController con;

  @override
  Widget build(BuildContext context) {
    final images = con.reportImages;
    final canAdd = images.length < NagarikController.maxReportImages;
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length + (canAdd ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          if (i == images.length) {
            // Add tile
            return GestureDetector(
              onTap: con.pickReportImages,
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFFCBD5E1),
                      width: 1.2,
                      strokeAlign: BorderSide.strokeAlignInside),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined,
                        color: _orange, size: 24),
                    SizedBox(height: 6),
                    Text('Add photo',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155))),
                  ],
                ),
              ),
            );
          }
          return Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  images[i],
                  width: 92,
                  height: 92,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: -6,
                top: -6,
                child: GestureDetector(
                  onTap: () => con.removeReportImage(i),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
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

class _Input extends StatelessWidget {
  const _Input({
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        style: const TextStyle(fontSize: 14.5, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          isCollapsed: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: InputBorder.none,
          hintText: hint,
          hintStyle:
              const TextStyle(fontSize: 14.5, color: Color(0xFFB8C0CC)),
        ),
      ),
    );
  }
}
