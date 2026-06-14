import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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

enum MmFieldType { text, number, dropdown, multiline, date }

class MmField {
  const MmField(this.key, this.label, this.type,
      {this.required = false, this.optionsKey = '', this.section = ''});
  final String key;
  final String label;
  final MmFieldType type;
  final bool required;
  final String optionsKey; // which option list feeds a dropdown
  final String section; // form section heading this field belongs to
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
  // Section headings, in display order, mirroring the register-profile design.
  static const String secIdentity = 'Identity';
  static const String secProfession = 'Profession & lifestyle';
  static const String secFamily = 'Family background';
  static const String secPhoto = 'Photo, bio & bio-data';

  final List<MmField> bioFields = const [
    // 1 · Identity
    MmField('full_name', 'Full name', MmFieldType.text,
        required: true, section: secIdentity),
    MmField('age', 'Age', MmFieldType.number,
        required: true, section: secIdentity),
    MmField('gender', 'Gender', MmFieldType.dropdown,
        required: true, optionsKey: 'genders', section: secIdentity),
    MmField('date_of_birth', 'Date of birth', MmFieldType.date,
        section: secIdentity),
    MmField('marital_status', 'Marital status', MmFieldType.dropdown,
        optionsKey: 'marital_status', section: secIdentity),
    MmField('religion', 'Religion', MmFieldType.text, section: secIdentity),
    MmField('nationality', 'Nationality', MmFieldType.text,
        section: secIdentity),
    MmField('language', 'Language', MmFieldType.text, section: secIdentity),
    // 2 · Profession & lifestyle
    MmField('education', 'Education', MmFieldType.text, section: secProfession),
    MmField('profession', 'Profession', MmFieldType.text,
        section: secProfession),
    MmField('income_range', 'Income range', MmFieldType.text,
        section: secProfession),
    MmField('location', 'Location (city)', MmFieldType.text,
        section: secProfession),
    MmField('height_cm', 'Height (cm)', MmFieldType.number,
        section: secProfession),
    MmField('weight_kg', 'Weight (kg)', MmFieldType.number,
        section: secProfession),
    MmField('lifestyle', 'Lifestyle', MmFieldType.text, section: secProfession),
    // 3 · Family background
    MmField('father_name', "Father's name", MmFieldType.text,
        section: secFamily),
    MmField('mother_name', "Mother's name", MmFieldType.text,
        section: secFamily),
    MmField('family_type', 'Family type', MmFieldType.dropdown,
        optionsKey: 'family_types', section: secFamily),
    MmField('siblings', 'Siblings', MmFieldType.text, section: secFamily),
    MmField('family_background', 'Family background note',
        MmFieldType.multiline, section: secFamily),
    MmField('birth_place', 'Birth place', MmFieldType.text, section: secFamily),
    // 4 · Photo, bio & bio-data (bio text here; files handled separately)
    MmField('bio', 'Short bio', MmFieldType.multiline, section: secPhoto),
  ];

  /// Section headings in order, for the grouped form.
  List<String> get bioSections =>
      const [secIdentity, secProfession, secFamily, secPhoto];

  List<MmField> fieldsForSection(String section) =>
      bioFields.where((f) => f.section == section).toList();

  final Map<String, TextEditingController> _text = {};
  final Map<String, String> choice = {};
  bool savingBiodata = false;

  // Photo visibility + locally-picked files (uploaded after the profile saves).
  bool photoVisible = true;
  File? photoFile;
  File? bioDataFile;
  String bioDataName = '';

  void setPhotoVisible(bool v) {
    photoVisible = v;
    update();
  }

  // ── Documents (GET/POST .../me/documents) ───────────────────────────
  List<MmDocument> documents = [];
  bool loadingDocuments = false;
  bool uploadingDoc = false;

  // ── Home category filter chips ──────────────────────────────────────
  String activeCategory = 'All';

  /// Chips shown above the suggestions: All + age ranges + professions.
  List<String> get categoryChips => [
        'All',
        ...?categories?.ageRanges.map((o) => o.label),
        ...?categories?.professions.map((o) => o.label),
      ];

