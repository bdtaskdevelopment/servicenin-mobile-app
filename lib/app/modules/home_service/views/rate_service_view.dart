import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/home_service_controller.dart';

const _teal = Color(0xFF0E9F8E);
const _darkTeal = Color(0xFF0E7C6B);
const _tile = Color(0xFFCDEDE6);

class RateServiceView extends StatefulWidget {
  const RateServiceView({super.key});

  @override
  State<RateServiceView> createState() => _RateServiceViewState();
}

class _RateServiceViewState extends State<RateServiceView> {
  int rating = 5;
  final Set<String> selectedTags = {'On time', 'Professional'};
  final TextEditingController _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  static const _ratingLabels = {
    1: 'Poor',
    2: 'Fair',
    3: 'Good',
    4: 'Very good',
    5: 'Excellent',
  };
  static const _tags = [
    'On time', 'Professional', 'Tidy work', 'Fair price', 'Polite', 'Skilled',
  ];

  @override
  Widget build(BuildContext context) {
    final con = Get.find<HomeServiceController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
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
                      Text('Rate service',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      Text('SB-5510',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    splashRadius: 22,
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF1A1A1A)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                              color: _tile, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text(con.techInitials,
                              style: const TextStyle(
                                  color: _darkTeal,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(height: 10),
                        Text(con.techName,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 2),
                        const Text('AC General Service · 1h 12m',
                            style: TextStyle(
                                fontSize: 12.5, color: Color(0xFF0E9F8E))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        const Text('HOW WAS IT?',
                            style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 0.6)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            final active = i < rating;
                            return GestureDetector(
                              onTap: () => setState(() => rating = i + 1),
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                    color: const Color(0xFFFFF3D6),
                                    shape: BoxShape.circle),
                                child: Icon(Icons.star_rounded,
                                    size: 26,
                                    color: active
                                        ? const Color(0xFF1A1A1A)
                                        : const Color(0xFFE2D9B8)),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
                        Text(_ratingLabels[rating]!,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('WHAT WENT WELL?',
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.6)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _tags.map((t) {
                      final sel = selectedTags.contains(t);
                      return GestureDetector(
                        onTap: () => setState(() {
                          sel ? selectedTags.remove(t) : selectedTags.add(t);
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: sel
                                ? _teal.withValues(alpha: 0.12)
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: sel
                                    ? _teal
                                    : const Color(0xFFE2E8F0)),
                          ),
                          child: Text(sel ? '✓ $t' : t,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: sel
                                      ? _darkTeal
                                      : const Color(0xFF334155))),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  const Text('COMMENT (OPTIONAL)',
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.6)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: TextField(
                      controller: _comment,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Tell others about your experience…',
                        hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    final tagNote = selectedTags.join(', ');
                    final comment = [
                      _comment.text.trim(),
                      if (tagNote.isNotEmpty) '($tagNote)',
                    ].where((s) => s.isNotEmpty).join(' ');
                    final ok = await con.submitRating(rating, comment);
                    if (ok) con.backToHomeService();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _darkTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Submit rating',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
