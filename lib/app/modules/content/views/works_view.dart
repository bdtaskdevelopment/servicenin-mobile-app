import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_config.dart';
import '../../../data/models/response/content_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/works_controller.dart';

const _teal = Color(0xFF0891B2);

String _mediaUrl(String path) {
  if (path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  final base = AppConfig.baseUrl.endsWith('/')
      ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
      : AppConfig.baseUrl;
  return path.startsWith('/') ? '$base$path' : '$base/$path';
}

/// "Our Work" — video showcase list from GET /api/v1/works/posts.
class WorksView extends GetView<WorksController> {
  const WorksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            const SizedBox(height: 12),
            GetBuilder<WorksController>(
              builder: (con) => _CategoryChips(con: con),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GetBuilder<WorksController>(
                builder: (con) {
                  if (con.loading && con.posts.isEmpty) {
                    return const SnListSkeleton();
                  }
                  return RefreshIndicator(
                    color: _teal,
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
                                      'No posts yet — check back soon.'.tr,
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
                                          child: _WorkCard(post: e.value),
                                        ),
                                      ),
                                    )),
                                if (con.loadingMore)
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 12),
                                    child: Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.4, color: _teal)),
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
  final WorksController con;

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
                color: sel ? _teal : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: sel ? _teal : const Color(0xFFE2E8F0)),
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
          Text('Our Work'.tr,
              style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}

// ── Work card: big 16:9 video thumbnail + play + provider, then title ──
class _WorkCard extends StatelessWidget {
  const _WorkCard({required this.post});
  final WorkPost post;

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
          // Big video thumbnail
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                img.isEmpty
                    ? Container(
                        color: const Color(0xFFE0F2FE),
                        alignment: Alignment.center,
                        child: const Icon(Icons.videocam_rounded,
                            color: _teal, size: 44),
                      )
                    : CachedNetworkImage(
                        imageUrl: img,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: const Color(0xFFF1F5F9)),
                        errorWidget: (_, __, ___) => Container(
                          color: const Color(0xFFE0F2FE),
                          alignment: Alignment.center,
                          child: const Icon(Icons.videocam_rounded,
                              color: _teal, size: 44),
                        ),
                      ),
                // Legibility gradient at the bottom.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black26],
                    ),
                  ),
                ),
                // Center play button.
                Center(
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                          width: 2),
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 36),
                  ),
                ),
                // Provider badge (YouTube / Facebook).
                if (post.provider.isNotEmpty)
                  Positioned(
                      top: 10, left: 10, child: _ProviderBadge(post.provider)),
              ],
            ),
          ),
          // Title + meta
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (post.categoryName.isNotEmpty)
                      Flexible(child: _Pill(post.categoryName, _teal)),
                    const Spacer(),
                    if (post.dateLabel.isNotEmpty) ...[
                      const Icon(Icons.calendar_today_outlined,
                          size: 12, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(post.dateLabel,
                          style: const TextStyle(
                              fontSize: 11.5, color: Color(0xFF94A3B8))),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Provider badge overlaid on the thumbnail ─────────────────────────
class _ProviderBadge extends StatelessWidget {
  const _ProviderBadge(this.provider);
  final String provider;

  @override
  Widget build(BuildContext context) {
    final p = provider.toLowerCase();
    Color color;
    String label;
    if (p.contains('youtube')) {
      color = const Color(0xFFFF0000);
      label = 'YouTube';
    } else if (p.contains('facebook')) {
      color = const Color(0xFF1877F2);
      label = 'Facebook';
    } else {
      color = const Color(0xFF334155);
      label = provider;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_circle_fill_rounded,
              color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ── Small pill/badge (category, provider) ────────────────────────────
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
