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
const _ink = Color(0xFF0F172A);
const _muted = Color(0xFF94A3B8);
const _line = Color(0xFFE9EDF2);

String _mediaUrl(String path) {
  if (path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  final base = AppConfig.baseUrl.endsWith('/')
      ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
      : AppConfig.baseUrl;
  return path.startsWith('/') ? '$base$path' : '$base/$path';
}

/// "Our Work" — newspaper-style video showcase: top category nav, a featured
/// latest video, then a list of title + thumbnail rows. GET /api/v1/works/posts.
class WorksView extends GetView<WorksController> {
  const WorksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            const Divider(height: 1, color: _line),
            GetBuilder<WorksController>(
              builder: (con) => _CategoryNav(con: con),
            ),
            const Divider(height: 1, color: _line),
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
                                      style: const TextStyle(color: _muted),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : _WorksFeed(con: con),
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

// ── Feed: featured latest video + list rows ──────────────────────────
class _WorksFeed extends StatelessWidget {
  const _WorksFeed({required this.con});
  final WorksController con;

  @override
  Widget build(BuildContext context) {
    final posts = con.posts;
    final featured = posts.first;
    final rest = posts.length > 1 ? posts.sublist(1) : const <WorkPost>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        FadeInUp(
          from: 18,
          duration: const Duration(milliseconds: 350),
          child: GestureDetector(
            onTap: () => con.openPost(featured),
            child: _FeaturedCard(post: featured),
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < rest.length; i++) ...[
          const Divider(height: 1, color: _line),
          FadeInUp(
            from: 14,
            duration: const Duration(milliseconds: 320),
            delay: Duration(milliseconds: 40 * i),
            child: GestureDetector(
              onTap: () => con.openPost(rest[i]),
              child: _WorkRow(post: rest[i]),
            ),
          ),
        ],
        if (con.loadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2.4, color: _teal),
            ),
          ),
      ],
    );
  }
}

// ── Top category navigation (underline tabs) ─────────────────────────
class _CategoryNav extends StatelessWidget {
  const _CategoryNav({required this.con});
  final WorksController con;

  @override
  Widget build(BuildContext context) {
    if (con.loadingCategories && con.categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SnChipsSkeleton(count: 4),
        ),
      );
    }
    if (con.categories.isEmpty) return const SizedBox(height: 4);
    final labels = ['All'.tr, ...con.categories.map((c) => c.name)];
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (_, i) {
          final sel = con.categoryIndex == i;
          return GestureDetector(
            onTap: () => con.setCategory(i),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: sel ? _teal : Colors.transparent,
                    width: 2.6,
                  ),
                ),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                  color: sel ? _ink : _muted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Featured card: big thumbnail, play button, title & date overlaid ─
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.post});
  final WorkPost post;

  @override
  Widget build(BuildContext context) {
    final img = _mediaUrl(post.thumbnailUrl);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            img.isEmpty
                ? Container(
                    color: const Color(0xFFE0F2FE),
                    alignment: Alignment.center,
                    child: const Icon(Icons.videocam_rounded,
                        color: _teal, size: 48),
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
                          color: _teal, size: 48),
                    ),
                  ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Color(0xCC000000),
                    Color(0xF2000000),
                  ],
                  stops: [0.0, 0.42, 0.78, 1.0],
                ),
              ),
            ),
            // Center play button
            Center(
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.9), width: 2),
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 38),
              ),
            ),
            if (post.provider.isNotEmpty)
              Positioned(
                  top: 12, left: 12, child: _ProviderBadge(post.provider)),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    post.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      height: 1.22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (post.dateLabel.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 12.5, color: Colors.white70),
                        const SizedBox(width: 5),
                        Text(
                          post.dateLabel,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── List row: title + meta on the left, thumbnail (with play) right ──
class _WorkRow extends StatelessWidget {
  const _WorkRow({required this.post});
  final WorkPost post;

  @override
  Widget build(BuildContext context) {
    final img = _mediaUrl(post.thumbnailUrl);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.categoryName.isNotEmpty) ...[
                  Text(
                    post.categoryName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: _teal,
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
                Text(
                  post.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16.5,
                    height: 1.28,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                if (post.dateLabel.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 12, color: _muted),
                      const SizedBox(width: 5),
                      Text(
                        post.dateLabel,
                        style: const TextStyle(fontSize: 11.5, color: _muted),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 118,
              height: 88,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  img.isEmpty
                      ? Container(
                          color: const Color(0xFFE0F2FE),
                          alignment: Alignment.center,
                          child: const Icon(Icons.videocam_rounded,
                              color: _teal, size: 26),
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
                                color: _teal, size: 26),
                          ),
                        ),
                  // Small play affordance
                  Center(
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.9),
                            width: 1.5),
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
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
                  fontSize: 19, fontWeight: FontWeight.w800, color: _ink)),
        ],
      ),
    );
  }
}
