import 'package:get/get.dart';

import '../../account/controllers/account_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../notifications/controllers/notifications_controller.dart';
import '../../orders/controllers/orders_controller.dart';
import '../../services/controllers/services_controller.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ServicesController>(() => ServicesController());
    Get.lazyPut<OrdersController>(() => OrdersController());
    Get.lazyPut<AccountController>(() => AccountController());
    // Kept alive across the dashboard so the app-bar bell can show the
    // live unread badge on Home/Orders/Account tabs.
    Get.lazyPut<NotificationsController>(() => NotificationsController(),
        fenix: true);
  }
}
