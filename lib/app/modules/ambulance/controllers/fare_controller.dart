import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import 'select_ambulance_controller.dart';

class PayMethod {
  const PayMethod(this.name, this.sub, this.color);
  final String name;
  final String sub;
  final Color color;
}

class FareController extends GetxController {
  SelectableAmbulance get _amb =>
      Get.find<SelectAmbulanceController>().selectedAmbulance;

  String get vehicle => _amb.name;
  String get vehicleSub => _amb.desc;
  String get eta => 'ETA ${_amb.eta}';

  int get base => _amb.base;
  int get perKm => _amb.perKm;

  // Extra distance (per km) — optional add-on.
  bool extraEnabled = true;
  final TextEditingController extraKmCtrl = TextEditingController(text: '5');
  int get extraKm => int.tryParse(extraKmCtrl.text.trim()) ?? 0;

  void toggleExtra(bool v) {
    extraEnabled = v;
    update();
  }

  void onExtraKmChanged(String _) => update();

  int get extraFare => extraEnabled ? extraKm * perKm : 0;
  int get totalAmount => base + extraFare;

  String _fmt(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  String get baseStr => '৳${_fmt(base)}';
  String get extraStr => '৳${_fmt(extraFare)}';
  String get total => '৳${_fmt(totalAmount)}';

  final List<PayMethod> methods = const [
    PayMethod('Cash', 'on arrival', Color(0xFF0F172A)),
    PayMethod('bKash', '*123', Color(0xFFE2136E)),
    PayMethod('Nagad', '*987', Color(0xFFF15A24)),
    PayMethod('SSLCommerz', 'web pay', Color(0xFF1D4ED8)),
    PayMethod('Visa', '**4521', Color(0xFF1A1F71)),
    PayMethod('Mastercard', '**8810', Color(0xFF7C3AED)),
  ];
  int selectedMethod = 0;
  void selectMethod(int i) {
    selectedMethod = i;
    update();
  }

  @override
  void onClose() {
    extraKmCtrl.dispose();
    super.onClose();
  }

  void confirmDispatch() => Get.toNamed(Routes.AMBULANCE_DISPATCHING);
}
