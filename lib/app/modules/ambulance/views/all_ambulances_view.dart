import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/ambulance_controller.dart';
import '../widgets/ambulance_widgets.dart';

const _red = Color(0xFFE23744);

class AllAmbulancesView extends GetView<AmbulanceController> {
  const AllAmbulancesView({super.key});

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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Available ambulances',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      SizedBox(height: 1),
                      Text('Tap one to estimate the fare',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: _red,
                onRefresh: controller.fetchAvailable,
                child: GetBuilder<AmbulanceController>(
                  builder: (con) {
                    if (con.loadingAvailable && con.available.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2.6, color: _red),
                      );
                    }
                    if (con.available.isEmpty) {
                      return ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text('No ambulances available right now.',
                                style: TextStyle(color: Color(0xFF94A3B8))),
                          ),
                        ],
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: con.available
                          .map((a) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: AmbulanceCard(
                                    amb: a, onTap: () => con.openFareFor(a)),
                              ))
                          .toList(),
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
