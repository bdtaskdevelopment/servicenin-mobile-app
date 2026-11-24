import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_url.dart';
import '../../../global_widget/invoice_actions.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../../../routes/app_pages.dart';
import '../controllers/ambulance_controller.dart';
import '../widgets/ambulance_widgets.dart';

const _red = Color(0xFFE4484D);
const _redTint = Color(0xFFFFEFEF);
const _blue = Color(0xFF1D6FD9);
const _orange = Color(0xFFF16621);

class AmbulanceBookingsView extends GetView<AmbulanceController> {
  const AmbulanceBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    splashRadius: 22,
                    onPressed: () => Get.back(),
                    icon: const Icon(LucideIcons.chevronLeft,
                        size: 22, color: Color(0xFF1A1A1A)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My bookings'.tr,
                          style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 1),
                      Text('Tap a booking to see its details'.tr,
                          style: const TextStyle(
                              fontSize: 11.5, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: _red,
                onRefresh: controller.fetchBookings,
                child: GetBuilder<AmbulanceController>(
                  builder: (con) {
                    if (con.loadingBookings && con.bookings.isEmpty) {
                      return const SnListSkeleton();
                    }
                    if (con.bookings.isEmpty) {
                      return const _Empty();
                    }
                    return FadeInUp(
                      from: 18,
                      duration: const Duration(milliseconds: 350),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        children: con.bookings
                            .map((b) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    children: [
                                      BookingCard(
                                          booking: b,
                                          onTap: () => con.trackBooking(b)),
                                      if (b.id.isNotEmpty) ...[
                                        const SizedBox(height: 10),
                                        InvoiceActions(
                                          viewPath: ApiURL.ambInvoicePdf(b.id),
                                          downloadPath:
                                              ApiURL.ambInvoicePdfDownload(
                                                  b.id),
                                          fileName: 'invoice-${b.id}',
                                          accent: _blue,
                                        ),
                                      ],
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 90),
        Center(
          child: SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                      color: _redTint, shape: BoxShape.circle),
                ),
                Positioned(
                  left: 14,
                  bottom: 22,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _orange, width: 2),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 18,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration:
                        const BoxDecoration(color: _red, shape: BoxShape.circle),
                  ),
                ),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _red,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          color: _red.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6)),
                    ],
                  ),
                  child: const Icon(LucideIcons.ambulance,
                      color: Colors.white, size: 30),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Center(
          child: Text('No bookings yet.'.tr,
              style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155))),
        ),
        const SizedBox(height: 18),
        Center(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () => Get.offNamed(Routes.AMBULANCE),
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.plus, size: 18),
                  const SizedBox(width: 8),
                  Text('Book ambulance'.tr,
                      style: const TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
