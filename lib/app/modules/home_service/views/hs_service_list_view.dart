import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/home_service_controller.dart';

const _teal = Color(0xFF0E9F8E);
const _darkTeal = Color(0xFF0E7C6B);

class HsServiceListView extends GetView<HomeServiceController> {
  const HsServiceListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<HomeServiceController>(
          builder: (con) {
            final services = con.visibleServices;
            final isSearch = con.mode == HsListMode.search;
            return Column(
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(con.listTitle,
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                          Text('${services.length} services available',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                      const Spacer(),
                      if (!isSearch)
                        GestureDetector(
                          onTap: con.openSearch,
                          child: const Icon(Icons.search_rounded,
                              color: Color(0xFF1A1A1A), size: 22),
                        ),
                    ],
                  ),
                ),
                if (isSearch)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                          color: const Color(0xFFEFF1F4),
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded,
                              color: Color(0xFF94A3B8)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              autofocus: true,
                              onChanged: con.onQueryChanged,
                              decoration: const InputDecoration(
                                hintText: 'Search services…',
                                hintStyle:
                                    TextStyle(color: Color(0xFF94A3B8)),
                                border: InputBorder.none,
                                isCollapsed: true,
                              ),
                              style: const TextStyle(
                                  fontSize: 14.5, color: Color(0xFF0F172A)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: (con.loadingSub || con.searching) && services.isEmpty
                      ? const SnListSkeleton(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 16))
                      : services.isEmpty
                          ? Center(
                              child: Text(
                                  isSearch
                                      ? 'Search for a service'
                                      : 'No services found',
                                  style: const TextStyle(
                                      color: Color(0xFF94A3B8))))
                          : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          children: services
                              .map((s) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12),
                                    child: _ServiceRow(service: s, con: con),
                                  ))
                              .toList(),
                        ),
                ),
                // Review booking bar
                if (con.totalItems > 0) _ReviewBar(con: con),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.service, required this.con});
  final HsServiceItem service;
  final HomeServiceController con;

  @override
  Widget build(BuildContext context) {
    final qty = con.qtyOf(service);
    final selected = qty > 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: selected ? _teal : const Color(0xFFEDEFF2),
            width: selected ? 1.5 : 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(service.name,
                          style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${service.bnName} · ${service.duration}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
                const SizedBox(height: 8),
                Text(service.desc,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                Text('৳${service.price}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Align(
            alignment: Alignment.center,
            child: selected
                ? _Stepper(
                    qty: qty,
                    onMinus: () => con.dec(service),
                    onPlus: () => con.add(service))
                : _AddButton(onTap: () => con.add(service)),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _teal, width: 1.4),
        ),
        child: const Text('Add +',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800, color: _teal)),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper(
      {required this.qty, required this.onMinus, required this.onPlus});
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: _darkTeal, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          _btn(Icons.remove_rounded, onMinus),
          SizedBox(
            width: 30,
            child: Text('$qty',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
          ),
          _btn(Icons.add_rounded, onPlus),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );
}

class _ReviewBar extends StatelessWidget {
  const _ReviewBar({required this.con});
  final HomeServiceController con;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${con.totalItems} item${con.totalItems > 1 ? 's' : ''}',
                  style: const TextStyle(
                      fontSize: 11.5, color: Color(0xFF94A3B8))),
              Text('৳${con.totalPrice}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: con.reviewBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _darkTeal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Review booking →',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
