import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import 'blood_controller.dart';

class Donor {
  const Donor({
    required this.name,
    required this.group,
    required this.distance,
    required this.donations,
    required this.initials,
    required this.color,
  });

  final String name;
  final String group;
  final String distance; // km
  final int donations;
  final String initials;
  final Color color;
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.subtitle,
    required this.initials,
    required this.points,
    required this.color,
    this.isYou = false,
  });

  final int rank;
  final String name;
  final String subtitle;
  final String initials;
  final int points;
  final Color color;
  final bool isYou;
}

/// Drives the full request → finding → tracking → OTP → confirmed flow.
class DonationFlowController extends GetxController {
  final String requestId = 'BR-3391';
  final String group = 'O+';
  final int notified = 14;
  final int responded = 3;
  final String nearest = '1.2';
  final String hospital = 'Square Hospital';

  final List<Donor> donors = const [
    Donor(
        name: 'Tanvir Ahmed',
        group: 'O+',
        distance: '0.8',
        donations: 12,
        initials: 'TA',
        color: Color(0xFFE11D48)),
    Donor(
        name: 'Sadia Islam',
        group: 'O+',
        distance: '1.5',
        donations: 7,
        initials: 'SI',
        color: Color(0xFFEC4899)),
    Donor(
        name: 'Rakib Hasan',
        group: 'O+',
        distance: '2.1',
        donations: 4,
        initials: 'RH',
        color: Color(0xFFF97316)),
  ];

  Donor? selected;

  // Tracking status step: 0 accepted, 1 en route, 2 arrived, 3 confirmed.
  int statusStep = 1;
  final String eta = '9 min';

  // Confirmed stats
  final int totalDonations = 13;
  final int livesTouched = 39;
  final int newRank = 3;
  final String badge = 'Lifesaver II';
  final String nextEligible = 'after 8 Aug 2026';

  // Leaderboard
  final List<LeaderboardEntry> podium = const [
    LeaderboardEntry(
        rank: 1,
        name: 'Mahin',
        subtitle: '',
        initials: 'MC',
        points: 28,
        color: Color(0xFFF59E0B)),
    LeaderboardEntry(
        rank: 2,
        name: 'Farhana',
        subtitle: '',
        initials: 'FY',
        points: 24,
        color: Color(0xFF64748B)),
    LeaderboardEntry(
        rank: 3,
        name: 'Imran',
        subtitle: '',
        initials: 'IK',
        points: 21,
        color: Color(0xFF64748B)),
  ];

  final List<LeaderboardEntry> ranking = const [
    LeaderboardEntry(
        rank: 4,
        name: 'Tanzil Ahmed (you)',
        subtitle: 'B+ donor',
        initials: 'TA',
        points: 12,
        color: Color(0xFFE11D48),
        isYou: true),
    LeaderboardEntry(
        rank: 5,
        name: 'Nabila Rahman',
        subtitle: 'O+ donor',
        initials: 'NR',
        points: 11,
        color: Color(0xFFF59E0B)),
  ];

  // ── Navigation actions ───────────────────────────────────────────
  void accept(Donor donor) {
    selected = donor;
    statusStep = 1;
    update();
    Get.toNamed(Routes.BLOOD_TRACKING);
  }

  void completeDonation() {
    statusStep = 3;
    update();
    Get.offNamed(Routes.BLOOD_CONFIRMED);
  }

  /// Open a chat with the donor currently being tracked.
  void openChat() {
    final d = selected;
    if (d != null && Get.isRegistered<BloodController>()) {
      Get.find<BloodController>().selectedDonor = ConnectedDonor(
        initials: d.initials,
        name: d.name,
        group: d.group,
        area: '${d.distance} km away',
        phone: '01700-000000',
        lastDonation: '${d.donations} donations',
      );
    }
    Get.toNamed(Routes.BLOOD_DONOR_CHAT);
  }

  void viewLeaderboard() => Get.toNamed(Routes.BLOOD_LEADERBOARD);

  void backToBloodHome() {
    Get.until((route) => route.settings.name == Routes.BLOOD);
  }
}
