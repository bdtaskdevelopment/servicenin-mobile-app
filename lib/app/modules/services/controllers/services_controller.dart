import 'package:get/get.dart';

import '../../../core/values/sn_catalog.dart';
import '../../../data/models/sn_service.dart';

/// Hidden for now — still fully wired up (routes/bindings untouched), just
/// not shown here until re-enabled. Mirrors Home's `_hiddenOnHome`.
const _hiddenServices = {'Marriage', 'Jobs'};

class ServicesController extends GetxController {
  /// The full-list page shows every real service — the "More" tile only
  /// belongs on Home (where it jumps to this tab), so drop it here.
  List<SnService> get services => SnCatalog.services
      .where((s) => s.name != 'More' && !_hiddenServices.contains(s.name))
      .toList();
}
