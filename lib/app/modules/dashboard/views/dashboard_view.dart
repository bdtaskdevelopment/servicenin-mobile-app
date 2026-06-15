import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldExit = await _confirmExit(context);
            if (shouldExit) SystemNavigator.pop();
          },
          child: Scaffold(
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
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: _QuickButton(),
            bottomNavigationBar: _BottomNav(con: con),
          ),
        );
      },
    );
  }

  /// "Exit app?" confirmation shown when the back button is pressed on the
  /// dashboard. Returns true when the user chooses Yes.
  Future<bool> _confirmExit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Are you sure?'.tr,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A))),
        content: Text('Do you want to exit the app?'.tr,
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('No'.tr,
                style: const TextStyle(
                    color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.appColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Yes'.tr,
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    return result ?? false;
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Text(
                'SN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              Positioned(
                top: 11,
                right: 12,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 11,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
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
            return Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Quick'.tr,
                    style: const TextStyle(
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
                    color: active ? AppColors.brandOrange : Colors.black,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.$4.tr,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: active ? AppColors.brandOrange : Colors.black,
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
