import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

enum JobStatus { inProgress, assigned }

class ProviderJob {
  const ProviderJob({
    required this.title,
    required this.place,
    required this.price,
    required this.status,
  });
  final String title;
  final String place;
  final String price;
  final JobStatus status;
}

class WithdrawalEntry {
  const WithdrawalEntry(this.amount, this.method, this.id, this.date);
  final String amount;
  final String method;
  final String id;
  final String date;
}

class ProviderController extends GetxController {
  final String name = 'Jamal Uddin';
  final String balance = '৳8,450';
  final String pending = '৳1,198';
  final String withdrawn = '৳42,600';
  final String jobsDone = '312';
  final String rating = '4.8';
  final String acceptance = '98%';

  final List<ProviderJob> jobs = const [
    ProviderJob(
        title: 'AC General Service ×2',
        place: 'Gulshan-2 · Today 3:00 PM',
        price: '৳1,198',
        status: JobStatus.inProgress),
    ProviderJob(
        title: 'AC Gas Refill',
        place: 'Banani · Today 6:00 PM',
        price: '৳1,500',
        status: JobStatus.assigned),
    ProviderJob(
        title: 'AC Installation',
        place: 'Baridhara · Tomorrow 11 AM',
        price: '৳800',
        status: JobStatus.assigned),
  ];

  // ── Earnings ─────────────────────────────────────────────────────
  final String monthEarnings = '৳24,680';
  final String monthJobs = '32 jobs';
  final String avgPerJob = 'avg ৳771/job';

  final List<String> withdrawMethods = const ['bKash', 'Nagad', 'Rocket', 'Bank'];
  int selectedWithdraw = 0;
  void selectWithdraw(int i) {
    selectedWithdraw = i;
    update();
  }

  final List<WithdrawalEntry> history = const [
    WithdrawalEntry('৳5,000', 'bKash', 'WD-221', '28 May'),
    WithdrawalEntry('৳8,000', 'Bank', 'WD-198', '6 May'),
    WithdrawalEntry('৳3,500', 'Nagad', 'WD-176', '24 Apr'),
  ];

  // ── Navigation ───────────────────────────────────────────────────
  void navigateJob() => Get.toNamed(Routes.HS_CHAT);
  void withdrawEarnings() => Get.toNamed(Routes.HS_EARNINGS);
  void withdrawAll() =>
      Get.until((route) => route.settings.name == Routes.HS_PROVIDER);
}
