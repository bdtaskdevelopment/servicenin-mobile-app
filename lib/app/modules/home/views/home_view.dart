import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/service_nav.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/values/app_config.dart';
import '../../../core/values/sn_catalog.dart';
import '../../../data/models/response/home_response.dart';
import '../../../global_widget/section_header.dart';
import '../../../global_widget/service_app_bar.dart';
import '../../../global_widget/sn_service_tile.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const ServiceAppBar(),
      body: GetBuilder<HomeController>(
        builder: (con) {
          return RefreshIndicator(
            color: AppColors.brandOrange,
            onRefresh: con.refreshAll,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                const SizedBox(height: 8),
                _BannerCarousel(con: con),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SectionHeader(
                      title: 'All Services'.tr,
                      actionLabel: 'See All →'.tr,
                      onAction: () => Get.toNamed('/search')),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: SnCatalog.services.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.86,
                    ),
                    itemBuilder: (_, i) => SnServiceTile(
                      service: SnCatalog.services[i],
                      onTap: () => ServiceNav.open(SnCatalog.services[i]),
                    ),
                  ),
                ),
                // ── Popular services ──────────────────────────────
                if (con.loadingPopular || con.popular.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SectionHeader(title: 'Popular Services'.tr),
                  ),
                  const SizedBox(height: 12),
                  if (con.popular.isEmpty)
                    const SnStripSkeleton(height: 120, itemWidth: 156)
                  else
                    FadeInUp(
                      from: 18,
                      duration: const Duration(milliseconds: 350),
                      child: _ServiceStrip(services: con.popular),
                    ),
                ],
                // ── Recent services ───────────────────────────────
                if (con.loadingRecent || con.recent.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SectionHeader(title: 'Recent Services'.tr),
                  ),
                  const SizedBox(height: 12),
                  if (con.recent.isEmpty)
                    const SnStripSkeleton(height: 120, itemWidth: 156)
                  else
                    FadeInUp(
                      from: 18,
                      duration: const Duration(milliseconds: 350),
                      child: _ServiceStrip(services: con.recent),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Banner carousel (driven by /api/v1/home/banners, auto-scrolls) ──
class _BannerCarousel extends StatelessWidget {
  const _BannerCarousel({required this.con});
  final HomeController con;

  @override
  Widget build(BuildContext context) {
    if (con.loadingBanners && con.banners.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: SnShimmer(
          child: SnBone(
            width: double.infinity,
            height: 150,
            radius: 20,
          ),
        ),
      );
    }
    if (con.banners.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: con.bannerController,
            itemCount: con.banners.length,
            onPageChanged: con.setPromo,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _BannerSlide(
                banner: con.banners[i],
                onTap: () => con.openBanner(con.banners[i]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(con.banners.length, (i) {
            final active = con.promoIndex == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.brandOrange
                    : const Color(0xFFD8DEE6),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

const _bannerGradients = <String, List<Color>>{
  'healthcare': [Color(0xFF0F7A52), Color(0xFF0B5E3F)],
  'ambulance': [Color(0xFFF15A24), Color(0xFFE14E14)],
  'blood': [Color(0xFFD7263D), Color(0xFFA61B2B)],
  'services': [Color(0xFF12877A), Color(0xFF0C6157)],
  'home_service': [Color(0xFF12877A), Color(0xFF0C6157)],
  'physio': [Color(0xFF7C3AED), Color(0xFF5B21B6)],
  'matchmaking': [Color(0xFFDB2777), Color(0xFFA21457)],
  'jobs': [Color(0xFF2563EB), Color(0xFF1D4ED8)],
  'education': [Color(0xFFEA9A0B), Color(0xFFB45309)],
  'nagarik': [Color(0xFF1E2A4A), Color(0xFF2D3E63)],
};

String _bannerImageUrl(String path) {
  if (path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  final base = AppConfig.baseUrl.endsWith('/')
      ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
      : AppConfig.baseUrl;
  return path.startsWith('/') ? '$base$path' : '$base/$path';
}

class _BannerSlide extends StatelessWidget {
  const _BannerSlide({required this.banner, required this.onTap});
  final HomeBanner banner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = _bannerGradients[banner.type] ??
        const [Color(0xFF0F7A52), Color(0xFF0B5E3F)];
    final img = _bannerImageUrl(banner.imageUrl);
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background — the banner image (full), with a brand gradient as
            // the fallback while loading or on error.
            if (img.isNotEmpty)
              Image.network(
                img,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _gradientBox(colors),
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : _gradientBox(colors),
              )
            else
              _gradientBox(colors),
            // Dark scrim so the white title/subtitle stay readable over photos.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xB3000000), Color(0x40000000)],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (banner.title.isNotEmpty)
                    Text(banner.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            height: 1.15)),
                  const SizedBox(height: 4),
                  if (banner.subtitle.isNotEmpty)
                    Text(banner.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('View →',
                            style: TextStyle(
                                color: colors.first,
                                fontSize: 12,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientBox(List<Color> colors) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );
}

// ── Horizontal service shortcut strip (popular / recent) ────────────
class _ServiceStrip extends StatelessWidget {
  const _ServiceStrip({required this.services});
  final List<HomeService> services;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: services.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _ServiceCard(service: services[i]),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});
  final HomeService service;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ServiceNav.openByKey(service.key),
      child: Container(
        width: 156,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: service.color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: service.color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(service.iconData, color: service.color, size: 21),
            ),
            const SizedBox(height: 10),
            Text(service.name.tr,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A))),
          ],
        ),
      ),
    );
  }
}
