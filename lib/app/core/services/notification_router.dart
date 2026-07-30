import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../data/models/response/notification_response.dart';
import '../../data/services/storage.service.dart';
import '../values/storage.dart';
import '../../modules/ambulance/bindings/ambulance_binding.dart';
import '../../modules/ambulance/controllers/ambulance_controller.dart';
import '../../modules/blood/bindings/blood_binding.dart';
import '../../modules/blood/controllers/blood_controller.dart';
import '../../modules/education/bindings/education_binding.dart';
import '../../modules/education/controllers/education_controller.dart';
import '../../modules/funeral/bindings/funeral_binding.dart';
import '../../modules/funeral/controllers/funeral_controller.dart';
import '../../modules/healthcare/bindings/healthcare_binding.dart';
import '../../modules/healthcare/controllers/appointments_controller.dart';
import '../../modules/home_service/bindings/home_service_binding.dart';
import '../../modules/home_service/controllers/home_service_controller.dart';
import '../../modules/nagarik/bindings/nagarik_binding.dart';
import '../../modules/nagarik/controllers/nagarik_controller.dart';
import '../../modules/physio/bindings/physio_binding.dart';
import '../../modules/physio/controllers/physio_controller.dart';
import '../../routes/app_pages.dart';

/// The single place that turns a notification — from ANY source (a tapped
/// FCM push, the foreground WebSocket feed, or a row on the notifications
/// list) — into a navigation to the right detail page, loaded by id.
///
/// Every backend notification carries the same triple: `type`,
/// `reference_type`, `reference_id`. The deep-link target is fully
/// determined by `(reference_type, reference_id)`. See
/// internal/services/notification_service.go.
///
/// Phase 1 wires home-service bookings and nagarik grievances. Other
/// reference types fall through to the notifications list until their
/// detail pages get id-based loaders.
class NotificationRouter {
  NotificationRouter._();
  static final NotificationRouter instance = NotificationRouter._();

  /// A deep-link that arrived before the app was ready to navigate (cold
  /// start, or before login). Delivered by [flushPending] once the app
  /// lands somewhere it can navigate from.
  _Target? _pending;

  /// Route a notification described by its raw fields. Safe to call from any
  /// source; no-ops on an empty reference.
  void handle({
    required String type,
    required String referenceType,
    required String referenceId,
  }) {
    final target = _resolve(
      referenceType: referenceType.trim().toLowerCase(),
      referenceId: referenceId.trim(),
    );
    if (target == null) return;

    if (!_canNavigate) {
      _pending = target; // deliver after login / once nav is ready
      return;
    }
    _go(target);
  }

  /// Route from a parsed [AppNotification] (WS feed / notifications list).
  void handleNotification(AppNotification n) => handle(
        type: n.type,
        referenceType: n.referenceType,
        referenceId: n.referenceId,
      );

  /// Route from an FCM `data` map (all values are strings).
  void handleFcmData(Map<String, dynamic> data) => handle(
        type: (data['type'] ?? '').toString(),
        referenceType: (data['reference_type'] ?? '').toString(),
        referenceId: (data['reference_id'] ?? '').toString(),
      );

  /// Deliver a deep-link that was queued while the app couldn't navigate.
  /// Called after login and once the authenticated home screen is ready.
  void flushPending() {
    final t = _pending;
    if (t == null || !_canNavigate) return;
    _pending = null;
    _go(t);
  }

  // ── internals ───────────────────────────────────────────────────────

  bool get _canNavigate {
    final token = StorageService.getString(StorageConstants.accessToken);
    return token.isNotEmpty && Get.key.currentState != null;
  }

  _Target? _resolve({
    required String referenceType,
    required String referenceId,
  }) {
    // Nothing to open by id — fall back to the notifications list so the tap
    // still does something.
    if (referenceId.isEmpty) {
      return const _Target(Routes.NOTIFICATIONS);
    }
    switch (referenceType) {
      // Home-service booking: transitions/ratings use `service_booking`,
      // admin reschedule / provider decline / finance use `booking`. Both
      // point at a ServiceBooking id — same detail page.
      case 'service_booking':
      case 'booking':
        return _Target(
          Routes.HS_DETAILS,
          referenceId: referenceId,
          load: (id) {
            if (!Get.isRegistered<HomeServiceController>()) {
              HomeServiceBinding().dependencies();
            }
            Get.find<HomeServiceController>().loadBookingById(id);
          },
        );
      case 'grievance':
        return _Target(
          Routes.NAGARIK_STATUS,
          referenceId: referenceId,
          load: (id) {
            if (!Get.isRegistered<NagarikController>()) {
              NagarikBinding().dependencies();
            }
            Get.find<NagarikController>().loadGrievanceById(id);
          },
        );
      case 'ambulance_booking':
        return _Target(
          Routes.AMBULANCE_CONFIRMED,
          referenceId: referenceId,
          load: (id) {
            if (!Get.isRegistered<AmbulanceController>()) {
              AmbulanceBinding().dependencies();
            }
            Get.find<AmbulanceController>().loadBookingById(id);
          },
        );
      case 'appointment':
        return _Target(
          Routes.HC_QUEUE,
          referenceId: referenceId,
          load: (id) {
            if (!Get.isRegistered<AppointmentsController>()) {
              HealthcareBinding().dependencies();
            }
            Get.find<AppointmentsController>().loadAppointmentById(id);
          },
        );
      case 'blood_request':
        return _Target(
          Routes.BLOOD_REQUEST_DETAIL,
          referenceId: referenceId,
          load: (id) {
            if (!Get.isRegistered<BloodController>()) {
              BloodBinding().dependencies();
            }
            Get.find<BloodController>().loadRequestById(id);
          },
        );
      // List-only modules — no per-item detail page, so land on the user's
      // list (which live-refreshes its rows when a status changes).
      case 'physio_appointment':
        return _Target(
          Routes.PHYSIO_SESSIONS,
          load: (_) {
            if (!Get.isRegistered<PhysioController>()) {
              PhysioBinding().dependencies();
            }
            Get.find<PhysioController>().fetchMySessions();
          },
        );
      case 'funeral_request':
        return _Target(
          Routes.FUNERAL_REQUESTS,
          load: (_) {
            if (!Get.isRegistered<FuneralController>()) {
              FuneralBinding().dependencies();
            }
            Get.find<FuneralController>().fetchMyRequests();
          },
        );
      case 'education_interest':
        return _Target(
          Routes.EDUCATION_INTERESTS,
          load: (_) {
            if (!Get.isRegistered<EducationController>()) {
              EducationBinding().dependencies();
            }
            Get.find<EducationController>().fetchMyInterests();
          },
        );
      default:
        // Unknown/unhandled reference type → land on the notifications list
        // rather than a dead tap.
        return const _Target(Routes.NOTIFICATIONS);
    }
  }

  void _go(_Target t) {
    Get.toNamed(t.route);
    final load = t.load;
    if (load == null) return;
    // Navigating triggers the route's binding, but that runs on the next
    // frame — wait for it so Get.find resolves the controller.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        load(t.referenceId ?? '');
      } catch (_) {
        // A missing controller/binding just means the page opened without a
        // fresh fetch; the user can pull-to-refresh. Never crash on a tap.
      }
    });
  }
}

class _Target {
  const _Target(this.route, {this.load, this.referenceId});
  final String route;
  final void Function(String id)? load;
  final String? referenceId;
}
