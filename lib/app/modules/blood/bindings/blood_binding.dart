import 'package:get/get.dart';

import '../controllers/blood_chat_controller.dart';
import '../controllers/blood_controller.dart';
import '../controllers/blood_faq_controller.dart';
import '../controllers/blog_controller.dart';
import '../controllers/donation_flow_controller.dart';
import '../controllers/donor_register_controller.dart';
import '../controllers/need_blood_controller.dart';

class BloodBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BloodController>(() => BloodController(), fenix: true);
    Get.lazyPut<NeedBloodController>(() => NeedBloodController(), fenix: true);
    Get.lazyPut<DonationFlowController>(() => DonationFlowController(),
        fenix: true);
    Get.lazyPut<DonorRegisterController>(() => DonorRegisterController(),
        fenix: true);
    Get.lazyPut<BloodChatController>(() => BloodChatController(), fenix: true);
    Get.lazyPut<BlogController>(() => BlogController(), fenix: true);
    Get.lazyPut<BloodFaqController>(() => BloodFaqController(), fenix: true);
  }
}
