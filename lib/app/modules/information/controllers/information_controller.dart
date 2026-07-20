import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../data/models/response/info_response.dart';
import '../../../data/repositories/info.repo.dart';
import '../../../routes/app_pages.dart';

class Guide {
  const Guide({
    required this.title,
    required this.source,
    required this.meta,
    required this.category,
    required this.icon,
    required this.steps,
    required this.helpText,
  });

  final String title;
  final String source;
  final String meta;
  final String category;
  final IconData icon;
  final List<String> steps;
  final String helpText;
}

class Hotline {
  const Hotline(this.number, this.label, this.icon,
      [this.color = const Color(0xFF6366F1)]);
  final String number;
  final String label;
  final IconData icon;
  final Color color;
}

class GuideCategory {
  const GuideCategory(this.name, this.count, this.icon);
  final String name;
  final int count;
  final IconData icon;
}

class PopularGuide {
  const PopularGuide(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final IconData icon;
}

class InformationController extends GetxController {
  InfoRepository get _infoRepo => Get.find<InfoRepository>();

  bool detailLoading = false;

  // ── Emergency contacts from /api/v1/info/emergency ────────────────
  // (kept for the National Emergency hero + the separate Hotlines screen)
  List<InfoEntry> emergencyEntries = [];
  bool loadingEmergency = false;

  /// The hero "National Emergency" entry — preferring the emergency feed,
  /// then the directory.
  InfoEntry? get nationalEmergency {
    for (final e in emergencyEntries) {
      if (e.isNationalEmergency) return e;
    }
    for (final e in directoryEntries) {
      if (e.isNationalEmergency) return e;
    }
    return null;
  }

  /// Looks up a domain's label/emoji by its key, for rendering an entry's
  /// category icon/pill. Returns null if [domains] hasn't loaded yet or the
  /// key doesn't match any active domain.
  InfoDomain? domainFor(String key) {
    for (final d in domains) {
      if (d.key == key) return d;
    }
    return null;
  }

  /// Emergency contacts minus the national-emergency hero (used by the
  /// separate "Hotlines" screen).
  List<InfoEntry> get emergencyCards =>
      emergencyEntries.where((e) => !e.isNationalEmergency).toList();

  // ── Categories ("domains") from /api/v1/info/domains ───────────────
  List<InfoDomain> domains = [];
  bool loadingDomains = false;

  /// The domain the category-list page is currently scoped to; null means
  /// either "All" or a plain search (see [categoryListTitle]).
  InfoDomain? selectedDomainForList;

  String? get selectedDomainKey => selectedDomainForList?.key;

  /// Header title for the category-list page.
  String get categoryListTitle =>
      selectedDomainForList?.label ?? (search.isNotEmpty ? 'Search results'.tr : 'All'.tr);

  /// Opens the category-list page scoped to [domain]. Clears any leftover
  /// search text so the list starts as a clean category browse.
  void openInfoCategory(InfoDomain domain) {
    selectedDomainForList = domain;
    searchCtrl.clear();
    update();
    fetchDirectory(reset: true);
    Get.toNamed(Routes.INFORMATION_CATEGORY);
  }

  /// Opens the category-list page showing every active entry (no domain
  /// filter) — the grid's "All" tile.
  void openAllInfo() {
    selectedDomainForList = null;
    searchCtrl.clear();
    update();
    fetchDirectory(reset: true);
    Get.toNamed(Routes.INFORMATION_CATEGORY);
  }

  /// Opens the category-list page for a free-text search (from the main
  /// page's search bar) — no domain filter, keeps the typed query.
  void openSearchResults() {
    selectedDomainForList = null;
    update();
    fetchDirectory(reset: true);
    Get.toNamed(Routes.INFORMATION_CATEGORY);
  }

  // ── Directory (paginated, category + search filtered) ──────────────
  List<InfoEntry> directoryEntries = [];
  bool loadingDirectory = false;
  bool loadingMoreDirectory = false;
  bool hasMoreDirectory = true;
  int _page = 1;
  static const _limit = 10;
  final TextEditingController searchCtrl = TextEditingController();
  String get search => searchCtrl.text.trim();
  Timer? _searchDebounce;

