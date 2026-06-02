import 'package:get/get.dart';

import '../controllers/physio_controller.dart';

class PhysioBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PhysioController>(() => PhysioController(), fenix: true);
  }
}
