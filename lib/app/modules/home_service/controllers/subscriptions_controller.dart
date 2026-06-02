import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubPlan {
  const SubPlan(this.name, this.schedule, this.save, this.price, this.icon);
  final String name;
  final String schedule;
  final String save;
  final String price;
  final IconData icon;
}

class MySub {
  const MySub(this.name, this.next, this.schedule, this.icon);
  final String name;
  final String next;
  final String schedule;
  final IconData icon;
}

class SubscriptionsController extends GetxController {
  final List<SubPlan> plans = const [
    SubPlan('Monthly AC Care', 'Every 30 days', 'Save 20%', '৳499',
        Icons.ac_unit_rounded),
    SubPlan('Weekly Home Cleaning', 'Every Friday', 'Save 15%', '৳1999',
        Icons.cleaning_services_rounded),
    SubPlan('Quarterly Pest Control', 'Every 90 days', 'Save 25%', '৳1499',
        Icons.shield_outlined),
  ];

  final List<MySub> mySubs = const [
    MySub('Monthly AC Care', 'Next visit · 12 Jun', 'Every 30 days',
        Icons.ac_unit_rounded),
  ];
}
