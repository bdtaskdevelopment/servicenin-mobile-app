import 'package:get/get.dart';

import '../controllers/home_service_controller.dart';
import '../controllers/hs_chat_controller.dart';
import '../controllers/provider_controller.dart';
import '../controllers/subscriptions_controller.dart';

class HomeServiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeServiceController>(() => HomeServiceController(),
        fenix: true);
    Get.lazyPut<HsChatController>(() => HsChatController(), fenix: true);
    Get.lazyPut<SubscriptionsController>(() => SubscriptionsController(),
        fenix: true);
    Get.lazyPut<ProviderController>(() => ProviderController(), fenix: true);
  }
}
