import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../data/models/response/blood_response_response.dart';
import '../../../data/repositories/blood.repo.dart';
import '../../../routes/app_pages.dart';
import 'blood_controller.dart';

/// Drives "ডোনেশন যোগ করুন" (log a completed donation, with photos) —
/// POST /blood/donations, multipart. Mirrors NagarikController's
/// photo-picker pattern (max 3 images, ImagePicker.pickMultiImage).
class AddDonationController extends GetxController {
  static const int maxPhotos = 3;
  final List<File> photos = [];
  final ImagePicker _picker = ImagePicker();

  /// Which of the viewer's own responded-to requests this donation is for
  /// — optional; left null for a donation that happened entirely outside
  /// the app.
  BloodResponseEntry? linkedResponse;

  DateTime donatedAt = DateTime.now();
  int bags = 1;
  final TextEditingController feeling = TextEditingController();
  final TextEditingController suggestion = TextEditingController();
  bool consentMediaUse = true;
  bool busy = false;

  List<BloodResponseEntry> get myDonatedResponses =>
      Get.find<BloodController>().myResponses.where((r) => r.status == 'donated').toList();

  Future<void> pickPhotos() async {
    if (photos.length >= maxPhotos) {
      SnackHelper.error('সর্বোচ্চ $maxPhotos টি ছবি যোগ করা যাবে');
      return;
    }
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 70);
      if (picked.isEmpty) return;
      final remaining = maxPhotos - photos.length;
      for (final x in picked.take(remaining)) {
        photos.add(File(x.path));
      }
      update();
    } catch (_) {
      SnackHelper.error('ছবি নির্বাচন করা যায়নি');
    }
  }

  void removePhoto(int i) {
    if (i >= 0 && i < photos.length) {
      photos.removeAt(i);
      update();
    }
  }

  void setLinkedResponse(BloodResponseEntry? r) {
    linkedResponse = r;
    update();
  }

  void setDonatedAt(DateTime d) {
    donatedAt = d;
    update();
  }

  void incBags() {
    if (bags < 3) {
      bags++;
      update();
    }
  }

  void decBags() {
    if (bags > 1) {
      bags--;
      update();
    }
  }

  void setConsent(bool v) {
    consentMediaUse = v;
    update();
  }

  Future<void> submit() async {
    if (busy) return;
    busy = true;
    update();
    try {
      final payload = <String, dynamic>{
        'request_id': linkedResponse?.requestId ?? '',
        'donated_at': donatedAt.toUtc().toIso8601String(),
        'bags': bags,
        'feeling': feeling.text.trim(),
        'suggestion': suggestion.text.trim(),
        'consent_media_use': consentMediaUse,
      };
      final res = await Get.find<BloodRepository>().logDonation(payload, photos);
      busy = false;
      update();
      if (res.success) {
        SnackHelper.success(res.message);
        await Get.find<BloodController>().fetchMyDonations();
        // Get.until (not Get.back()) — a plain back() after an async gap has
        // been observed to silently no-op here, same as the edit-request flow.
        Get.until((route) => route.settings.name == Routes.BLOOD_MY_RESPONSES);
      } else {
        SnackHelper.error(res.message);
      }
    } catch (e) {
      busy = false;
      update();
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  void onClose() {
    feeling.dispose();
    suggestion.dispose();
    super.onClose();
  }
}
