import 'package:get/get.dart';

import '../controllers/news_controller.dart';
import '../controllers/works_controller.dart';

class ContentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorksController>(() => WorksController(), fenix: true);
    Get.lazyPut<NewsController>(() => NewsController(), fenix: true);
  }
}
