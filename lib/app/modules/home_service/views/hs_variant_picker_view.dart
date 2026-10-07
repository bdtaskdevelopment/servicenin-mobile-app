import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/home_service_controller.dart';
import 'hs_service_list_view.dart';

/// Opened when a citizen taps a sub-service that has variants (e.g. AC
/// capacity) on [HsServiceListView] — picking an option used to expand
/// inline on that list; it now gets its own page so each sub-service is a
/// single clean tap instead of a growing accordion.
///
/// Expects the tapped [HsServiceItem] (the one with non-empty `variants`) as
/// `Get.arguments`.
class HsVariantPickerView extends GetView<HomeServiceController> {
  const HsVariantPickerView({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Get.arguments as HsServiceItem?;
    if (service == null) {
      // Shouldn't happen — nothing sane to show without the service.
      Future.microtask(() => Get.back());
      return const SizedBox.shrink();
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<HomeServiceController>(
          builder: (con) {
            return Column(
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
                      Expanded(
                        child: Text(service.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                      ),
                      GestureDetector(
                        onTap: con.openCart,
                        behavior: HitTestBehavior.opaque,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.shopping_cart_outlined,
                                color: Color(0xFF1A1A1A), size: 24),
                            if (con.totalItems > 0)
                              Positioned(
                                right: -7,
                                top: -7,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  constraints: const BoxConstraints(
                                      minWidth: 18, minHeight: 18),
                                  decoration: const BoxDecoration(
                                      color: AppColors.brandOrange,
                                      shape: BoxShape.circle),
                                  alignment: Alignment.center,
                                  child: Text('${con.totalItems}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    children: [
                      // Sub-service summary: same thumb/desc/duration a plain
                      // catalog row shows, so the context carries over.
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: const Color(0xFFEDEFF2))),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            hsServiceThumb(service, size: 44),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${service.bnName} · ${service.duration}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF94A3B8))),
                                  if (service.desc.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(service.desc,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF64748B))),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Choose an option'.tr,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 0.6)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: const Color(0xFFEDEFF2)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            for (final v in service.variants)
                              HsVariantRow(
                                  service: service, variant: v, con: con),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (con.totalItems > 0) HsReviewBar(con: con),
              ],
            );
          },
        ),
      ),
    );
  }
}
