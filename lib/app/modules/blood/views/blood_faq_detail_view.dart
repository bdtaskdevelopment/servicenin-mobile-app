import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_config.dart';
import '../controllers/blood_faq_controller.dart';

const _red = Color(0xFFE11D48);

String _mediaUrl(String path) {
  if (path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  final base = AppConfig.baseUrl.endsWith('/')
      ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
      : AppConfig.baseUrl;
  return path.startsWith('/') ? '$base$path' : '$base/$path';
}

/// Full FAQ answer — opened from [BloodFaqView]. The list response already
/// carries the full answer, so this just displays [BloodFaqController.selected].
class BloodFaqDetailView extends GetView<BloodFaqController> {
  const BloodFaqDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<BloodFaqController>(
          builder: (con) {
            final f = con.selected;
            if (f == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final img = _mediaUrl(f.imageUrl);
            return ListView(
              padding: const EdgeInsets.fromLTRB(8, 6, 20, 32),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    splashRadius: 22,
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: Color(0xFF1A1A1A)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (img.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: CachedNetworkImage(
                                imageUrl: img,
                                fit: BoxFit.cover,
                                placeholder: (_, u) => Container(
                                    color: const Color(0xFFF1F5F9)),
                                errorWidget: (_, u, e) => Container(
                                    color: const Color(0xFFF1F5F9)),
                              ),
                            ),
                          ),
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDE4E4),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(Icons.help_outline_rounded,
                                color: _red, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(f.question,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    height: 1.35)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(f.answer,
                          style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF334155),
                              height: 1.6)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
