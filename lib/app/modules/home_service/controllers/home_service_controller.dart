import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class HsCategory {
  const HsCategory(this.name, this.en, this.icon);
  final String name; // Bangla label
  final String en; // English title (used on the service list)
  final IconData icon;
}

class HsService {
  const HsService(this.name, this.desc, this.price, this.icon);
  final String name;
  final String desc;
  final String price;
  final IconData icon;
}

class HsServiceItem {
  const HsServiceItem({
    required this.name,
    required this.bnName,
    required this.duration,
    required this.desc,
    required this.price,
    required this.category,
    this.icon = Icons.ac_unit_rounded,
  });

  final String name;
  final String bnName;
  final String duration;
  final String desc;
  final int price;
  final String category; // matches HsCategory.en
  final IconData icon;
}

enum HsListMode { category, all, search }

class HomeServiceController extends GetxController {
  final List<HsCategory> categories = const [
    HsCategory('এসি সার্ভিস', 'AC Service', Icons.ac_unit_rounded),
    HsCategory('পরিষ্কার', 'Cleaning', Icons.cleaning_services_rounded),
    HsCategory('প্লাম্বিং', 'Plumbing', Icons.water_drop_rounded),
    HsCategory('ইলেকট্রিক', 'Electric', Icons.lightbulb_outline_rounded),
    HsCategory('যন্ত্র মেরামত', 'Appliance Repair', Icons.bolt_rounded),
    HsCategory('পোকা দমন', 'Pest Control', Icons.shield_outlined),
    HsCategory('রং', 'Painting', Icons.format_paint_rounded),
    HsCategory('বাসা বদল', 'Home Shifting', Icons.work_outline_rounded),
  ];

  final List<HsService> popular = const [
    HsService('AC General Service',
        '60 min · Filter clean, gas check, performance test', '৳599',
        Icons.ac_unit_rounded),
    HsService('AC Master Service',
        '90 min · Deep jet wash, coil + drain clean', '৳1099',
        Icons.ac_unit_rounded),
  ];

  // ── Service catalog ──────────────────────────────────────────────
  final List<HsServiceItem> catalog = const [
    HsServiceItem(name: 'AC General Service', bnName: 'সাধারণ সার্ভিস', duration: '60 min', desc: 'Filter clean, gas check, performance test', price: 599, category: 'AC Service', icon: Icons.ac_unit_rounded),
    HsServiceItem(name: 'AC Master Service', bnName: 'মাস্টার সার্ভিস', duration: '90 min', desc: 'Deep jet wash, coil + drain clean', price: 1099, category: 'AC Service', icon: Icons.ac_unit_rounded),
    HsServiceItem(name: 'Gas Refill (per ton)', bnName: 'গ্যাস রিফিল', duration: '75 min', desc: 'R22 / R410A refill with leak test', price: 1500, category: 'AC Service', icon: Icons.ac_unit_rounded),
    HsServiceItem(name: 'Installation', bnName: 'ইন্সটলেশন', duration: '120 min', desc: 'Mount + piping up to 5ft', price: 800, category: 'AC Service', icon: Icons.ac_unit_rounded),
    HsServiceItem(name: 'Uninstallation', bnName: 'খোলা', duration: '60 min', desc: 'Safe dismount + packing', price: 600, category: 'AC Service', icon: Icons.ac_unit_rounded),
    HsServiceItem(name: 'Home Deep Clean', bnName: 'ঘর গভীর পরিষ্কার', duration: '180 min', desc: 'Full home, kitchen + bath', price: 2500, category: 'Cleaning', icon: Icons.cleaning_services_rounded),
    HsServiceItem(name: 'Sofa Cleaning', bnName: 'সোফা পরিষ্কার', duration: '60 min', desc: 'Shampoo + vacuum', price: 1200, category: 'Cleaning', icon: Icons.cleaning_services_rounded),
    HsServiceItem(name: 'Pipe Leak Repair', bnName: 'পাইপ লিক', duration: '45 min', desc: 'Detect + fix leak', price: 450, category: 'Plumbing', icon: Icons.water_drop_rounded),
    HsServiceItem(name: 'Tap / Basin Fix', bnName: 'কল মেরামত', duration: '40 min', desc: 'Replace washer or tap', price: 350, category: 'Plumbing', icon: Icons.water_drop_rounded),
    HsServiceItem(name: 'Wiring Check', bnName: 'ওয়্যারিং চেক', duration: '60 min', desc: 'Full safety inspection', price: 500, category: 'Electric', icon: Icons.lightbulb_outline_rounded),
    HsServiceItem(name: 'Fan / Light Install', bnName: 'ফ্যান-লাইট', duration: '45 min', desc: 'Mount + connect', price: 300, category: 'Electric', icon: Icons.lightbulb_outline_rounded),
    HsServiceItem(name: 'Fridge Repair', bnName: 'ফ্রিজ মেরামত', duration: '90 min', desc: 'Diagnose + fix', price: 700, category: 'Appliance Repair', icon: Icons.bolt_rounded),
    HsServiceItem(name: 'Washing Machine', bnName: 'ওয়াশিং মেশিন', duration: '90 min', desc: 'Service + repair', price: 800, category: 'Appliance Repair', icon: Icons.bolt_rounded),
    HsServiceItem(name: 'Cockroach Control', bnName: 'তেলাপোকা', duration: '60 min', desc: 'Gel + spray treatment', price: 900, category: 'Pest Control', icon: Icons.shield_outlined),
    HsServiceItem(name: 'Room Painting', bnName: 'রুম পেইন্ট', duration: 'per room', desc: 'Putty + 2 coats', price: 3500, category: 'Painting', icon: Icons.format_paint_rounded),
    HsServiceItem(name: 'Mini Truck Move', bnName: 'মিনি ট্রাক', duration: '3 hr', desc: 'Loading + transport', price: 2500, category: 'Home Shifting', icon: Icons.work_outline_rounded),
  ];

