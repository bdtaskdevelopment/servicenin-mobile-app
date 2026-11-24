import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../core/mixins/live_refresh_mixin.dart';
import '../../../core/values/storage.dart';
import '../../../data/models/response/nagarik_response.dart';
import '../../../data/models/sn_place.dart';
import '../../../data/repositories/nagarik.repo.dart';
import '../../../data/services/storage.service.dart';
import '../../../routes/app_pages.dart';
import '../views/nagarik_address_search_view.dart';

/// Maps a grievance category's slug (e.g. "street_lights", "drainage") to
/// an icon that actually represents that issue. Takes the category's `key`
/// — the backend has never sent a separate `icon` field (only `emoji`,
/// which this app doesn't render), so passing the old `icon` field here
/// always fell through to the generic default below for every category.
/// Substring matching (not exact-match) so this stays correct even if an
/// admin renames a slug slightly (e.g. "road" vs "roads").
IconData nagarikCategoryIcon(String key) {
  final k = key.toLowerCase();
  if (k.contains('traffic') || k.contains('signal')) {
    return LucideIcons.trafficCone;
  }
  if (k.contains('light') || k.contains('bulb') || k.contains('lamp')) {
    return LucideIcons.lamp;
  }
  if (k.contains('road') || k.contains('street')) {
    return LucideIcons.construction;
  }
  if (k.contains('waste') || k.contains('garbage') || k.contains('trash')) {
    return LucideIcons.trash2;
  }
  if (k.contains('drain')) return LucideIcons.waves;
  if (k.contains('sewage') || k.contains('sewer')) {
    return LucideIcons.pipette;
  }
  if (k.contains('water') || k.contains('tap') || k.contains('supply')) {
    return LucideIcons.droplet;
  }
  if (k.contains('mosquito') || k.contains('pest')) {
    return LucideIcons.bug;
  }
  if (k.contains('illegal') ||
      k.contains('occupation') ||
      k.contains('encroach')) {
    return LucideIcons.ban;
  }
  if (k.contains('tree') || k.contains('park') || k.contains('garden')) {
    return LucideIcons.recycle;
  }
  return LucideIcons.info;
}

/// Tile background + icon color for a category, matched to the mockup's
/// per-category palette (same substring-matching order as [nagarikCategoryIcon]
/// so a tile's color and icon always agree).
(Color bg, Color fg) nagarikCategoryColor(String key) {
  final k = key.toLowerCase();
  if (k.contains('traffic') || k.contains('signal')) {
    return (const Color(0xFFFDEDF5), const Color(0xFFC22F79));
  }
  if (k.contains('light') || k.contains('bulb') || k.contains('lamp')) {
    return (const Color(0xFFFFF5DB), const Color(0xFFA16107));
  }
  if (k.contains('road') || k.contains('street')) {
    return (const Color(0xFFFFF4DE), const Color(0xFFCA913A));
  }
  if (k.contains('waste') || k.contains('garbage') || k.contains('trash')) {
    return (const Color(0xFFECF5E7), const Color(0xFF3F8A1F));
  }
  if (k.contains('drain')) {
    return (const Color(0xFFE6F4FA), const Color(0xFF0183C7));
  }
  if (k.contains('sewage') || k.contains('sewer')) {
    return (const Color(0xFFE6F5F4), const Color(0xFF249D8F));
  }
  if (k.contains('water') || k.contains('tap') || k.contains('supply')) {
    return (const Color(0xFFE7F1FD), const Color(0xFF1D6FD9));
  }
  if (k.contains('mosquito') || k.contains('pest')) {
    return (const Color(0xFFFFEFEF), const Color(0xFFE4484D));
  }
  if (k.contains('illegal') ||
      k.contains('occupation') ||
      k.contains('encroach')) {
    return (const Color(0xFFFFF1E7), const Color(0xFFD9580E));
  }
  if (k.contains('tree') || k.contains('park') || k.contains('garden')) {
    return (const Color(0xFFE9F5ED), const Color(0xFF17813E));
  }
  return (const Color(0xFFEDF1F5), const Color(0xFF3A4860));
}

class NagarikController extends GetxController with LiveRefreshMixin {
  NagarikRepository get _repo => Get.find<NagarikRepository>();

