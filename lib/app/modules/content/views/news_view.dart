import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_config.dart';
import '../../../data/models/response/content_response.dart';
import '../../../global_widget/sn_shimmer.dart';
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

/// "Our News" — article list from GET /api/v1/news/posts.
class NewsView extends GetView<NewsController> {
  const NewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            const SizedBox(height: 12),
            GetBuilder<NewsController>(
              builder: (con) => _CategoryChips(con: con),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GetBuilder<NewsController>(
                builder: (con) {
                  if (con.loading && con.posts.isEmpty) {
                    return const SnListSkeleton();
                  }
                  return RefreshIndicator(
                    color: _green,
                    onRefresh: () => con.fetchPosts(reset: true),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n.metrics.pixels >=
                            n.metrics.maxScrollExtent - 200) {
                          con.loadMore();
                        }
                        return false;
                      },
                      child: con.posts.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 80),
                                  child: Center(
                                    child: Text(
                                      'No news yet — check back soon.'.tr,
                                      style: const TextStyle(
                                          color: Color(0xFF94A3B8)),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 24),
                              children: [
                                ...con.posts.asMap().entries.map((e) =>
                                    FadeInUp(
                                      from: 18,
                                      duration:
                                          const Duration(milliseconds: 350),
                                      delay:
                                          Duration(milliseconds: 60 * e.key),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 14),
                                        child: GestureDetector(
                                          onTap: () => con.openPost(e.value),
                                          child: _NewsCard(post: e.value),
                                        ),
                                      ),
                                    )),
                                if (con.loadingMore)
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 12),
                                    child: Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.4, color: _green)),
                                  ),
                              ],
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

// ── Category filter chips ────────────────────────────────────────────
class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.con});
  final NewsController con;

  @override
  Widget build(BuildContext context) {
    if (con.loadingCategories && con.categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SnChipsSkeleton(count: 4),
        ),
      );
    }
    if (con.categories.isEmpty) return const SizedBox.shrink();
    final labels = ['All'.tr, ...con.categories.map((c) => c.name)];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final sel = con.categoryIndex == i;
          return GestureDetector(
            onTap: () => con.setCategory(i),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: sel ? _green : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: sel ? _green : const Color(0xFFE2E8F0)),
              ),
              child: Text(labels[i],
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: sel ? Colors.white : const Color(0xFF334155))),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(8, 6, 12, 10),
      child: Row(
        children: [
          IconButton(
            splashRadius: 22,
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: Color(0xFF1A1A1A)),
          ),
          Text('Our News'.tr,
              style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}

// ── News card: big cover image, then title · excerpt · meta ─────────
class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.post});
  final NewsPost post;

  @override
  Widget build(BuildContext context) {
    final img = _mediaUrl(post.thumbnailUrl);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big cover image
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                img.isEmpty
                    ? Container(
                        color: const Color(0xFFDCFCE7),
                        alignment: Alignment.center,
                        child: const Icon(Icons.newspaper_rounded,
                            color: _green, size: 44),
                      )
                    : CachedNetworkImage(
                        imageUrl: img,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: const Color(0xFFF1F5F9)),
                        errorWidget: (_, __, ___) => Container(
                          color: const Color(0xFFDCFCE7),
                          alignment: Alignment.center,
                          child: const Icon(Icons.newspaper_rounded,
                              color: _green, size: 44),
                        ),
                      ),
                // Category badge overlaid on the image.
                if (post.categoryName.isNotEmpty)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: _green,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 6),
                        ],
                      ),
                      child: Text(post.categoryName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
              ],
            ),
          ),
          // Title + excerpt + date
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16.5,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                if (post.excerpt.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(post.excerpt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: Color(0xFF64748B))),
                ],
                if (post.dateLabel.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 12, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(post.dateLabel,
                          style: const TextStyle(
                              fontSize: 11.5, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small pill/badge (category) ──────────────────────────────────────
class _Pill extends StatelessWidget {
  const _Pill(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
