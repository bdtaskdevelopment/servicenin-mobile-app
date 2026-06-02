import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/service_nav.dart';
import '../../../core/values/app_colors.dart';
import '../../../global_widget/service_app_bar.dart';
import '../../../global_widget/sn_service_tile.dart';
import '../controllers/services_controller.dart';

class ServicesView extends GetView<ServicesController> {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const ServiceAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          const Text(
            'All Services',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '১২টি সেবা · এক অ্যাকাউন্টে',
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: controller.services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.86,
            ),
            itemBuilder: (_, i) => SnServiceTile(
              service: controller.services[i],
              onTap: () => ServiceNav.open(controller.services[i]),
            ),
          ),
        ],
      ),
    );
  }
}
