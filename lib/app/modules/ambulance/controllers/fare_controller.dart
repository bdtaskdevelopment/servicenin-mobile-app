import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class FareLine {
  const FareLine(this.label, this.sub, this.amount, {this.discount = false});
  final String label;
  final String sub;
  final String amount;
  final bool discount;
}

class PayMethod {
  const PayMethod(this.name, this.sub, this.color);
  final String name;
  final String sub;
  final Color color;
}

class FareController extends GetxController {
  final String area = 'Gulshan-2 · Dhaka';
  final String hospital = 'United Hsp.';
  final String pickupDistance = 'Pickup · 3.2 km';

  final String vehicle = 'ICU Ambulance · BD-1234';
  final String vehicleSub = 'Ventilator · Paramedic on-board';
  final String eta = 'ETA 6 min';

  final List<FareLine> lines = const [
    FareLine('Base fare', 'ICU Ambulance', '৳2,500'),
    FareLine('Distance', '3.2 km × ৳80', '৳256'),
    FareLine('Emergency surcharge', 'Priority dispatch', '৳200'),
    FareLine('Waiting charge', '~4 min @ ৳5/min', '৳20'),
    FareLine('Equipment', 'Oxygen + ventilator', '৳150'),
    FareLine('Vulnerable discount', 'Senior citizen (5%)', '-৳158', discount: true),
  ];
  final String total = '৳2,968';

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

  void confirmDispatch() => Get.toNamed(Routes.AMBULANCE_DISPATCHING);
}
