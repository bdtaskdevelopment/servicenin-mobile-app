import 'package:get/get.dart';

import '../controllers/matchmaking_controller.dart';
import '../controllers/mm_chat_controller.dart';

class MatchmakingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MatchmakingController>(() => MatchmakingController(),
        fenix: true);
    Get.lazyPut<MmChatController>(() => MmChatController(), fenix: true);
  }
}
