import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/provider_controller.dart';

const _teal = Color(0xFF0E9F8E);
const _darkTeal = Color(0xFF0E7C6B);
const _navy = Color(0xFF1E2A4A);

class EarningsView extends GetView<ProviderController> {
  const EarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<ProviderController>(
          builder: (con) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        splashRadius: 22,
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: Color(0xFF1A1A1A)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Earnings'.tr,
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                          Text('${'Balance'.tr} ${con.balance}',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      // Month hero
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [_navy, Color(0xFF2A3A60)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('This month'.tr,
                                style: const TextStyle(
                                    color: Color(0xFFB6C0CC),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(con.monthEarnings,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text('${con.monthJobs}  ·  ${con.avgPerJob}',
                                style: const TextStyle(
                                    color: Color(0xFFB6C0CC), fontSize: 12.5)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _Label('WITHDRAW TO'.tr),
                      const SizedBox(height: 10),
                      Row(
                        children: List.generate(con.withdrawMethods.length,
                            (i) {
                          final sel = con.selectedWithdraw == i;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: i == con.withdrawMethods.length - 1
                                      ? 0
                                      : 10),
                              child: GestureDetector(
                                onTap: () => con.selectWithdraw(i),
                                child: Container(
                                  height: 48,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: sel
                                            ? _teal
                                            : const Color(0xFFE2E8F0),
                                        width: sel ? 1.6 : 1.2),
                                  ),
                                  child: Text(con.withdrawMethods[i],
                                      style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: sel
                                              ? _darkTeal
                                              : const Color(0xFF334155))),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 22),
                      _Label('WITHDRAWAL HISTORY'.tr),
                      const SizedBox(height: 10),
                      ...con.history.map((h) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _HistoryRow(entry: h),
                          )),
                    ],
                  ),
                ),
                // Bottom
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Available'.tr,
                              style: const TextStyle(
                                  fontSize: 11.5, color: Color(0xFF94A3B8))),
                          Text(con.balance,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: con.withdrawAll,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _darkTeal,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text('Withdraw all'.tr,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.6));
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});
  final WithdrawalEntry entry;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7), shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded,
                color: Color(0xFF16A34A), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${entry.amount} · ${entry.method}',
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('${entry.id} · ${entry.date}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20)),
            child: Text('Paid'.tr,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15803D))),
          ),
        ],
      ),
    );
  }
}
