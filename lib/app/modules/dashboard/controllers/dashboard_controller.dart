import 'package:get/get.dart';

import '../../orders/controllers/orders_controller.dart';

class DashboardController extends GetxController {
  /// 0 = Home, 1 = Services, 2 = Orders, 3 = Account.
  /// The center "Quick" button is not a page — it opens a bottom sheet.
  static const int ordersTab = 2;

  int currentIndex = 0;

  void changeTab(int index) {
    if (index == currentIndex) return;
    currentIndex = index;
    update();
    // The Orders tab lives in an IndexedStack, so its controller is created
    // once at app start and would otherwise keep that first (possibly empty)
    // list. Re-pull whenever the tab is opened so new bookings show up.
    if (index == ordersTab) Get.find<OrdersController>().fetchOrders();
  }
}
