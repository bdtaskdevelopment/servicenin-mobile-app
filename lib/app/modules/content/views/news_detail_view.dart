import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../core/values/app_config.dart';
import '../controllers/news_controller.dart';

const _green = Color(0xFF16A34A);

String _mediaUrl(String path) {
  if (path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  final base = AppConfig.baseUrl.endsWith('/')
      ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
      : AppConfig.baseUrl;
  return path.startsWith('/') ? '$base$path' : '$base/$path';
}

/// Full "Our News" article — opened from [NewsView], backed by
/// GET /api/v1/news/posts/:id. `body` may contain simple HTML from the admin
/// editor; shown as plain text here (tags stripped) to avoid pulling in a
/// full HTML-rendering dependency for a first pass.
class NewsDetailView extends GetView<NewsController> {
  const NewsDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<NewsController>(
          builder: (con) {
            final p = con.selected;
            if (p == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final img = _mediaUrl(p.heroImageUrl);
            final plainBody =
                p.body.replaceAll(RegExp(r'<[^>]*>'), '').trim();
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      IconButton(
                        splashRadius: 22,
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: Color(0xFF1A1A1A)),
                      ),
                    ],
                  ),
                ),
                if (img.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: CachedNetworkImage(
                            imageUrl: img,
                            fit: BoxFit.cover,
                            placeholder: (_, u) =>
                                Container(color: const Color(0xFFF1F5F9)),
                            errorWidget: (_, u, e) =>
                                Container(color: const Color(0xFFF1F5F9)),
                          ),
                        ),
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.title,
                            style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                height: 1.3)),
                        if (p.dateLabel.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 13, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 6),
                              Text(p.dateLabel,
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ],
                        if (plainBody.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Text(plainBody,
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF334155),
                                  height: 1.6)),
                        ],
                        if (p.externalUrl.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                try {
                                  final ok = await launchUrl(
                                      Uri.parse(p.externalUrl),
                                      mode: LaunchMode.externalApplication);
                                  if (!ok) {
                                    SnackHelper.error('খুলতে সমস্যা হয়েছে');
                                  }
                                } catch (_) {
                                  SnackHelper.error('খুলতে সমস্যা হয়েছে');
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _green,
                                side: const BorderSide(color: _green),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: const Icon(Icons.open_in_new_rounded,
                                  size: 18),
                              label: Text('Read full story'.tr,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                        if (con.loadingDetail) ...[
                          const SizedBox(height: 20),
                          const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: _green),
                            ),
                          ),
                        ],
                      ],
                    ),
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