  void selectCategory(String c) {
    activeCategory = c;
    update();
  }

  /// Suggestions filtered by the active chip (matches age range / profession /
  /// location against each profile).
  List<MmSuggestion> get visibleSuggestions {
    final c = activeCategory;
    if (c == 'All' || c.isEmpty) return suggestions;
    final range = _ageRange(c);
    final lc = c.toLowerCase();
    return suggestions.where((s) {
      final p = s.profile;
      if (range != null) return p.age >= range.$1 && p.age <= range.$2;
      return p.profession.toLowerCase().contains(lc) ||
          p.location.toLowerCase().contains(lc);
    }).toList();
  }

  /// Parses "25-30" / "Age 25–30" into a (min, max) range, or null.
  (int, int)? _ageRange(String label) {
    final nums = RegExp(r'\d+')
        .allMatches(label)
        .map((m) => int.parse(m.group(0)!))
        .toList();
    if (nums.length >= 2) return (nums[0], nums[1]);
    return null;
  }

  // ── Partner preference form state ───────────────────────────────────
  final Map<String, TextEditingController> _prefText = {};
  final Map<String, String> prefChoice = {};
  bool savingPreference = false;

  TextEditingController prefCtrl(String key) =>
      _prefText.putIfAbsent(key, () => TextEditingController());

  void setPrefChoice(String key, String value) {
    prefChoice[key] = value;
    update();
  }

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

  Future<void> fetchDocuments() async {
    loadingDocuments = true;
    update();
    try {
      documents = await _repo.fetchDocuments();
    } catch (_) {
      // No profile yet / no documents — leave the list empty silently.
    } finally {
      loadingDocuments = false;
      update();
    }
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
      // Personalized suggestions need a completed biodata + an eligible pool.
      // When there are none yet, fall back to browsing all available profiles
      // so the page isn't empty.
      if (suggestions.isEmpty) {
        suggestions = await _browseProfiles();
      }
    } catch (e) {
      // Suggestions can fail when the user has no profile yet — still try to
      // show the open profile list before surfacing an error.
      try {
        suggestions = await _browseProfiles();
      } catch (_) {
        SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      loadingSuggestions = false;
      update();
    }
  }

  /// All available profiles wrapped as (unscored) suggestions, for the
  /// "browse everyone" fallback when there are no personalized matches.
  Future<List<MmSuggestion>> _browseProfiles() async {
    final profiles = await _repo.fetchProfiles();
    return profiles
        .map((p) => MmSuggestion(profile: p, reasons: const [], score: 0))
        .toList();
  }

  Future<void> fetchMyProfile() async {
    loadingMyProfile = true;
    update();
    try {
      myProfile = await _repo.fetchMyProfile();
      if (myProfile != null) {
        photoVisible = myProfile!.photoVisible;
        _prefillPreference();
        fetchDocuments();
      }
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
    photoVisible = p?.photoVisible ?? true;
    photoFile = null;
    bioDataFile = null;
    bioDataName = '';
    update();
  }

  // ── File pickers (photo image + bio-data PDF) ───────────────────────
  Future<void> pickPhoto() async {
    try {
      final picked =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      photoFile = File(picked.path);
      update();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> pickBioDataPdf() async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      final path = res?.files.single.path;
      if (path == null) return;
      bioDataFile = File(path);
      bioDataName = res!.files.single.name;
      update();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    }
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
      final payload = <String, dynamic>{'photo_visible': photoVisible};
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
      // Upload any picked files now that the profile exists.
      await _uploadPickedFiles();
      await fetchMyProfile();
      Get.back();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      savingBiodata = false;
      update();
    }
  }