  /// Directory entries minus the national-emergency hero (already shown
  /// separately at the top of the page).
  List<InfoEntry> get directoryCards =>
      directoryEntries.where((e) => !e.isNationalEmergency).toList();

  @override
  void onInit() {
    super.onInit();
    fetchDomains();
    fetchEmergency();
  }

  Future<void> fetchDomains() async {
    loadingDomains = true;
    update();
    try {
      domains = await _infoRepo.fetchDomains();
    } catch (_) {
    } finally {
      loadingDomains = false;
      update();
    }
  }

  /// Search-bar submit while already on the category-list page — refetches
  /// in place (no navigation). The main page's search bar uses
  /// [openSearchResults] instead, which navigates first.
  void onSearchSubmitted(String _) {
    _searchDebounce?.cancel();
    fetchDirectory(reset: true);
  }

  /// Debounced live search as the user types — category-list page only.
  void onSearchChanged(String _) {
    update(); // refresh the clear (×) affordance
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
        const Duration(milliseconds: 400), () => fetchDirectory(reset: true));
  }

  /// Main page's search bar just tracks the clear (×) affordance — it
  /// doesn't fetch anything itself; submitting navigates via
  /// [openSearchResults] instead.
  void onMainSearchChanged(String _) => update();

  void clearSearch() {
    searchCtrl.clear();
    _searchDebounce?.cancel();
    fetchDirectory(reset: true);
  }

  /// GET /api/v1/info — load the directory list.
  Future<void> fetchDirectory({bool reset = false}) async {
    if (reset) {
      _page = 1;
      hasMoreDirectory = true;
    }
    loadingDirectory = true;
    update();
    try {
      final list = await _infoRepo.fetchDirectory(
        page: _page,
        limit: _limit,
        domain: selectedDomainKey,
        search: search,
      );
      directoryEntries = list;
      hasMoreDirectory = list.length >= _limit;
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingDirectory = false;
      update();
    }
  }

  Future<void> loadMoreDirectory() async {
    if (loadingMoreDirectory || loadingDirectory || !hasMoreDirectory) return;
    loadingMoreDirectory = true;
    update();
    try {
      _page += 1;
      final list = await _infoRepo.fetchDirectory(
        page: _page,
        limit: _limit,
        domain: selectedDomainKey,
        search: search,
      );
      directoryEntries.addAll(list);
      hasMoreDirectory = list.length >= _limit;
    } catch (_) {
      _page -= 1;
    } finally {
      loadingMoreDirectory = false;
      update();
    }
  }

  /// GET /api/v1/info/emergency — load emergency contacts.
  Future<void> fetchEmergency() async {
    loadingEmergency = true;
    update();
    try {
      emergencyEntries = await _infoRepo.fetchEmergency();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingEmergency = false;
      update();
    }
  }

  /// GET /api/v1/info/{id} — fetch a single entry's full details.
  Future<InfoEntry?> fetchInfoById(String id) async {
    detailLoading = true;
    update();
    try {
      return await _infoRepo.fetchById(id);
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
      return null;
    } finally {
      detailLoading = false;
      update();
    }
  }

  // ── Detail page (opened from a directory card tap) ──────────────────
  InfoEntry? selected;

  /// Opens the detail page immediately with the list's copy, then refreshes
  /// it in the background with the fuller single-entry response.
  void openInfo(InfoEntry entry) async {
    selected = entry;
    update();
    Get.toNamed(Routes.INFORMATION_DETAIL);
    final fresh = await fetchInfoById(entry.id);
    if (fresh != null) {
      selected = fresh;
      update();
    }
  }

