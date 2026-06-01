import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/sn_catalog.dart';
import '../../../data/models/sn_service.dart';
import '../../../global_widget/section_header.dart';
import '../../../global_widget/service_app_bar.dart';
import '../../../global_widget/sn_service_tile.dart';
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
          return ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              const SizedBox(height: 8),
              _PromoCarousel(con: con),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader(
                    title: 'All Services',
                    actionLabel: 'See All →',
                    onAction: () {}),
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
                  itemBuilder: (_, i) =>
                      SnServiceTile(service: SnCatalog.services[i]),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader(
                    title: 'Recent Services',
                    actionLabel: 'See All →',
                    onAction: () {}),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 116,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: con.recent.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _RecentCard(item: con.recent[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Promo carousel ──────────────────────────────────────────────────
class _PromoCarousel extends StatelessWidget {
  const _PromoCarousel({required this.con});
  final HomeController con;

  static const _slides = [
    _PromoData(
      tag: 'LIMITED · 7 DAYS LEFT',
      title: '20% off your first doctor visit',
      subtitle: 'Verified BMDC doctors across Dhaka. Use code SN20.',
      hotline: '16263',
      action: 'Find a doctor →',
      colors: [Color(0xFF0F7A52), Color(0xFF0B5E3F)],
    ),
    _PromoData(
      tag: 'AMBULANCE · 24/7',
      title: 'Emergency ambulance in minutes',
      subtitle: 'Nearest verified ambulance, live tracking.',
      hotline: '16121',
      action: 'Book now →',
      colors: [Color(0xFFF15A24), Color(0xFFE14E14)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.92),
            itemCount: _slides.length,
            onPageChanged: con.setPromo,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _PromoSlide(data: _slides[i]),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (i) {
            final active = con.promoIndex == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? AppColors.brandOrange : const Color(0xFFD8DEE6),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _PromoData {
  const _PromoData({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.hotline,
    required this.action,
    required this.colors,
  });
  final String tag;
  final String title;
  final String subtitle;
  final String hotline;
  final String action;
  final List<Color> colors;
}

class _PromoSlide extends StatelessWidget {
  const _PromoSlide({required this.data});
  final _PromoData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(Icons.medical_services_outlined,
                size: 96, color: Colors.white.withValues(alpha: 0.12)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(data.tag,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
              ),
              const SizedBox(height: 8),
              Text(data.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.15)),
              const SizedBox(height: 4),
              Text(data.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11.5)),
              const Spacer(),
              Row(
                children: [
                  _pill(Icons.call_rounded, data.hotline, false),
                  const SizedBox(width: 10),
                  _pill(null, data.action, true),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(IconData? icon, String label, bool solid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: solid ? Colors.white : Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 5),
          ],
          Text(label,
              style: TextStyle(
                  color: solid ? const Color(0xFF0F172A) : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ── Recent service card ─────────────────────────────────────────────
class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.item});
  final RecentService item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(item.icon, color: item.color, size: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(item.status,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: item.color)),
              ),
            ],
          ),
          const Spacer(),
          Text(item.title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(item.subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
          const SizedBox(height: 6),
          Text(item.time,
              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}
