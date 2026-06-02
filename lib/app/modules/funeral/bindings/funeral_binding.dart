import 'package:get/get.dart';

import '../controllers/funeral_controller.dart';

class FuneralBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FuneralController>(() => FuneralController(), fenix: true);
  }
}
