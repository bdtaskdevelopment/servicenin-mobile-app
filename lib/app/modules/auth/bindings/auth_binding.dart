import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/registration_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<RegistrationController>(() => RegistrationController(),
        fenix: true);
  }
}
