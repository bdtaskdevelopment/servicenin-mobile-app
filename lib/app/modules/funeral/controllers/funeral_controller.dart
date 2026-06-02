import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class FuneralService {
  const FuneralService({
    required this.icon,
    required this.title,
    required this.bangla,
    required this.desc,
  });
  final IconData icon;
  final String title;
  final String bangla;
  final String desc;
}

class FuneralUnit {
  const FuneralUnit({
    required this.name,
    required this.area,
    required this.status,
  });
  final String name;
  final String area;
  final String status;
}

class FuneralController extends GetxController {
  final List<FuneralService> services = const [
    FuneralService(
      icon: Icons.waves_rounded,
      title: 'Ghusl & Kafan',
      bangla: 'গোসল ও কাফন',
      desc: 'Ritual washing & shrouding by trained attendants',
    ),
    FuneralService(
      icon: Icons.local_shipping_outlined,
      title: 'Hearse / Freezer van',
      bangla: 'ফ্রিজার ভ্যান',
      desc: 'Refrigerated transport to home, mosque or graveyard',
    ),
    FuneralService(
      icon: Icons.account_balance_outlined,
      title: 'Janaza coordination',
      bangla: 'জানাজা',
      desc: 'Mosque liaison & prayer scheduling',
    ),
    FuneralService(
      icon: Icons.location_on_outlined,
      title: 'Burial / graveyard',
      bangla: 'দাফন',
      desc: 'Plot arrangement & grave digging',
    ),
  ];

  final List<FuneralUnit> units = const [
    FuneralUnit(
      name: 'Anjuman Mufidul Islam',
      area: 'Kakrail · citywide',
      status: 'Available 24/7',
    ),
    FuneralUnit(
      name: 'ServiceNin Funeral Care',
      area: 'Gulshan · Banani · Uttara',
      status: '3 vans available now',
    ),
  ];

  // Which services are ticked on the request form (defaults to first two).
  final List<bool> selected = [true, true, false, false];
  void toggleService(int i) {
    selected[i] = !selected[i];
    update();
  }

  // ---- Navigation ----
  void requestService() => Get.toNamed(Routes.FUNERAL_REQUEST);

  void submitRequest() => Get.toNamed(Routes.FUNERAL_DONE);

  void done() => Get.until((r) => Get.currentRoute == Routes.FUNERAL);
}
