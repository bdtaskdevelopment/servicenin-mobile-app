import 'package:get/get.dart';

import '../controllers/support_controller.dart';

class SupportBinding extends Bindings {
  @override
  void dependencies() {
    // Not fenix/lazyPut-cached: each open passes different arguments, so the
    // controller must re-read them and re-fetch for the module it was opened
    // from.
    Get.put<SupportController>(SupportController());
  }
}