  // ── List mode ────────────────────────────────────────────────────
  HsListMode mode = HsListMode.category;
  String selectedCategory = 'AC Service';
  String query = '';

  void onQueryChanged(String v) {
    query = v;
    update();
  }

  String get listTitle => switch (mode) {
        HsListMode.category => selectedCategory,
        HsListMode.all => 'All services',
        HsListMode.search => 'Search services',
      };

  List<HsServiceItem> get visibleServices {
    switch (mode) {
      case HsListMode.category:
        return catalog.where((s) => s.category == selectedCategory).toList();
      case HsListMode.all:
        return catalog;
      case HsListMode.search:
        if (query.trim().isEmpty) return catalog;
        final q = query.toLowerCase();
        return catalog
            .where((s) =>
                s.name.toLowerCase().contains(q) ||
                s.category.toLowerCase().contains(q) ||
                s.desc.toLowerCase().contains(q))
            .toList();
    }
  }

  // ── Cart ─────────────────────────────────────────────────────────
  final Map<String, int> _cart = {};
  int qtyOf(HsServiceItem s) => _cart[s.name] ?? 0;

  void add(HsServiceItem s) {
    _cart[s.name] = (_cart[s.name] ?? 0) + 1;
    update();
  }

  void dec(HsServiceItem s) {
    final q = (_cart[s.name] ?? 0) - 1;
    if (q <= 0) {
      _cart.remove(s.name);
    } else {
      _cart[s.name] = q;
    }
    update();
  }

  int get totalItems => _cart.values.fold(0, (a, b) => a + b);

  int get totalPrice {
    var total = 0;
    for (final s in catalog) {
      total += (_cart[s.name] ?? 0) * s.price;
    }
    return total;
  }

  // ── Navigation ───────────────────────────────────────────────────
  void openCategory(HsCategory c) {
    mode = HsListMode.category;
    selectedCategory = c.en;
    update();
    Get.toNamed(Routes.HOME_SERVICE_LIST);
  }

  void openAll() {
    mode = HsListMode.all;
    update();
    Get.toNamed(Routes.HOME_SERVICE_LIST);
  }

  void openSearch() {
    mode = HsListMode.search;
    query = '';
    update();
    Get.toNamed(Routes.HOME_SERVICE_LIST);
  }

  // ── Confirm-booking schedule / payment ──────────────────────────
  final String address = 'House 32, Road 11, Gulshan-2';

  final List<(String, String)> bookingDates = const [
    ('Today', '29 May'),
    ('Tomorrow', '30 May'),
    ('Sat', '31 May'),
  ];
  int selectedBookingDate = 0;
  void selectBookingDate(int i) {
    selectedBookingDate = i;
    update();
  }

  final List<String> bookingTimes = const [
    '9:00 AM', '11:00 AM', '1:00 PM', '3:00 PM', '5:00 PM', '7:00 PM',
  ];
  String selectedBookingTime = '3:00 PM';
  void selectBookingTime(String t) {
    selectedBookingTime = t;
    update();
  }

  final List<(String, IconData, Color)> payments = const [
    ('Cash after service', Icons.bolt_rounded, Color(0xFF0E7C6B)),
    ('bKash', Icons.water_drop_rounded, Color(0xFFE2136E)),
    ('Nagad', Icons.account_balance_wallet_outlined, Color(0xFFF15A24)),
    ('Card', Icons.credit_card_rounded, Color(0xFF334155)),
  ];
  int selectedPayment = 0;
  void selectPayment(int i) {
    selectedPayment = i;
    update();
  }

  // ── Booking summary / invoice ────────────────────────────────────
  List<HsServiceItem> get cartItems =>
      catalog.where((s) => (_cart[s.name] ?? 0) > 0).toList();

  String get bookingSummary {
    if (cartItems.isEmpty) return 'AC General Service ×1';
    final first = cartItems.first;
    return '${first.name} ×$totalItems';
  }

  String get whenSummary =>
      '${bookingDates[selectedBookingDate].$1} · $selectedBookingTime';

  int get vat => (totalPrice * 0.05).round();
  int get totalPaid => totalPrice + vat;

  // Booking / technician detail (demo)
  final String bookingId = 'SB-5521';
  final String techName = 'Jamal Uddin';
  final String techInitials = 'JU';
  final String techRating = '4.8';
  final String techJobs = '312 jobs';

  // ── Booking-flow navigation ──────────────────────────────────────
  void reviewBooking() {
    if (totalItems == 0) return;
    Get.toNamed(Routes.HS_CONFIRM);
  }

  void placeBooking() => Get.toNamed(Routes.HS_PLACED);
  void trackBooking() => Get.toNamed(Routes.HS_TRACKING);
  void viewBookingDetails() => Get.toNamed(Routes.HS_DETAILS);
  void rateService() => Get.toNamed(Routes.HS_RATE);
  void openSubscriptions() => Get.toNamed(Routes.HS_SUBSCRIPTIONS);

  void backToHomeService() =>
      Get.until((route) => route.settings.name == Routes.HOME_SERVICE);
}
