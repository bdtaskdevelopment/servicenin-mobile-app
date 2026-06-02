import 'package:get/get.dart';

import '../controllers/nagarik_controller.dart';

class NagarikBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NagarikController>(() => NagarikController(), fenix: true);
  }
}
