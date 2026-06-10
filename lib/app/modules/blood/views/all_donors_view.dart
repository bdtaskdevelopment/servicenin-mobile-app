import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../global_widget/sn_shimmer.dart';
import '../controllers/blood_controller.dart';
import '../widgets/blood_widgets.dart';

class AllDonorsView extends GetView<BloodController> {
  const AllDonorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<BloodController>(
          builder: (con) => Column(
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
                        Text('All donors',
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        SizedBox(height: 1),
                        Text('Registered blood donors · ServiceNin',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ),
                    const Spacer(),
                    if (con.loadingAllDonors && con.allDonors.isNotEmpty)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.2, color: Color(0xFFE11D48)),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: con.fetchAllDonors,
                  color: const Color(0xFFE11D48),
                  child: _body(con),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BloodController con) {
    if (con.loadingAllDonors && con.allDonors.isEmpty) {
      return const SnListSkeleton(padding: EdgeInsets.fromLTRB(16, 8, 16, 24));
    }
    if (con.allDonors.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 80, 16, 24),
        children: [
          Icon(Icons.groups_outlined,
              size: 56, color: Colors.black.withValues(alpha: 0.12)),
          const SizedBox(height: 12),
          const Text('No donors found',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8))),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        ...con.allDonors.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DonorCard(
                donor: d,
                onView: () => con.viewDonor(d),
                onCall: () => con.callPhone(d.phone),
              ),
            )),
      ],
    );
  }
}
