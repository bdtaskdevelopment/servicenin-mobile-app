import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/ambulance_controller.dart';

const _navy = Color(0xFF1E2A4A);

/// Rate a completed trip — driver, ambulance condition and overall service,
/// each 1-5, plus an optional comment.
/// Rates whichever booking `AmbulanceController.lastBooking` currently holds
/// (set by `trackBooking`/`createBooking`), same as `BookingConfirmedView`.
class RateAmbulanceView extends StatefulWidget {
  const RateAmbulanceView({super.key});

  @override
  State<RateAmbulanceView> createState() => _RateAmbulanceViewState();
}

class _RateAmbulanceViewState extends State<RateAmbulanceView> {
  int _driverRating = 5;
  int _conditionRating = 5;
  int _serviceRating = 5;
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final con = Get.find<AmbulanceController>();
    final bookingId = con.lastBooking?.id;
    if (bookingId == null || bookingId.isEmpty) return;
    final ok = await con.submitRating(
      bookingId,
      driverRating: _driverRating,
      ambulanceConditionRating: _conditionRating,
      serviceRating: _serviceRating,
      comment: _comment.text.trim(),
    );
    if (ok && mounted) {
      await con.fetchBookings();
      // The success snackbar can still be open here — plain Get.back() only
      // dismisses it and returns without popping the route in that case.
      Get.back(closeOverlays: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
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
                  Text('Rate this trip'.tr,
                      style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                children: [
                  _StarSection(
                    label: 'Driver'.tr,
                    value: _driverRating,
                    onChanged: (v) => setState(() => _driverRating = v),
                  ),
                  const SizedBox(height: 12),
                  _StarSection(
                    label: 'Ambulance condition'.tr,
                    value: _conditionRating,
                    onChanged: (v) => setState(() => _conditionRating = v),
                  ),
                  const SizedBox(height: 12),
                  _StarSection(
                    label: 'Overall service'.tr,
                    value: _serviceRating,
                    onChanged: (v) => setState(() => _serviceRating = v),
                  ),
                  const SizedBox(height: 18),
                  Text('COMMENT (OPTIONAL)'.tr,
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.6)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: TextField(
                      controller: _comment,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Quick response, courteous driver…'.tr,
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: GetBuilder<AmbulanceController>(
                  builder: (con) => ElevatedButton(
                    onPressed: con.submittingRating ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: con.submittingRating
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.4, color: Colors.white),
                          )
                        : Text('Submit'.tr,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarSection extends StatelessWidget {
  const _StarSection({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A))),
          ),
          ...List.generate(5, (i) {
            final active = i < value;
            return GestureDetector(
              onTap: () => onChanged(i + 1),
              child: Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Icon(Icons.star_rounded,
                    size: 26,
                    color: active
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFFE2E8F0)),
              ),
            );
          }),
        ],
      ),
    );
  }
}
