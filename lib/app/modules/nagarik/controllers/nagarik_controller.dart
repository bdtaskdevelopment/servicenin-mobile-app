import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../core/values/storage.dart';
import '../../../data/models/response/nagarik_response.dart';
import '../../../data/repositories/nagarik.repo.dart';
import '../../../data/services/storage.service.dart';
import '../../../routes/app_pages.dart';

IconData nagarikCategoryIcon(String icon) {
  switch (icon.toLowerCase()) {
    case 'road':
      return Icons.add_road_rounded;
    case 'garbage':
    case 'waste':
    case 'trash':
      return Icons.delete_outline_rounded;
    case 'drain':
    case 'drainage':
    case 'water':
      return Icons.waves_rounded;
    case 'light':
    case 'streetlight':
    case 'bulb':
      return Icons.lightbulb_outline_rounded;
    case 'water_supply':
    case 'tap':
      return Icons.water_drop_outlined;
    case 'mosquito':
    case 'health':
      return Icons.shield_outlined;
    case 'tree':
    case 'park':
      return Icons.park_outlined;
    case 'noise':
      return Icons.volume_up_outlined;
    default:
      return Icons.report_problem_outlined;
  }
}

class NagarikController extends GetxController {
  NagarikRepository get _repo => Get.find<NagarikRepository>();

  // ── Hotlines ────────────────────────────────────────────────────────
  NagarikHotlinesData? hotlines;
  bool loadingHotlines = false;

  /// The Nagarik Sheba hotline number, set by admin in the web dashboard
  /// (falls back to 16106 until it loads or if left empty).
  String get hotlineNumber {
    final h = hotlines?.dnccHotline ?? '';
    return h.isNotEmpty ? h : '16106';
  }

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
      final x = await _picker.pickImage(source: ImageSource.gallery,
          imageQuality: 70);
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
  final TextEditingController reportWard = TextEditingController();
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
    reportWard.clear();
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
    reportWard.clear();
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
    submittingReport = true;
    update();
    try {
      final payload = <String, dynamic>{
        'category': selectedCategoryKey,
        'title': reportTitle.text.trim(),
        'description': reportDescription.text.trim(),
        if (reportAddress.text.trim().isNotEmpty)
          'address': reportAddress.text.trim(),
        if (reportWard.text.trim().isNotEmpty)
          'ward_no': reportWard.text.trim(),
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
      final res = await _repo.verifyGrievance(g.id, payload,
          proofPhoto: verifyPhoto);
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

  Future<void> fetchMessages(String ticketId,
      {bool showLoader = false}) async {
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
    reportWard.dispose();
    ticketSubject.dispose();
    ticketDescription.dispose();
    chatInput.dispose();
    verifyComment.dispose();
    super.onClose();
  }
}
