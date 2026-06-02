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
                      childAspectRatio: 1.25,
                      children: List.generate(con.issueCategories.length, (i) {
                        final sel = con.categoryIndex == i;
                        return GestureDetector(
                          onTap: () => con.setCategory(i),
                          child: Container(
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
                                Icon(con.issueIcons[i],
                                    size: 24,
                                    color: sel
                                        ? _orange
                                        : const Color(0xFF334155)),
                                const SizedBox(height: 8),
                                Text(con.issueCategories[i],
                                    style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: sel
                                            ? const Color(0xFF0F172A)
                                            : const Color(0xFF334155))),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                    const _Label('PHOTO EVIDENCE'),
                    const SizedBox(height: 10),
                    DottedBox(
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                                color: _tile,
                                borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.photo_camera_outlined,
                                color: _orange, size: 26),
                          ),
                          const SizedBox(height: 10),
                          const Text('Tap to add photo',
                              style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF334155))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _Label('LOCATION'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: const Color(0xFFEDEFF2))),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                                color: _tile,
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.location_on_outlined,
                                color: _orange, size: 21),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Road 27, Banani · Ward 19',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A))),
                                SizedBox(height: 2),
                                Text('GPS pinned · auto-routed to ward officer',
                                    style: TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF94A3B8))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.circle,
                                    size: 7, color: Color(0xFF16A34A)),
                                SizedBox(width: 4),
                                Text('GPS',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF15803D))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _Label('DESCRIBE THE ISSUE'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: const Color(0xFFEDEFF2))),
                      child: const TextField(
                        maxLines: 4,
                        style: TextStyle(
                            fontSize: 14.5, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                          border: InputBorder.none,
                          hintText:
                              'What\'s wrong, how long has it been there…',
                          hintStyle: TextStyle(
                              fontSize: 14.5, color: Color(0xFFB8C0CC)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: List.generate(3, (i) {
                        const labels = ['Low', 'Medium', 'Urgent'];
                        final sel = con.priorityIndex == i;
                        return Expanded(
                          child: Padding(
                            padding:
                                EdgeInsets.only(right: i == 2 ? 0 : 10),
                            child: GestureDetector(
                              onTap: () => con.setPriority(i),
                              child: Container(
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color:
                                      sel ? _tile : AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: sel
                                          ? _orange
                                          : const Color(0xFFE2E8F0),
                                      width: sel ? 1.6 : 1.2),
                                ),
                                child: Text(labels[i],
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
                    onPressed: con.submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Submit to DNCC',
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

class DottedBox extends StatelessWidget {
  const DottedBox({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFCBD5E1),
            width: 1.2,
            strokeAlign: BorderSide.strokeAlignInside),
      ),
      child: child,
    );
  }
}
