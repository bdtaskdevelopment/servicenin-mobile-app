import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/emergency_controller.dart';

const _navy = Color(0xFF222A54);

class DispatchingView extends StatefulWidget {
  const DispatchingView({super.key});

  @override
  State<DispatchingView> createState() => _DispatchingViewState();
}

class _DispatchingViewState extends State<DispatchingView> {
  @override
  void initState() {
    super.initState();
    // Simulate searching for the nearest ambulance, then go to tracking.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<EmergencyController>().runDispatchThenTrack();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Pulsing rings + ambulance
            SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _ring(240, 0.05),
                  _ring(180, 0.08),
                  _ring(120, 0.12),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.airport_shuttle_rounded,
                        color: Colors.white, size: 40),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('Dispatching ambulance'.tr,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Finding the nearest ambulance…'.tr,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
            const SizedBox(height: 36),
            // Steps
            GetBuilder<EmergencyController>(
              builder: (c) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    _step('Request received'.tr, done: true, active: false),
                    _step('Finding nearest ICU ambulance'.tr,
                        done: c.dispatchStep > 1, active: c.dispatchStep == 1),
                    _step('Driver assigned'.tr,
                        done: c.dispatchStep >= 2, active: false),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Cancel
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Cancel request'.tr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ring(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: opacity)),
        ),
      );

  Widget _step(String label, {required bool done, required bool active}) {
    final Color color = done
        ? const Color(0xFF22C55E)
        : active
            ? const Color(0xFFE23744)
            : Colors.white.withValues(alpha: 0.25);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            done
                ? Icons.check_circle
                : active
                    ? Icons.radio_button_checked
                    : Icons.circle_outlined,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  color: (done || active)
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                  fontSize: 14.5,
                  fontWeight: (done || active)
                      ? FontWeight.w700
                      : FontWeight.w500)),
        ],
      ),
    );
  }
}
