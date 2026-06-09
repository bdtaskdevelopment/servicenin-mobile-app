import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../data/models/response/matchmaking_response.dart';
import '../../../data/repositories/matchmaking.repo.dart';
import '../../../routes/app_pages.dart';

/// Humanise an enum-ish value: never_married → "Never married",
/// 60k_100k → "60k 100k".
String mmHumanize(String v) {
  if (v.isEmpty) return '';
  final s = v.replaceAll('_', ' ');
  return s[0].toUpperCase() + s.substring(1);
}

enum MmFieldType { text, number, dropdown, multiline }

class MmField {
  const MmField(this.key, this.label, this.type,
      {this.required = false, this.optionsKey = ''});
  final String key;
  final String label;
  final MmFieldType type;
  final bool required;
  final String optionsKey; // which option list feeds a dropdown
}

class MatchmakingController extends GetxController {
  MatchmakingRepository get _repo => Get.find<MatchmakingRepository>();

  // ── Home: suggestions ───────────────────────────────────────────────
  List<MmSuggestion> suggestions = [];
  bool loadingSuggestions = false;

  // ── My profile ──────────────────────────────────────────────────────
  MmProfile? myProfile;
  bool loadingMyProfile = false;
  bool get hasProfile => myProfile != null;
  int get completion {
    final p = myProfile;
    if (p == null) return 0;
    const keys = [
      'full_name', 'age', 'gender', 'religion', 'profession', 'education',
      'height_cm', 'income_range', 'father_name', 'mother_name',
      'family_type', 'date_of_birth', 'birth_place', 'location', 'bio',
    ];
    final filled = keys.where((k) => p.dyn(k).isNotEmpty && p.dyn(k) != '0').length;
    return ((filled / keys.length) * 100).round();
  }

  // ── Categories + biodata fields (form options) ──────────────────────
  MmCategories? categories;
  MmBiodataFields? fields;

  // ── Selected profile (detail) ───────────────────────────────────────
  MmProfile? selected;
  bool loadingSelected = false;
  bool sendingInterest = false;

  // ── Interests / matches ─────────────────────────────────────────────
  List<MmInterest> received = [];
  List<MmInterest> sent = [];
  List<MmMatchEntry> matches = [];
  bool loadingReceived = false;
  bool loadingSent = false;
  bool loadingMatches = false;
  bool responding = false;

  // ── Biodata form state ──────────────────────────────────────────────
  final List<MmField> bioFields = const [
    MmField('full_name', 'Full name', MmFieldType.text, required: true),
    MmField('age', 'Age', MmFieldType.number, required: true),
    MmField('gender', 'Gender', MmFieldType.dropdown,
        required: true, optionsKey: 'genders'),
    MmField('religion', 'Religion', MmFieldType.dropdown,
        required: true, optionsKey: 'religions'),
    MmField('profession', 'Profession', MmFieldType.dropdown,
        required: true, optionsKey: 'professions'),
    MmField('education', 'Education', MmFieldType.text, required: true),
    MmField('marital_status', 'Marital status', MmFieldType.dropdown,
        optionsKey: 'marital_status'),
    MmField('height_cm', 'Height (cm)', MmFieldType.number),
    MmField('income_range', 'Income range', MmFieldType.dropdown,
        optionsKey: 'income_ranges'),
    MmField('family_type', 'Family type', MmFieldType.dropdown,
        optionsKey: 'family_types'),
    MmField('father_name', "Father's name", MmFieldType.text),
    MmField('mother_name', "Mother's name", MmFieldType.text),
    MmField('date_of_birth', 'Date of birth (YYYY-MM-DD)', MmFieldType.text),
    MmField('birth_place', 'Birth place', MmFieldType.text),
    MmField('location', 'Location', MmFieldType.text),
    MmField('bio', 'About / Bio', MmFieldType.multiline),
  ];

  final Map<String, TextEditingController> _text = {};
  final Map<String, String> choice = {};
  bool savingBiodata = false;

  TextEditingController textCtrl(String key) =>
      _text.putIfAbsent(key, () => TextEditingController());

  void setChoice(String key, String value) {
    choice[key] = value;
    update();
  }