  /// Open the phone dialer for a hotline number.
  Future<void> callHotline(String number) async {
    final digits = number.trim();
    if (digits.isEmpty) return;
    final uri = Uri.parse('tel:$digits');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      SnackHelper.error('ডায়াল করা যায়নি');
    }
  }

  /// Open a website/map link externally (browser or the relevant app).
  Future<void> openExternal(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;
    try {
      final ok = await launchUrl(Uri.parse(trimmed),
          mode: LaunchMode.externalApplication);
      if (!ok) SnackHelper.error('খুলতে সমস্যা হয়েছে');
    } catch (_) {
      SnackHelper.error('খুলতে সমস্যা হয়েছে');
    }
  }

  /// Compose an email to the given address.
  Future<void> openEmail(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return;
    await openExternal('mailto:$trimmed');
  }

  /// Open a WhatsApp chat with the given number.
  Future<void> openWhatsapp(String number) async {
    final digits = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return;
    await openExternal('https://wa.me/$digits');
  }

  final List<Hotline> hotlines = const [
    Hotline('16263', 'Health (Shastho)', Icons.medical_services_outlined),
    Hotline('109', 'Women & Children', Icons.female_rounded),
    Hotline('106', 'Anti-Corruption', Icons.flag_outlined),
    Hotline('16106', 'DNCC Hotline', Icons.account_balance_outlined),
  ];

  /// Full list shown on the "Emergency hotlines" screen.
  final List<Hotline> allHotlines = const [
    Hotline('16263', 'Health (Shastho)', Icons.medical_services_outlined),
    Hotline('109', 'Women & Children', Icons.female_rounded),
    Hotline('106', 'Anti-Corruption', Icons.flag_outlined),
    Hotline('16106', 'DNCC Hotline', Icons.account_balance_outlined),
    Hotline('102', 'Fire Service', Icons.local_fire_department_rounded,
        Color(0xFF1E2A4A)),
    Hotline('16216', 'WASA (Water)', Icons.waves_rounded, Color(0xFF3B82F6)),
    Hotline('16120', 'Titas Gas', Icons.bolt_rounded, Color(0xFF6366F1)),
  ];

  final List<GuideCategory> categories = const [
    GuideCategory('Utility & Bills', 12, Icons.bolt_rounded),
    GuideCategory('Govt. Services', 18, Icons.account_balance_rounded),
    GuideCategory('Health & Safety', 9, Icons.medical_services_rounded),
    GuideCategory('Transport', 7, Icons.location_on_rounded),
  ];

  final List<PopularGuide> popular = const [
    PopularGuide('How to pay holding tax online',
        'DNCC · step-by-step · 4 min', Icons.lightbulb_outline_rounded),
  ];

  // ── Guides ───────────────────────────────────────────────────────
  final List<Guide> guides = const [
    Guide(
      title: 'Report a power outage',
      source: 'DPDC / DESCO',
      meta: '2 min read · updated Mar 2026',
      category: 'Utility & Bills',
      icon: Icons.lightbulb_outline_rounded,
      steps: [
        'Note your consumer/meter number before calling.',
        'Report outages to your local DPDC or DESCO office, or via their hotline.',
        'Planned maintenance schedules are announced a day in advance.',
      ],
      helpText: 'Call DNCC hotline 16106',
    ),
    Guide(
      title: 'How to pay holding tax online',
      source: 'DNCC',
      meta: '4 min read · updated Mar 2026',
      category: 'Govt. Services',
      icon: Icons.lightbulb_outline_rounded,
      steps: [
        'Create or log in to your DNCC e-services account.',
        'Search your holding number to view the assessed amount.',
        'Pay via card or mobile banking and save the receipt.',
      ],
      helpText: 'Call DNCC hotline 16106',
    ),
  ];

  GuideCategory? selectedCategory;
  Guide? selectedGuide;

  List<Guide> get categoryGuides =>
      guides.where((g) => g.category == selectedCategory?.name).toList();

  void openCategory(GuideCategory c) {
    selectedCategory = c;
    update();
    Get.toNamed(Routes.INFORMATION_GUIDES);
  }

  void openGuide(Guide g) {
    selectedGuide = g;
    update();
    Get.toNamed(Routes.INFORMATION_GUIDE_DETAIL);
  }

  void openGuideByTitle(String title) {
    openGuide(guides.firstWhere((g) => g.title == title,
        orElse: () => guides.first));
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchCtrl.dispose();
    super.onClose();
  }
}
