import 'package:get/get.dart';

import '../../../core/values/storage.dart';
import '../../../data/services/storage.service.dart';
import '../../../routes/app_pages.dart';

class AccountController extends GetxController {
  String get name => 'Tanzil';

  /// Masked phone, e.g. "+880 1711-••••23".
  String get maskedPhone {
    final raw = StorageService.read(StorageConstants.phoneNumber) as String?;
    if (raw == null || raw.length < 6) return '+880 1711-••••23';
    final start = raw.substring(0, 4);
    final end = raw.substring(raw.length - 2);
    return '+880 $start-••••$end';
  }

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : 'U';

  void logout() {
    StorageService.remove(StorageConstants.accessToken);
    Get.offAllNamed(Routes.AUTH);
  }
}