  List<String> optionsFor(String optionsKey) {
    final f = fields;
    switch (optionsKey) {
      case 'genders':
        return f?.genders ?? const [];
      case 'religions':
        return f?.religions ?? const [];
      case 'marital_status':
        return f?.maritalStatus ?? const [];
      case 'income_ranges':
        return f?.incomeRanges ?? const [];
      case 'family_types':
        return f?.familyTypes ?? const [];
      case 'professions':
        return categories?.professions.map((p) => p.label).toList() ?? const [];
      default:
        return const [];
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchSuggestions();
    fetchMyProfile();
    _loadFormOptions();
  }

  Future<void> _loadFormOptions() async {
    try {
      categories = await _repo.fetchCategories();
      fields = await _repo.fetchBiodataFields();
      update();
    } catch (_) {}
  }

  Future<void> fetchSuggestions() async {
    loadingSuggestions = true;
    update();
    try {
      suggestions = await _repo.fetchSuggestions();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingSuggestions = false;
      update();
    }
  }

  Future<void> fetchMyProfile() async {
    loadingMyProfile = true;
    update();
    try {
      myProfile = await _repo.fetchMyProfile();
    } catch (_) {
    } finally {
      loadingMyProfile = false;
      update();
    }
  }

  // ── Navigation ──────────────────────────────────────────────────────
  void openInterests() {
    fetchReceived();
    fetchSent();
    fetchMatches();
    Get.toNamed(Routes.MATCHMAKING_INTERESTS);
  }

  void openBiodata() {
    if (categories == null || fields == null) _loadFormOptions();
    _prefillForm();
    Get.toNamed(Routes.MATCHMAKING_BIODATA);
  }

  void _prefillForm() {
    final p = myProfile;
    choice.clear();
    for (final f in bioFields) {
      final val = p?.dyn(f.key) ?? '';
      if (f.type == MmFieldType.dropdown) {
        if (val.isNotEmpty) choice[f.key] = val;
      } else {
        textCtrl(f.key).text = (val == '0') ? '' : val;
      }
    }
    update();
  }

  void openProfile(MmProfile p) async {
    selected = p;
    update();
    Get.toNamed(Routes.MATCHMAKING_PROFILE);
    loadingSelected = true;
    update();
    try {
      selected = await _repo.fetchProfile(p.id);
    } catch (_) {
    } finally {
      loadingSelected = false;
      update();
    }
  }

  // ── Biodata save (create / update) ──────────────────────────────────
  Future<void> saveBiodata() async {
    if (savingBiodata) return;
    // Validate required fields.
    for (final f in bioFields.where((x) => x.required)) {
      final v = f.type == MmFieldType.dropdown
          ? (choice[f.key] ?? '')
          : textCtrl(f.key).text.trim();
      if (v.isEmpty) {
        SnackHelper.error('${f.label} is required');
        return;
      }
    }
    savingBiodata = true;
    update();
    try {
      final payload = <String, dynamic>{};
      for (final f in bioFields) {
        if (f.type == MmFieldType.dropdown) {
          final v = choice[f.key] ?? '';
          if (v.isNotEmpty) payload[f.key] = v;
        } else if (f.type == MmFieldType.number) {
          final v = int.tryParse(textCtrl(f.key).text.trim());
          if (v != null) payload[f.key] = v;
        } else {
          final v = textCtrl(f.key).text.trim();
          if (v.isNotEmpty) payload[f.key] = v;
        }
      }
      if (hasProfile) {
        final res = await _repo.updateProfile(payload);
        SnackHelper.success(res.message.isNotEmpty ? res.message : 'Saved');
      } else {
        myProfile = await _repo.createProfile(payload);
        SnackHelper.success('Profile created');
      }
      await fetchMyProfile();
      Get.back();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      savingBiodata = false;
      update();
    }
  }

  // ── Express interest ────────────────────────────────────────────────
  Future<void> expressInterest() async {
    final p = selected;
    if (p == null || sendingInterest) return;
    sendingInterest = true;
    update();
    try {
      final res = await _repo.expressInterest(p.id);
      if (res.success) {
        SnackHelper.success(res.message.isNotEmpty ? res.message : 'Interest sent');
        Get.back();
      } else {
        SnackHelper.error(res.message);
      }
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      sendingInterest = false;
      update();
    }
  }

  // ── Interests / matches ─────────────────────────────────────────────
  Future<void> fetchReceived() async {
    loadingReceived = true;
    update();
    try {
      received = await _repo.fetchReceived();
    } catch (_) {
    } finally {
      loadingReceived = false;
      update();
    }
  }

  Future<void> fetchSent() async {
    loadingSent = true;
    update();
    try {
      sent = await _repo.fetchSent();
    } catch (_) {
    } finally {
      loadingSent = false;
      update();
    }
  }

  Future<void> fetchMatches() async {
    loadingMatches = true;
    update();
    try {
      matches = await _repo.fetchMatches();
    } catch (_) {
    } finally {
      loadingMatches = false;
      update();
    }
  }

  Future<void> respond(MmInterest it, bool accept) async {
    if (responding) return;
    responding = true;
    update();
    try {
      final res = await _repo.respondInterest(it.id, accept);
      SnackHelper.success(res.message.isNotEmpty
          ? res.message
          : (accept ? 'Accepted' : 'Declined'));
      await fetchReceived();
      await fetchMatches();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      responding = false;
      update();
    }
  }

  void openChat(String interestId, String title) {
    Get.toNamed(Routes.MATCHMAKING_CHAT,
        arguments: {'id': interestId, 'title': title});
  }

  @override
  void onClose() {
    for (final c in _text.values) {
      c.dispose();
    }
    super.onClose();
  }
}
