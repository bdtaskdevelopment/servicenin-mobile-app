import 'package:get/get.dart';

/// Canonical home-service job-progress step keys, in order — mirrors the
/// provider app's own stepper (job_detail_view.dart's `_canonicalSteps`) and
/// the backend's `ServiceStatusRank` ordering, so the citizen app shows the
/// exact same phases the provider and admin see instead of a shorter list.
const List<String> kHomeServiceCanonicalSteps = [
  'assigned',
  'accepted',
  'on_the_way',
  'arrived',
  'in_progress',
  'completed',
];

/// English labels for the canonical steps — kept distinct from the Bangla
/// map below rather than run through the shared `.tr` lookup, because
/// 'Assigned'/'Accepted'/'Completed' are also used as generic translation
/// keys elsewhere in the app (blood/ambulance/job statuses, etc.); reusing
/// them here would silently change THEIR Bangla text too.
const Map<String, String> _enStepLabels = {
  'assigned': 'Assigned',
  'accepted': 'Accepted',
  'on_the_way': 'On the way',
  'arrived': 'Reached customer',
  'in_progress': 'Work in progress',
  'completed': 'Completed',
};

/// Bangla wording specifically for the home-service status stepper, as given
/// by the product owner — phrased from the technician's action ("টেকনিশিয়ান
/// রওনা হয়েছেন") rather than a literal translation of the English label.
const Map<String, String> _bnStepLabels = {
  'assigned': 'টেকনিশিয়ানকে অ্যাসাইন করা হয়েছে',
  'accepted': 'টেকনিশিয়ান অ্যাসাইনমেন্ট গ্রহণ করেছেন',
  'on_the_way': 'টেকনিশিয়ান রওনা হয়েছেন',
  'arrived': 'টেকনিশিয়ান পৌঁছেছেন',
  'in_progress': 'কাজ চলছে',
  'completed': 'কাজ সম্পন্ন হয়েছে',
};

/// Forward-only rank, matching the backend's `ServiceStatusRank` — used to
/// decide which canonical steps are done/active/pending for a given status.
/// `cancelled`/`declined` return -1 (off the forward path, handled as their
/// own banner rather than a stepper position).
int homeServiceStatusRank(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return 0;
    case 'assigned':
      return 1;
    case 'accepted':
      return 2;
    case 'on_the_way':
      return 3;
    case 'arrived':
      return 4;
    case 'in_progress':
      return 5;
    case 'completed':
      return 6;
    case 'closed':
      return 7;
    default:
      return -1;
  }
}

/// Full-sentence label for the status STEPPER only (see
/// `HomeServiceStatusStepper`) — each row has its own line, so the longer
/// technician-centric phrasing reads fine there. For the 6 canonical steps
/// this uses fixed English/Bangla wording (see above) instead of the shared
/// `.tr` map, so it can carry its own Bangla phrasing without touching any
/// other feature's translation of the same English word. Anything else
/// (e.g. `pending`, `cancelled`) falls back to `homeServiceStatusLabel`.
String homeServiceStepLabel(String status) {
  if (status.isEmpty) return homeServiceStatusLabel(status);
  final lower = status.toLowerCase();
  final isBn = Get.locale?.languageCode == 'bn';
  final known = isBn ? _bnStepLabels[lower] : _enStepLabels[lower];
  return known ?? homeServiceStatusLabel(status);
}

/// Short label for a status, for compact UI (the status chip/pill shown on
/// list rows and headers) where the stepper's full sentence wording above
/// would overflow. Generic underscore→space, capitalize-first-letter
/// formatting run through `.tr`, so it keeps using whatever short
/// translation already exists for that word elsewhere in the app (e.g.
/// 'Accepted' → 'গৃহীত') rather than introducing a second, longer phrasing
/// for the same status in a context that has no room for it.
String homeServiceStatusLabel(String status) {
  if (status.isEmpty) return 'Pending'.tr;
  return (status[0].toUpperCase() + status.substring(1).replaceAll('_', ' '))
      .tr;
}
