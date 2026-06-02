import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/custom_app_bar.dart';
import '../../../routes/app_pages.dart';
import '../controllers/ambulance_controller.dart';

const _red = Color(0xFFE23744);
const _indigo = Color(0xFF6366F1);

class AmbulanceView extends GetView<AmbulanceController> {
  const AmbulanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: 'Ambulance',
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(Routes.AMBULANCE_NOTIFICATIONS),
            icon: const Icon(Icons.notifications_none_rounded,
                color: Color(0xFF1A1A1A)),
          ),
        ],
      ),
      body: GetBuilder<AmbulanceController>(
        builder: (con) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _LocationCard(location: con.currentLocation),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.AMBULANCE_BOOKING),
                child: const _EmergencyCard(),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.AMBULANCE_SCHEDULE),
                child: const _ScheduleCard(),
              ),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.AMBULANCE_SELECT),
                child: _SectionHeader(
                    title: 'Choose ambulance type', action: 'See all →'),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: con.types.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _TypeCard(
                    type: con.types[i],
                    selected: con.selectedType == i,
                    onTap: () => Get.toNamed(Routes.AMBULANCE_SELECT),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nearby ambulances',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 2),
                      Text('${con.nearbyAvailable} available · ${con.radius}',
                          style: const TextStyle(
                              fontSize: 12.5, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _MapCard(area: con.area),
              const SizedBox(height: 22),
              _SectionHeader(title: 'Recent bookings', action: 'History →'),
              const SizedBox(height: 12),
              ...con.bookings.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _BookingCard(booking: b),
                  )),
            ],
          );
        },
      ),
    );
  }
}

// ── Current location ────────────────────────────────────────────────
class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.location});
  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFDE4E4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on_outlined,
                color: _red, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CURRENT LOCATION',
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text('Change',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155))),
          ),
        ],
      ),
    );
  }
}

// ── Emergency CTA ───────────────────────────────────────────────────
class _EmergencyCard extends StatelessWidget {
  const _EmergencyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_red, Color(0xFFC2182B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -6,
            top: -10,
            bottom: -10,
            child: Icon(Icons.add_rounded,
                size: 120, color: Colors.white.withValues(alpha: 0.12)),
          ),
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6), width: 2),
                ),
                child: const Icon(Icons.airport_shuttle_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('EMERGENCY · 999',
                        style: TextStyle(
                            color: Color(0xFFFFDADE),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    const Text('Call Ambulance Now',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text('২ ট্যাপ আম্বুলেন্স · Avg pickup 6 min',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Schedule card ───────────────────────────────────────────────────
class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _indigo.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_month_rounded,
                color: _indigo, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Schedule an ambulance',
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                SizedBox(height: 2),
                Text('For pre-booked transfers · checkups · dialysis',
                    style:
                        TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

// ── Section header ──────────────────────────────────────────────────
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

// ── Ambulance type card ─────────────────────────────────────────────
class _TypeCard extends StatelessWidget {
  const _TypeCard(
      {required this.type, required this.selected, required this.onTap});
  final AmbulanceType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _indigo : const Color(0xFFEDEFF2),
            width: selected ? 1.6 : 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _indigo.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.airport_shuttle_rounded,
                      color: _indigo, size: 20),
                ),
                const Spacer(),
                if (type.available != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle,
                            size: 6, color: Color(0xFF16A34A)),
                        const SizedBox(width: 4),
                        Text('${type.available}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF15803D))),
                      ],
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(type.name,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 2),
            Text(type.subtitle,
                style:
                    const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('৳${type.price}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const Spacer(),
                if (type.eta != null)
                  Text(type.eta!,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Nearby map card ─────────────────────────────────────────────────
class _MapCard extends StatelessWidget {
  const _MapCard({required this.area});
  final String area;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 180,
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _AmbMapPainter())),
            Positioned(
              left: 12,
              top: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(area,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.circle, size: 8, color: Color(0xFF1E2A4A)),
                    SizedBox(width: 6),
                    Text('You',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFE9EEF3));

    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 14;
    canvas.drawLine(Offset(0, size.height * 0.55),
        Offset(size.width, size.height * 0.42), road);
    canvas.drawLine(Offset(size.width * 0.4, 0),
        Offset(size.width * 0.5, size.height), road);

    final block = Paint()..color = const Color(0xFFDDE5EC);
    void b(double x, double y, double w, double h) => canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, w, h), const Radius.circular(6)),
        block);
    b(size.width * 0.06, size.height * 0.12, 60, 40);
    b(size.width * 0.55, size.height * 0.10, 70, 40);
    b(size.width * 0.08, size.height * 0.62, 60, 40);
    b(size.width * 0.58, size.height * 0.62, 70, 40);

    // route (dashed)
    final route = Paint()
      ..color = const Color(0xFFE23744)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final start = Offset(size.width * 0.14, size.height * 0.82);
    final end = Offset(size.width * 0.86, size.height * 0.22);
    for (int i = 0; i < 24; i += 2) {
      canvas.drawLine(
        Offset.lerp(start, end, i / 24)!,
        Offset.lerp(start, end, (i + 1) / 24)!,
        route,
      );
    }

    // markers (ambulance crosses)
    void marker(Offset o, double r) {
      canvas.drawCircle(o, r, Paint()..color = const Color(0x33E23744));
      canvas.drawCircle(o, r * 0.55, Paint()..color = const Color(0xFFE23744));
    }

    marker(Offset(size.width * 0.34, size.height * 0.62), 18);
    marker(Offset(size.width * 0.7, size.height * 0.28), 14);
    marker(Offset(size.width * 0.6, size.height * 0.68), 11);

    // You dot
    canvas.drawCircle(start, 7, Paint()..color = const Color(0xFF1E2A4A));
    canvas.drawCircle(start, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Booking card ────────────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});
  final AmbulanceBooking booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.airport_shuttle_rounded,
                color: Color(0xFF334155), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.id,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8))),
                const SizedBox(height: 2),
                Text(booking.title,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(booking.dateAmount,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Completed',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15803D))),
          ),
        ],
      ),
    );
  }
}
