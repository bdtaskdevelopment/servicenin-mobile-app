import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/values/app_colors.dart';
import '../data/models/sn_service.dart';

/// A single "All Services" grid card: bordered white box with a tinted icon,
/// a label and an optional count badge.
class SnServiceTile extends StatelessWidget {
  const SnServiceTile({super.key, required this.service, this.onTap});

  final SnService service;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEFF2)),
        ),
        child: Stack(
          children: [
            // Positioned.fill gives the content tight (bounded) height so the
            // label can't push outside the cell on small screens — it
            // ellipsises within the available space instead.
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(service.icon, color: service.color, size: 26),
                    const SizedBox(height: 6),
                    // Single long words (Ambulance, Information) use one line +
                    // ellipsis so they never break mid-word; two-word names
                    // (Home Service, Nagarik Sheba) wrap cleanly to 2 lines.
                    Flexible(
                      child: Builder(
                        builder: (_) {
                          final label = service.name.tr;
                          final multiWord = label.trim().contains(' ');
                          return Text(
                            label,
                            textAlign: TextAlign.center,
                            maxLines: multiWord ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                              height: 1.1,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (service.badge != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                  decoration: const BoxDecoration(
                    color: AppColors.brandOrange,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${service.badge}',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
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
