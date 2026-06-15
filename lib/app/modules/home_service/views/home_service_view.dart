import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/home_service_controller.dart';

const _teal = Color(0xFF0E9F8E);
const _darkTeal = Color(0xFF0E7C6B);
const _tile = Color(0xFFE0F2EF);

class HomeServiceView extends GetView<HomeServiceController> {
  const HomeServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Home Service'.tr,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 1),
                      Text('Trusted pros · pay after service'.tr,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const Spacer(),
                  // Provider entry hidden for now.
                  // GestureDetector(
                  //   onTap: () => Get.toNamed(Routes.HS_PROVIDER),
                  //   child: const Icon(Icons.work_outline_rounded,
                  //       color: Color(0xFF1A1A1A), size: 22),
                  // ),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<HomeServiceController>(
                builder: (con) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      FadeInDown(
                        duration: const Duration(milliseconds: 300),
                        child: _Hero(),
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: con.openMyBookings,
                        child: const _ActiveCard(),
                      ),
                      const SizedBox(height: 22),
                      GestureDetector(
                        onTap: con.openAll,
                        child: _SectionHeader(
                            title: 'What do you need?'.tr, action: 'All →'.tr),
                      ),
                      const SizedBox(height: 14),
                      if (con.loadingCategories && con.categories.isEmpty)
                        const SnGridSkeleton(
                          count: 8,
                          crossAxisCount: 4,
                          padding: EdgeInsets.zero,
                          childAspectRatio: 0.92,
                        )
                      else
                        FadeInUp(
                          from: 18,
                          duration: const Duration(milliseconds: 350),
                          child: GridView.count(
                            crossAxisCount: 4,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.92,
                            children: con.categories
                                .map((c) => GestureDetector(
                                      onTap: () => con.openCategory(c),
                                      child: _CatTile(cat: c),
                                    ))
                                .toList(),
                          ),
                        ),
                      const SizedBox(height: 20),
                      // Subscriptions section hidden for now.
                      // GestureDetector(
                      //   onTap: con.openSubscriptions,
                      //   child: const _SubscriptionCard(),
                      // ),
                      // const SizedBox(height: 22),
                      Text('Popular this week'.tr,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 12),
                      if (con.loadingPopular && con.popular.isEmpty)
                        const SnListSkeleton(
                          count: 4,
                          padding: EdgeInsets.zero,
                        )
                      else
                        ...con.popular.toList().asMap().entries.map((e) =>
                            FadeInUp(
                              from: 18,
                              duration: const Duration(milliseconds: 350),
                              delay: Duration(milliseconds: 70 * e.key),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () => con.openCategoryById(
                                      e.value.id, e.value.name),
                                  child: _ServiceCard(service: e.value),
                                ),
                              ),
                            )),
                    ],
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

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [_darkTeal, Color(0xFF0B5E52)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -6,
            top: -6,
            child: Icon(Icons.home_repair_service_outlined,
                size: 80, color: Colors.white.withValues(alpha: 0.10)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('All home services, in one place'.tr,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Verified technicians · 7-day warranty · cash or online'.tr,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12.5)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: Get.find<HomeServiceController>().openSearch,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 10),
                      Text('Search AC service, cleaning, plumber…'.tr,
                          style: const TextStyle(
                              color: Color(0xFF94A3B8), fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: _tile, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.receipt_long_rounded,
                color: _teal, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My bookings'.tr,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('Track your service bookings'.tr,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});
  final String title;
  final String action;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A))),
        Text(action,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.brandOrange)),
      ],
    );
  }
}

class _CatTile extends StatelessWidget {
  const _CatTile({required this.cat});
  final HsCategory cat;
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(cat.icon, color: _teal, size: 26),
          const SizedBox(height: 6),
          Flexible(
            child: Text(cat.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155))),
          ),
        ],
      ),
    );
  }
}

// ── Subscriptions navigation card ───────────────────────────────────
// ignore: unused_element
class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1E2A4A), Color(0xFF3A3F8A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.calendar_month_rounded,
                color: Color(0xFFF59E0B), size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Subscriptions',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 2),
                Text('Recurring AC care, weekly cleaning & more',
                    style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _SubscribeBanner extends StatelessWidget {
  const _SubscribeBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1E2A4A), Color(0xFF3A3F8A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.calendar_month_rounded,
                color: Color(0xFFF59E0B), size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Subscribe & save up to 25%',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 2),
                Text('Recurring AC care, weekly cleaning & more',
                    style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});
  final HsService service;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: _tile, borderRadius: BorderRadius.circular(12)),
            child: Icon(service.icon, color: _teal, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(service.desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(service.price,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0E7C6B))),
        ],
      ),
    );
  }
}
