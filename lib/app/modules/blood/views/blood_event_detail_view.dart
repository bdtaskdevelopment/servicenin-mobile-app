import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/blood_event_response.dart';
import '../controllers/blood_controller.dart';

const _red = Color(0xFFE5383B);
const _pinkTile = Color(0xFFFDECEC);

class BloodEventDetailView extends GetView<BloodController> {
  const BloodEventDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BloodController>(
      builder: (con) {
        final event = con.viewingEvent;
        if (event == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF4F5FA),
            body: SafeArea(
              child: Center(
                child: Text('Event not found'.tr, style: const TextStyle(color: Color(0xFF94A3B8))),
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: const Color(0xFFF4F5FA),
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: false,
                    backgroundColor: _red,
                    expandedHeight: 220,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: event.bannerUrl.isEmpty
                          ? Container(
                              color: _red,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(LucideIcons.image, color: Colors.white.withValues(alpha: 0.6), size: 30),
                                  const SizedBox(height: 8),
                                  Text('Event banner photo'.tr,
                                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                                ],
                              ),
                            )
                          : Image.network(event.bannerUrl, fit: BoxFit.cover),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -20),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF4F5FA),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(color: _pinkTile, borderRadius: BorderRadius.circular(8)),
                                  child: Text((event.isUpcoming ? 'Upcoming event' : 'Past event').tr,
                                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: _red)),
                                ),
                                if (event.isFree) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                                    child: Text('Free'.tr,
                                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF16A34A))),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(event.title,
                                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                            if (event.organizer.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('${'Organizer'.tr}: ${event.organizer}',
                                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8))),
                            ],
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3))],
                              ),
                              child: Column(
                                children: [
                                  _InfoRow(icon: LucideIcons.clock, label: 'Time'.tr, value: event.timeRangeLabel),
                                  if (event.location.isNotEmpty) ...[
                                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                    _InfoRow(icon: LucideIcons.mapPin, label: 'Location'.tr, value: event.location),
                                  ],
                                ],
                              ),
                            ),
                            if (event.description.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text('Details'.tr,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14)),
                                child: Text(event.description,
                                    style: const TextStyle(fontSize: 13.5, color: Color(0xFF475569), height: 1.5)),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(14)),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    child: const Icon(LucideIcons.users, size: 17, color: Color(0xFF16A34A)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${event.attendeeCount} ${'people joining'.tr}',
                                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF166534))),
                                        if (!event.hasJoined)
                                          Text('Join us too'.tr, style: const TextStyle(fontSize: 11.5, color: Color(0xFF16A34A))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 90),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 8,
                left: 8,
                child: SafeArea(
                  child: _CircleButton(icon: LucideIcons.chevronLeft, onTap: () => Get.back()),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: SafeArea(
                  child: _CircleButton(icon: LucideIcons.share2, onTap: () {}),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _BottomBar(con: con, event: event),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
        child: Icon(icon, size: 19, color: Colors.white),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: _pinkTile, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: _red),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.con, required this.event});
  final BloodController con;
  final BloodEvent event;

  Future<void> _call() async {
    if (event.contactPhone.isEmpty) return;
    try {
      await launchUrl(Uri.parse('tel:${event.contactPhone}'), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: event.contactPhone.isEmpty ? null : _call,
                icon: const Icon(LucideIcons.phone, size: 17),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _red,
                  side: const BorderSide(color: _red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                label: Text('Contact'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          if (event.isUpcoming) ...[
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 52,
                child: GetBuilder<BloodController>(
                  builder: (_) => ElevatedButton.icon(
                    onPressed: con.joiningEvent ? null : () => con.toggleJoinEvent(event),
                    icon: Icon(event.hasJoined ? LucideIcons.circleCheck : LucideIcons.userPlus, size: 18),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: event.hasJoined ? const Color(0xFF16A34A) : _red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    label: Text((event.hasJoined ? 'Joined' : 'Join now').tr,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
