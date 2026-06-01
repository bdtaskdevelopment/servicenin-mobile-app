import 'package:get/get.dart';

class DashboardController extends GetxController {
  /// 0 = Home, 1 = Services, 2 = Orders, 3 = Account.
  /// The center "Quick" button is not a page — it opens a bottom sheet.
  int currentIndex = 0;

  void changeTab(int index) {
    if (index == currentIndex) return;
    currentIndex = index;
    update();
  }
}
