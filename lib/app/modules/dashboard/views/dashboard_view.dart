import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../account/views/account_view.dart';
import '../../home/views/home_view.dart';
import '../../orders/views/orders_view.dart';
import '../../services/views/services_view.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/quick_actions_sheet.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (con) {
        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          extendBody: true,
          body: IndexedStack(
            index: con.currentIndex,
            children: const [
              HomeView(),
              ServicesView(),
              OrdersView(),
              AccountView(),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _QuickButton(),
          bottomNavigationBar: _BottomNav(con: con),
        );
      },
    );
  }
}

// ── Center Quick FAB ────────────────────────────────────────────────
class _QuickButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.brandOrangeLight, AppColors.brandOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandOrange.withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: QuickActionsSheet.show,
          child: const Icon(Icons.auto_awesome_rounded,
              color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

// ── Bottom navigation bar ───────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.con});
  final DashboardController con;

  // (pageIndex, outlinedIcon, filledIcon, label). pageIndex -1 = the Quick gap.
  static const _items = [
    (0, Icons.home_outlined, Icons.home_rounded, 'Home'),
    (1, Icons.grid_view_outlined, Icons.grid_view_rounded, 'Services'),
    (-1, Icons.add, Icons.add, 'Quick'),
    (2, Icons.access_time_rounded, Icons.access_time_filled_rounded, 'Orders'),
    (3, Icons.person_outline_rounded, Icons.person_rounded, 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.white,
      elevation: 12,
      shadowColor: Colors.black26,
      height: 64,
      padding: EdgeInsets.zero,
      child: Row(
        children: _items.map((item) {
          final pageIndex = item.$1;
          // Quick slot — just a label under the FAB notch.
          if (pageIndex == -1) {
            return const Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Quick',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandOrange,
                    ),
                  ),
                ),
              ),
            );
          }
          final active = con.currentIndex == pageIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => con.changeTab(pageIndex),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    active ? item.$3 : item.$2,
                    size: 24,
                    color: active
                        ? AppColors.brandOrange
                        : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.$4,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                      color: active
                          ? AppColors.brandOrange
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