  // ── Live refresh (LiveRefreshMixin) ─────────────────────────────────
  // A grievance status change writes a notification (type `ticket`,
  // reference_type `grievance`) on `user:<id>`. When it's for the grievance
  // currently open, silently re-pull it so the status page updates itself
  // instead of the user having to pull-to-refresh.
  @override
  Set<String> get liveRefreshTypes => {'grievance'};
  @override
  String get liveRefreshId => selectedGrievance?.id ?? '';
  @override
  Future<void> onLiveRefresh() async {
    final id = selectedGrievance?.id ?? '';
    if (id.isEmpty) return;
    try {
      selectedGrievance = await _repo.fetchGrievance(id);
      update();
    } catch (_) {
      // Keep the last good copy on a transient failure.
    }
  }

  /// Deep-link entry: the notification router has already navigated to
  /// NAGARIK_STATUS; fetch the grievance fresh (it isn't in memory).
  Future<void> loadGrievanceById(String id) async {
    if (id.isEmpty) return;
    // Reset the verify form for the freshly-opened grievance, same as
    // openGrievance does when coming from the list.
    verifyStars = 5;
    verifyComment.clear();
    verifyPhoto = null;
    await _loadGrievanceDetail(id);
  }

  // ── Hotlines ────────────────────────────────────────────────────────
  NagarikHotlinesData? hotlines;
  bool loadingHotlines = false;

  /// The Nagarik Sheba hotline number, set by admin in the web dashboard
  /// (falls back to 16106 until it loads or if left empty).
  String get hotlineNumber {
    final h = hotlines?.dnccHotline ?? '';
    return h.isNotEmpty ? h : '16106';
  }

  /// Ready-to-open WhatsApp link for the hotline, empty when the admin
  /// hasn't configured one — the header's WhatsApp icon hides in that case.
  String get hotlineWhatsappUrl => hotlines?.dnccWhatsappUrl ?? '';

  /// Banner title/subtitle, admin-editable alongside the hotline number
  /// (falls back to the translated default copy until they load).
  String get bannerTitle {
    final t = hotlines?.bannerTitle ?? '';
    return t.isNotEmpty ? t : 'Your city, your responsibility'.tr;
  }

  String get bannerSubtitle {
    final t = hotlines?.bannerSubtitle ?? '';
    return t.isNotEmpty
        ? t
        : 'Report civic issues straight to DNCC officials · track to resolution'
            .tr;
  }

  // ── Report categories ───────────────────────────────────────────────
  List<NagarikReportCategory> categories = [];
  bool loadingCategories = false;

  // ── Grievances ──────────────────────────────────────────────────────
  List<NagarikGrievance> grievances = [];
  bool loadingGrievances = false;
  NagarikGrievance? selectedGrievance;
  bool loadingGrievanceDetail = false;

  // ── Grievance verification (citizen confirms a resolution) ──────────
  int verifyStars = 5;
  final TextEditingController verifyComment = TextEditingController();
  File? verifyPhoto;
  bool verifying = false;

  void setVerifyStars(int s) {
    verifyStars = s;
    update();
  }