  /// Uploads the picked photo / bio-data PDF via the documents endpoint, then
  /// clears them and refreshes the documents list. Best-effort: a failure is
  /// surfaced but doesn't undo the saved profile.
  Future<void> _uploadPickedFiles() async {
    try {
      if (photoFile != null) {
        await _repo.uploadDocument(photoFile!, kind: 'photo');
        photoFile = null;
      }
      if (bioDataFile != null) {
        await _repo.uploadDocument(bioDataFile!,
            kind: 'bio_data', remarks: 'My full bio-data sheet');
        bioDataFile = null;
        bioDataName = '';
      }
      await fetchDocuments();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Standalone document upload (used by the documents section).
  Future<void> uploadDocument(File file, String kind, {String remarks = ''}) async {
    if (uploadingDoc) return;
    uploadingDoc = true;
    update();
    try {
      final res = await _repo.uploadDocument(file, kind: kind, remarks: remarks);
      SnackHelper.success(res.message.isNotEmpty ? res.message : 'Uploaded');
      await fetchDocuments();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      uploadingDoc = false;
      update();
    }
  }

  // ── Partner preference (PUT .../me/preference) ──────────────────────
  void openPreference() {
    _prefillPreference();
    Get.toNamed(Routes.MATCHMAKING_PREFERENCE);
  }

  void _prefillPreference() {
    final p = myProfile?.preference;
    if (p == null) return;
    prefChoice.clear();
    String numOrEmpty(int v) => v > 0 ? '$v' : '';
    prefCtrl('age_min').text = numOrEmpty(p.ageMin);
    prefCtrl('age_max').text = numOrEmpty(p.ageMax);
    prefCtrl('height_min_cm').text = numOrEmpty(p.heightMinCm);
    prefCtrl('height_max_cm').text = numOrEmpty(p.heightMaxCm);
    prefCtrl('religion').text = p.religion;
    prefCtrl('education').text = p.education;
    prefCtrl('profession').text = p.profession;
    prefCtrl('location').text = p.location;
    prefCtrl('income_range').text = p.incomeRange;
    prefCtrl('lifestyle').text = p.lifestyle;
    prefCtrl('notes').text = p.notes;
    if (p.gender.isNotEmpty) prefChoice['gender'] = p.gender;
    if (p.maritalStatus.isNotEmpty) {
      prefChoice['marital_status'] = p.maritalStatus;
    }
    if (p.familyType.isNotEmpty) prefChoice['family_type'] = p.familyType;
    update();
  }

  Future<void> savePreference() async {
    if (savingPreference) return;
    savingPreference = true;
    update();
    try {
      String t(String k) => prefCtrl(k).text.trim();
      int? n(String k) => int.tryParse(t(k));
      final payload = <String, dynamic>{
        if (n('age_min') != null) 'age_min': n('age_min'),
        if (n('age_max') != null) 'age_max': n('age_max'),
        if (n('height_min_cm') != null) 'height_min_cm': n('height_min_cm'),
        if (n('height_max_cm') != null) 'height_max_cm': n('height_max_cm'),
        if ((prefChoice['gender'] ?? '').isNotEmpty)
          'gender': prefChoice['gender'],
        if ((prefChoice['marital_status'] ?? '').isNotEmpty)
          'marital_status': prefChoice['marital_status'],
        if ((prefChoice['family_type'] ?? '').isNotEmpty)
          'family_type': prefChoice['family_type'],
        if (t('religion').isNotEmpty) 'religion': t('religion'),
        if (t('education').isNotEmpty) 'education': t('education'),
        if (t('profession').isNotEmpty) 'profession': t('profession'),
        if (t('location').isNotEmpty) 'location': t('location'),
        if (t('income_range').isNotEmpty) 'income_range': t('income_range'),
        if (t('lifestyle').isNotEmpty) 'lifestyle': t('lifestyle'),
        if (t('notes').isNotEmpty) 'notes': t('notes'),
      };
      final res = await _repo.updatePreference(payload);
      if (res.success) {
        // Pop back first, then show the snackbar on the previous screen so the
        // route transition doesn't swallow it. Refresh the profile in the
        // background so the saved preference is reflected.
        Get.back();
        SnackHelper.success(
            res.message.isNotEmpty ? res.message : 'Preferences saved');
        fetchMyProfile();
      } else {
        SnackHelper.error(
            res.message.isNotEmpty ? res.message : 'Could not save preferences');
      }
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      savingPreference = false;
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
    for (final c in _prefText.values) {
      c.dispose();
    }
    super.onClose();
  }
}
