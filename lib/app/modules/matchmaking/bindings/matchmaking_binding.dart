import 'package:get/get.dart';

import '../controllers/matchmaking_controller.dart';

class MatchmakingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MatchmakingController>(() => MatchmakingController(),
        fenix: true);
  }
}
