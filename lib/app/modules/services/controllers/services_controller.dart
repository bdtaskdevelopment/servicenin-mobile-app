import 'package:get/get.dart';

import '../../../core/values/sn_catalog.dart';
import '../../../data/models/sn_service.dart';

class ServicesController extends GetxController {
  /// The full-list page shows every real service — the "More" tile only
  /// belongs on Home (where it jumps to this tab), so drop it here.
  List<SnService> get services =>
      SnCatalog.services.where((s) => s.name != 'More').toList();
}
