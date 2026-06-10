import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/funeral_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/funeral_controller.dart';

const _charcoal = Color(0xFF332F2C);
const _green = Color(0xFF16A34A);
const _greenTile = Color(0xFFD6F5E3);
const _grayTile = Color(0xFFE8EAED);
const _subtitle = Color(0xFF6B7A99);

class FuneralView extends GetView<FuneralController> {
  const FuneralView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(
        child: Column(
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Funeral Services',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      SizedBox(height: 1),
                      Text('Compassionate, dignified support',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: con.openMyRequests,
                    child: const Icon(Icons.receipt_long_outlined,
                        color: Color(0xFF1A1A1A), size: 22),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<FuneralController>(
                builder: (con) => ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _charcoal,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                              'ইন্না লিল্লাহি ওয়া ইন্না ইলাইহি রাজিউন',
                              style: TextStyle(
                                  color: Color(0xFFF4D9A8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          Text(
                              con.coordinator?.description.isNotEmpty == true
                                  ? con.coordinator!.description
                                  : 'We\'re here to help you through this time with care.',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                  height: 1.45)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Coordinator card
                    GestureDetector(
                      onTap: con.callCoordinator,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3)),
                            ]),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                  color: _grayTile,
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.support_agent_rounded,
                                  color: Color(0xFF334155), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text('Speak to a coordinator now',
                                      style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A))),
                                  const SizedBox(height: 2),
                                  Text(
                                      _coordinatorLine(con.coordinator),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12.5,
                                          color: Color(0xFF94A3B8))),
                                ],
                              ),
                            ),
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                  color: _greenTile,
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.call_rounded,
                                  color: _green, size: 21),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text('What we arrange',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 12),
                    if (con.loadingServices && con.services.isEmpty)
                      const _Loader()
                    else
                      ...con.services.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ServiceCard(service: s),
                          )),
                    const SizedBox(height: 10),
                    const Text('Service units near you',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 12),
                    if (con.loadingUnits && con.units.isEmpty)
                      const _Loader()
                    else if (con.units.isEmpty)
                      const Text('No units available right now.',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF94A3B8)))
                    else
                      ...con.units.map((u) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _UnitCard(unit: u),
                          )),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: con.requestService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _charcoal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Request funeral service',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _coordinatorLine(FuneralCoordinator? c) {
    if (c == null) return '24/7 helpline';
    final parts = [
      if (c.available.isNotEmpty) c.available,
      if (c.hotline.isNotEmpty) 'hotline ${c.hotline}',
    ];
    return parts.isEmpty ? (c.name) : parts.join(' · ');
  }
}

class _Loader extends StatelessWidget {
  const _Loader();
  @override
  Widget build(BuildContext context) =>
      const SnListSkeleton(padding: EdgeInsets.zero, count: 3);
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});
  final FuneralServiceOption service;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: _grayTile, borderRadius: BorderRadius.circular(12)),
            child: Icon(funeralServiceIcon(service.icon),
                color: const Color(0xFF334155), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(service.label,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                    ),
                    if (service.priceLabel.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(service.priceLabel,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFC2410C))),
                    ],
                  ],
                ),
                if (service.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(service.description,
                      style: const TextStyle(
                          fontSize: 12.5, color: _subtitle)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({required this.unit});
  final FuneralUnitModel unit;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: _grayTile, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.local_shipping_outlined,
                color: Color(0xFF334155), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(unit.name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(
                    [unit.typeLabel, unit.driverName]
                        .where((s) => s.isNotEmpty)
                        .join(' · '),
                    style: const TextStyle(fontSize: 12.5, color: _subtitle)),
              ],
            ),
          ),
          if (unit.isAvailable) ...[
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: _greenTile, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.circle, size: 7, color: _green),
                  SizedBox(width: 5),
                  Text('Available',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
