import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/blood_event_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/blood_controller.dart';

const _red = Color(0xFFE5383B);

class BloodEventsView extends GetView<BloodController> {
  const BloodEventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5FA),
        body: SafeArea(
          child: GetBuilder<BloodController>(
            initState: (_) => controller.fetchEvents(),
            builder: (con) => Column(
              children: [
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.fromLTRB(8, 6, 16, 10),
                  child: Row(
                    children: [
                      IconButton(
                        splashRadius: 22,
                        onPressed: () => Get.back(),
                        icon: const Icon(LucideIcons.chevronLeft, size: 22, color: Color(0xFF0F172A)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Events'.tr,
                              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          const SizedBox(height: 1),
                          Text('Our programs & camps'.tr,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  color: AppColors.white,
                  child: TabBar(
                    labelColor: _red,
                    unselectedLabelColor: const Color(0xFF94A3B8),
                    indicatorColor: _red,
                    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                    unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    tabs: [
                      Tab(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('${'Upcoming events'.tr} (${con.upcomingEvents.length})'),
                        ),
                      ),
                      Tab(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('${'Past events'.tr} (${con.pastEvents.length})'),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _EventsList(con: con, events: con.upcomingEvents, loading: con.loadingEvents),
                      _EventsList(con: con, events: con.pastEvents, loading: con.loadingEvents),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  const _EventsList({required this.con, required this.events, required this.loading});
  final BloodController con;
  final List<BloodEvent> events;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading && events.isEmpty) {
      return const SnListSkeleton(padding: EdgeInsets.fromLTRB(16, 12, 16, 24));
    }
    if (events.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
        children: [
          Icon(LucideIcons.calendarDays, size: 56, color: Colors.black.withValues(alpha: 0.12)),
          const SizedBox(height: 12),
          Text('No events here yet'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: con.fetchEvents,
      color: _red,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          ...events.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _EventCard(event: e.value, banner: e.key.isEven ? _red : const Color(0xFF1E3A8A), con: con),
              )),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.banner, required this.con});
  final BloodEvent event;
  final Color banner;
  final BloodController con;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => con.openEvent(event),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 110,
                  width: double.infinity,
                  color: banner,
                  alignment: Alignment.center,
                  child: event.bannerUrl.isEmpty
                      ? Icon(LucideIcons.image, color: Colors.white.withValues(alpha: 0.6), size: 26)
                      : Image.network(event.bannerUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 110,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: Text((event.isUpcoming ? 'Upcoming event' : 'Past event').tr,
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(LucideIcons.calendarDays, size: 13, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(event.dateLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
                      ),
                    ],
                  ),
                  if (event.location.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, size: 13, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(event.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => con.openEvent(event),
                        child: Text('Read details →'.tr,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _red)),
                      ),
                      const Spacer(),
                      if (event.isUpcoming)
                        GestureDetector(
                          onTap: () => con.toggleJoinEvent(event),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                                color: event.hasJoined ? const Color(0xFFDCFCE7) : _red,
                                borderRadius: BorderRadius.circular(20)),
                            child: Text((event.hasJoined ? 'Joined' : 'Join').tr,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: event.hasJoined ? const Color(0xFF16A34A) : Colors.white)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
