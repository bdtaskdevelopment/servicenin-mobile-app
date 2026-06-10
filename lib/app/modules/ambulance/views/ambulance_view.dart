import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/custom_app_bar.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/ambulance_controller.dart';
import '../widgets/ambulance_widgets.dart';

const _red = Color(0xFFE23744);

class AmbulanceView extends GetView<AmbulanceController> {
  const AmbulanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: CustomAppBar(
        title: 'Ambulance',
        backgroundColor: AppColors.white,
        // Notification bell hidden for now.
        // actions: [
        //   IconButton(
        //     onPressed: () => Get.toNamed(Routes.AMBULANCE_NOTIFICATIONS),
        //     icon: const Icon(Icons.notifications_none_rounded,
        //         color: Color(0xFF1A1A1A)),
        //   ),
        // ],
      ),
      body: RefreshIndicator(
        color: _red,
        onRefresh: () async {
          await Future.wait([
            controller.fetchAvailable(),
            controller.fetchBookings(),
          ]);
        },
        child: GetBuilder<AmbulanceController>(
          builder: (con) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _SectionHeader(
                  title: 'Available ambulances',
                  onSeeAll: con.openSeeAll,
                ),
                const SizedBox(height: 12),
                _AvailableList(con: con),
                const SizedBox(height: 22),
                _SectionHeader(
                  title: 'Recent bookings',
                  onSeeAll: con.openBookings,
                ),
                const SizedBox(height: 12),
                _BookingsList(con: con),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A))),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          child: const Text('See all →',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandOrange)),
        ),
      ],
    );
  }
}

class _AvailableList extends StatelessWidget {
  const _AvailableList({required this.con});
  final AmbulanceController con;

  @override
  Widget build(BuildContext context) {
    if (con.loadingAvailable && con.available.isEmpty) {
      return const _Loader();
    }
    if (con.available.isEmpty) {
      return const _EmptyCard(text: 'No ambulances available right now.');
    }
    final shown = con.available.take(5).toList();
    return Column(
      children: shown
          .map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AmbulanceCard(amb: a, onTap: () => con.openFareFor(a)),
              ))
          .toList(),
    );
  }
}

class _BookingsList extends StatelessWidget {
  const _BookingsList({required this.con});
  final AmbulanceController con;

  @override
  Widget build(BuildContext context) {
    if (con.loadingBookings && con.bookings.isEmpty) {
      return const _Loader();
    }
    if (con.bookings.isEmpty) {
      return const _EmptyCard(text: 'No bookings yet.');
    }
    final shown = con.bookings.take(2).toList();
    return Column(
      children: shown
          .map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BookingCard(
                    booking: b, onTap: () => con.trackBooking(b)),
              ))
          .toList(),
    );
  }
}

class _Loader extends StatelessWidget {
  const _Loader();
  @override
  Widget build(BuildContext context) => const SnListSkeleton(
        count: 3,
        padding: EdgeInsets.zero,
      );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEFF2)),
        ),
        child: Text(text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
      );
}
