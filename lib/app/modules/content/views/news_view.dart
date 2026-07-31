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

/// "Our News" — newspaper-style feed: top category nav, a featured latest
/// post, then a list of title + thumbnail rows. Data: GET /api/v1/news/posts.
class NewsView extends GetView<NewsController> {
  const NewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            const Divider(height: 1, color: _line),
            GetBuilder<NewsController>(
              builder: (con) => _CategoryNav(con: con),
            ),
            const Divider(height: 1, color: _line),
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
                                      style: const TextStyle(color: _muted),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : _NewsFeed(con: con),
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

// ── Feed: featured latest post + list rows ───────────────────────────
class _NewsFeed extends StatelessWidget {
  const _NewsFeed({required this.con});
  final NewsController con;

  @override
  Widget build(BuildContext context) {
    final posts = con.posts;
    final featured = posts.first;
    final rest = posts.length > 1 ? posts.sublist(1) : const <NewsPost>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Featured / latest post
        FadeInUp(
          from: 18,
          duration: const Duration(milliseconds: 350),
          child: GestureDetector(
            onTap: () => con.openPost(featured),
            child: _FeaturedCard(post: featured),
          ),
        ),
        const SizedBox(height: 8),
        // Remaining posts as title + thumbnail rows
        for (var i = 0; i < rest.length; i++) ...[
          const Divider(height: 1, color: _line),
          FadeInUp(
            from: 14,
            duration: const Duration(milliseconds: 320),
            delay: Duration(milliseconds: 40 * i),
            child: GestureDetector(
              onTap: () => con.openPost(rest[i]),
              child: _NewsRow(post: rest[i]),
            ),
          ),
        ],
        if (con.loadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2.4, color: _green),
            ),
          ),
      ],
    );
  }
}

// ── Top category navigation (underline tabs) ─────────────────────────
class _CategoryNav extends StatelessWidget {
  const _CategoryNav({required this.con});
  final NewsController con;

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
                    color: sel ? _green : Colors.transparent,
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

// ── Featured card: big image with title & date overlaid ──────────────
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.post});
  final NewsPost post;

  @override
  Widget build(BuildContext context) {
    final img = _mediaUrl(post.heroImageUrl);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            img.isEmpty
                ? Container(
                    color: const Color(0xFFDCFCE7),
                    alignment: Alignment.center,
                    child: const Icon(Icons.newspaper_rounded,
                        color: _green, size: 48),
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
                          color: _green, size: 48),
                    ),
                  ),
            // Dark gradient for text legibility
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
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (post.categoryName.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: _green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        post.categoryName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  const SizedBox(height: 10),
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

// ── List row: title + meta on the left, thumbnail on the right ───────
class _NewsRow extends StatelessWidget {
  const _NewsRow({required this.post});
  final NewsPost post;

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
                      color: _green,
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
              child: img.isEmpty
                  ? Container(
                      color: const Color(0xFFDCFCE7),
                      alignment: Alignment.center,
                      child: const Icon(Icons.newspaper_rounded,
                          color: _green, size: 26),
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
                            color: _green, size: 26),
                      ),
                    ),
            ),
          ),
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
          Text('Our News'.tr,
              style: const TextStyle(
                  fontSize: 19, fontWeight: FontWeight.w800, color: _ink)),
        ],
      ),
    );
  }
}
