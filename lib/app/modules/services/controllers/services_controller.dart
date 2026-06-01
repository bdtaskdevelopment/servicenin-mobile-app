import 'package:get/get.dart';

import '../../../core/values/sn_catalog.dart';
import '../../../data/models/sn_service.dart';

class ServicesController extends GetxController {
  List<SnService> get services => SnCatalog.services;
}