  Future<void> pickVerifyPhoto() async {
    try {
      final x = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 70);
      if (x == null) return;
      verifyPhoto = File(x.path);
      update();
    } catch (_) {
      SnackHelper.error('ছবি নির্বাচন করা যায়নি');
    }
  }

  void removeVerifyPhoto() {
    verifyPhoto = null;
    update();
  }

  // ── Tickets ─────────────────────────────────────────────────────────
  List<NagarikTicket> tickets = [];
  bool loadingTickets = false;
  NagarikTicket? selectedTicket;
  bool loadingTicketDetail = false;

  // ── Report-an-issue form ────────────────────────────────────────────
  String selectedCategoryKey = '';
  final TextEditingController reportTitle = TextEditingController();
  final TextEditingController reportDescription = TextEditingController();
  final TextEditingController reportAddress = TextEditingController();

  /// DNCC has 54 wards; no backend ward-list endpoint exists yet, so this
  /// is the same static 1-54 range the ward-picker bottom sheet shows.
  static const String wardCorporationName = 'Dhaka North City Corporation';
  static const List<int> dnccWards = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38,
    39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54,
  ];
  int? selectedWard;

  void setWard(int ward) {
    selectedWard = ward;
    update();
  }

  /// Opens the address search page and, if the user picks a result, fills
  /// the address field — same shape as Funeral's pickAddress.
  Future<void> pickAddress() async {
    final place = await Get.to<SnPlace>(
        () => const NagarikAddressSearchView(title: 'Search address'));
    if (place == null) return;
    reportAddress.text = place.address.isNotEmpty ? place.address : place.label;
    update();
  }

  final List<Map<String, String>> priorities = const [
    {'label': 'Low', 'value': 'low'},
    {'label': 'Medium', 'value': 'medium'},
    {'label': 'Urgent', 'value': 'high'},
  ];
  int priorityIndex = 1;
  bool submittingReport = false;

  // Photo evidence (max 3).
  static const int maxReportImages = 3;
  final List<File> reportImages = [];
  final ImagePicker _picker = ImagePicker();

  void setCategoryKey(String key) {
    selectedCategoryKey = key;
    update();
  }

  Future<void> pickReportImages() async {
    if (reportImages.length >= maxReportImages) {
      SnackHelper.error('সর্বোচ্চ $maxReportImages টি ছবি যোগ করা যাবে');
      return;
    }
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 70);
      if (picked.isEmpty) return;
      final remaining = maxReportImages - reportImages.length;
      for (final x in picked.take(remaining)) {
        reportImages.add(File(x.path));
      }
      if (picked.length > remaining) {
        SnackHelper.error('সর্বোচ্চ $maxReportImages টি ছবি যোগ করা যাবে');
      }
      update();
    } catch (_) {
      SnackHelper.error('ছবি নির্বাচন করা যায়নি');
    }
  }

  void removeReportImage(int i) {
    if (i >= 0 && i < reportImages.length) {
      reportImages.removeAt(i);
      update();
    }
  }

  void setPriority(int i) {
    priorityIndex = i;
    update();
  }

  // ── Ticket-create form ──────────────────────────────────────────────
  final List<Map<String, String>> ticketCategories = const [
    {'label': 'Holding Tax', 'value': 'holding_tax'},
    {'label': 'Trade License', 'value': 'trade_license'},
    {'label': 'Birth Certificate', 'value': 'birth_certificate'},
    {'label': 'Tax Assessment', 'value': 'tax_assessment'},
    {'label': 'Other', 'value': 'other'},
  ];
  String ticketCategoryKey = 'holding_tax';
  final TextEditingController ticketSubject = TextEditingController();
  final TextEditingController ticketDescription = TextEditingController();
  int ticketPriorityIndex = 1;
  bool creatingTicket = false;

  void setTicketCategory(String key) {
    ticketCategoryKey = key;
    update();
  }

  void setTicketPriority(int i) {
    ticketPriorityIndex = i;
    update();
  }

  // ── Chat ────────────────────────────────────────────────────────────
  List<NagarikMessage> messages = [];
  bool loadingMessages = false;
  bool sendingMessage = false;
  final TextEditingController chatInput = TextEditingController();
  Timer? _poll;
  String? myUserId;

  @override
  void onInit() {
    super.onInit();
    myUserId = _currentUserId();
    fetchHotlines();
    fetchCategories();
    fetchGrievances();
    fetchTickets();
    startLiveRefresh();
  }

  // ── Loaders ─────────────────────────────────────────────────────────
  Future<void> fetchHotlines() async {
    loadingHotlines = true;
    update();
    try {
      hotlines = await _repo.fetchHotlines();
    } catch (_) {
    } finally {
      loadingHotlines = false;
      update();
    }
  }

  Future<void> fetchCategories() async {
    loadingCategories = true;
    update();
    try {
      categories = await _repo.fetchCategories();
      if (selectedCategoryKey.isEmpty && categories.isNotEmpty) {
        selectedCategoryKey = categories.first.key;
      }
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingCategories = false;
      update();
    }
  }

  Future<void> fetchGrievances() async {
    loadingGrievances = true;
    update();
    try {
      grievances = await _repo.fetchMyGrievances();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingGrievances = false;
      update();
    }
  }

  Future<void> fetchTickets() async {
    loadingTickets = true;
    update();
    try {
      tickets = await _repo.fetchMyTickets();
    } catch (_) {
    } finally {
      loadingTickets = false;
      update();
    }
  }

  // ── Hotlines: dial ──────────────────────────────────────────────────
  Future<void> callNumber(String number) async {
    final n = number.trim();
    if (n.isEmpty) return;
    try {
      await launchUrl(Uri.parse('tel:$n'),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      SnackHelper.error('ডায়াল করা যায়নি');
    }
  }

  /// Opens the pre-built `https://wa.me/...` link for the hotline's
  /// WhatsApp number (see hotlineWhatsappUrl).
  Future<void> openWhatsApp(String url) async {
    if (url.trim().isEmpty) return;
    try {
      await launchUrl(Uri.parse(url.trim()), mode: LaunchMode.externalApplication);
    } catch (_) {
      SnackHelper.error('হোয়াটসঅ্যাপ খোলা যায়নি');
    }
  }

  // ── Navigation ──────────────────────────────────────────────────────
  void openReports() {
    fetchGrievances();
    Get.toNamed(Routes.NAGARIK_REPORTS);
  }

  /// Open the standalone support-tickets list (surfaced like My reports).
  void openTickets() {
    fetchTickets();
    Get.toNamed(Routes.NAGARIK_TICKETS);
  }

  void reportIssue() {
    if (selectedCategoryKey.isEmpty && categories.isNotEmpty) {
      selectedCategoryKey = categories.first.key;
    }
    priorityIndex = 1;
    reportTitle.clear();
    reportDescription.clear();
    reportAddress.clear();
    selectedWard = null;
    reportImages.clear();
    update();
    Get.toNamed(Routes.NAGARIK_REPORT_ISSUE);
  }

  void openCategory(String key) {
    selectedCategoryKey = key;
    priorityIndex = 1;
    reportTitle.clear();
    reportDescription.clear();
    reportAddress.clear();
    selectedWard = null;
    reportImages.clear();
    update();
    Get.toNamed(Routes.NAGARIK_REPORT_ISSUE);
  }

  // ── File a grievance ────────────────────────────────────────────────
  Future<void> submitReport() async {
    if (submittingReport) return;
    if (selectedCategoryKey.isEmpty) {
      SnackHelper.error('একটি ক্যাটাগরি নির্বাচন করুন');
      return;
    }
    if (reportTitle.text.trim().isEmpty) {
      SnackHelper.error('সমস্যার শিরোনাম দিন');
      return;
    }
    if (reportDescription.text.trim().isEmpty) {
      SnackHelper.error('সমস্যার বিবরণ দিন');
      return;
    }
    if (selectedWard == null) {
      SnackHelper.error('ওয়ার্ড নম্বর নির্বাচন করুন');
      return;
    }
    submittingReport = true;
    update();
    try {
      final payload = <String, dynamic>{
        'category': selectedCategoryKey,
        'title': reportTitle.text.trim(),
        'description': reportDescription.text.trim(),
        if (reportAddress.text.trim().isNotEmpty)
          'address': reportAddress.text.trim(),
        'ward_no': selectedWard.toString(),
        'priority': priorities[priorityIndex]['value'],
      };
      final filed = await _repo.fileGrievance(payload, images: reportImages);
      selectedGrievance = filed;
      grievances.insert(0, filed);
      reportImages.clear();
      update();
      Get.offNamed(Routes.NAGARIK_STATUS);
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      submittingReport = false;
      update();
    }
  }

  // ── Grievance detail ────────────────────────────────────────────────
  void openGrievance(NagarikGrievance g) {
    selectedGrievance = g;
    // Reset the verification form for the freshly-opened grievance.
    verifyStars = 5;
    verifyComment.clear();
    verifyPhoto = null;
    update();
    Get.toNamed(Routes.NAGARIK_STATUS);
    _loadGrievanceDetail(g.id);
  }

  Future<void> _loadGrievanceDetail(String id) async {
    if (id.isEmpty) return;
    loadingGrievanceDetail = true;
    update();
    try {
      selectedGrievance = await _repo.fetchGrievance(id);
    } catch (_) {
    } finally {
      loadingGrievanceDetail = false;
      update();
    }
  }

  /// Pull-to-refresh on the report status page.
  Future<void> refreshGrievanceDetail() async {
    final id = selectedGrievance?.id;
    if (id == null || id.isEmpty) return;
    await _loadGrievanceDetail(id);
  }

  /// Reporter confirms (or rejects) a resolved grievance.
  /// `confirmed: true` → fixed; `false` → not fixed.
  Future<void> submitVerification({required bool confirmed}) async {
    final g = selectedGrievance;
    if (g == null || verifying) return;
    verifying = true;
    update();
    try {
      final payload = <String, dynamic>{
        'confirmed': confirmed,
        if (confirmed) 'stars': verifyStars,
        if (verifyComment.text.trim().isNotEmpty)
          'comment': verifyComment.text.trim(),
      };
      final res =
          await _repo.verifyGrievance(g.id, payload, proofPhoto: verifyPhoto);
      if (res.success) {
        SnackHelper.success(res.message.isNotEmpty
            ? res.message
            : (confirmed ? 'Thanks for verifying' : 'Marked as not fixed'));
        verifyComment.clear();
        verifyPhoto = null;
        verifyStars = 5;
        await _loadGrievanceDetail(g.id); // refresh verified/can_verify flags
        fetchGrievances(); // refresh list badges
      } else {
        SnackHelper.error(res.message);
      }
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      verifying = false;
      update();
    }
  }

  // ── Create a support ticket ─────────────────────────────────────────
  void newTicket() {
    ticketCategoryKey = ticketCategories.first['value']!;
    ticketSubject.clear();
    ticketDescription.clear();
    ticketPriorityIndex = 1;
    update();
    Get.toNamed(Routes.NAGARIK_TICKET_CREATE);
  }

  Future<void> submitTicket() async {
    if (creatingTicket) return;
    if (ticketSubject.text.trim().isEmpty) {
      SnackHelper.error('বিষয় দিন');
      return;
    }
    if (ticketDescription.text.trim().isEmpty) {
      SnackHelper.error('বিস্তারিত লিখুন');
      return;
    }
    creatingTicket = true;
    update();
    try {
      final payload = <String, dynamic>{
        'category': ticketCategoryKey,
        'subject': ticketSubject.text.trim(),
        'description': ticketDescription.text.trim(),
        'priority': priorities[ticketPriorityIndex]['value'],
      };
      final ticket = await _repo.createTicket(payload);
      tickets.insert(0, ticket);
      selectedTicket = ticket;
      update();
      // Replace the create screen with the ticket chat.
      Get.offNamed(Routes.NAGARIK_CHAT);
      _startChat(ticket.id);
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      creatingTicket = false;
      update();
    }
  }

  // ── Open ticket chat ────────────────────────────────────────────────
  void openTicket(NagarikTicket t) {
    selectedTicket = t;
    messages = t.messages;
    update();
    Get.toNamed(Routes.NAGARIK_CHAT);
    _startChat(t.id);
  }

  // ── View ticket details (GET /tickets/:id) ──────────────────────────
  void viewTicket(NagarikTicket t) {
    selectedTicket = t;
    update();
    Get.toNamed(Routes.NAGARIK_TICKET_DETAIL);
    _loadTicketDetail(t.id);
  }

  Future<void> _loadTicketDetail(String id) async {
    if (id.isEmpty) return;
    loadingTicketDetail = true;
    update();
    try {
      selectedTicket = await _repo.fetchTicket(id);
    } catch (_) {
    } finally {
      loadingTicketDetail = false;
      update();
    }
  }

  void _startChat(String ticketId) {
    fetchMessages(ticketId, showLoader: messages.isEmpty);
    _poll?.cancel();
    _poll = Timer.periodic(
        const Duration(seconds: 3), (_) => fetchMessages(ticketId));
  }

  void stopChat() {
    _poll?.cancel();
    _poll = null;
  }

  Future<void> fetchMessages(String ticketId, {bool showLoader = false}) async {
    if (showLoader) {
      loadingMessages = true;
      update();
    }
    try {
      final fetched = await _repo.fetchTicketMessages(ticketId);
      if (!_sameThread(fetched, messages)) {
        messages = fetched;
        update();
      }
    } catch (_) {
    } finally {
      if (showLoader) {
        loadingMessages = false;
        update();
      }
    }
  }

  Future<void> sendMessage() async {
    final text = chatInput.text.trim();
    final ticket = selectedTicket;
    if (text.isEmpty || ticket == null || sendingMessage) return;
    sendingMessage = true;
    chatInput.clear();
    update();
    try {
      final sent = await _repo.sendTicketMessage(ticket.id, text);
      messages = [...messages, sent];
      update();
      // Reconcile with server (gets sender/profile populated).
      fetchMessages(ticket.id);
    } catch (e) {
      chatInput.text = text;
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      sendingMessage = false;
      update();
    }
  }

  bool isMine(NagarikMessage m) => m.senderId == myUserId;

  bool _sameThread(List<NagarikMessage> a, List<NagarikMessage> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  String? _currentUserId() {
    final raw = StorageService.read(StorageConstants.userInfo);
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final map = jsonDecode(raw);
        if (map is Map) return map['id']?.toString();
      } catch (_) {}
    }
    return null;
  }

  @override
  void onClose() {
    stopChat();
    reportTitle.dispose();
    reportDescription.dispose();
    reportAddress.dispose();
    ticketSubject.dispose();
    ticketDescription.dispose();
    chatInput.dispose();
    verifyComment.dispose();
    super.onClose();
  }
}
