import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class MmMatch {
  const MmMatch({
    required this.code,
    required this.letter,
    required this.age,
    required this.height,
    required this.profession,
    required this.education,
    required this.location,
    this.nidVerified = true,
  });
  final String code;
  final String letter;
  final String age;
  final String height;
  final String profession;
  final String education;
  final String location;
  final bool nidVerified;
}

class MmBioField {
  const MmBioField(this.label, this.value, {this.hint = false, this.fromProfile = false});
  final String label;
  final String value;
  final bool hint;
  final bool fromProfile;
}

class MmDetailRow {
  const MmDetailRow(this.label, this.value);
  final String label;
  final String value;
}

class MmInterest {
  const MmInterest({
    required this.code,
    required this.score,
    required this.summary,
    required this.ago,
    this.awaiting = false,
  });
  final String code;
  final String score;
  final String summary;
  final String ago;
  final bool awaiting;
}

class MatchmakingController extends GetxController {
  final List<String> filters = const [
    'All',
    'Age 25–30',
    'Dhaka',
    'Doctor',
    'Engineer',
  ];
  int filterIndex = 0;
  void setFilter(int i) {
    filterIndex = i;
    update();
  }

  final List<MmMatch> matches = const [
    MmMatch(
      code: 'SN-72841',
      letter: 'A',
      age: '27 yrs',
      height: '5\'4"',
      profession: 'Banker',
      education: 'BBA, Dhaka University',
      location: 'Dhanmondi, Dhaka',
    ),
    MmMatch(
      code: 'SN-71203',
      letter: 'R',
      age: '30 yrs',
      height: '5\'7"',
      profession: 'Software Engineer',
      education: 'BSc CSE, BUET',
      location: 'Uttara, Dhaka',
    ),
    MmMatch(
      code: 'SN-70588',
      letter: 'T',
      age: '26 yrs',
      height: '5\'2"',
      profession: 'Doctor',
      education: 'MBBS, DMC',
      location: 'Mirpur, Dhaka',
    ),
  ];

  // Selected profile (for the detail screen)
  MmMatch? selected;

  final List<MmBioField> biodata = const [
    MmBioField('FULL NAME', 'Tanzil Ahmed', fromProfile: true),
    MmBioField('DATE OF BIRTH', '14 Mar 1994'),
    MmBioField('HEIGHT (CM)', 'e.g. 172', hint: true),
    MmBioField('RELIGION', 'Islam · Sunni'),
    MmBioField('PROFESSION', 'e.g. Software Engineer', hint: true),
    MmBioField('EDUCATION', 'e.g. BSc, BUET', hint: true),
    MmBioField('PRESENT ADDRESS', 'Gulshan-2, Dhaka'),
    MmBioField('GUARDIAN CONTACT', '+880 1XXXXXXXXX', hint: true),
  ];

  // Editable text controllers, one per biodata field.
  late final List<TextEditingController> bioControllers;

  @override
  void onInit() {
    super.onInit();
    bioControllers = biodata
        .map((f) => TextEditingController(text: f.hint ? '' : f.value))
        .toList();
  }

  @override
  void onClose() {
    for (final c in bioControllers) {
      c.dispose();
    }
    super.onClose();
  }

  // Detail rows for the selected match (SN-72841 in the mock)
  final List<MmDetailRow> detailRows = const [
    MmDetailRow('Age', '27 years'),
    MmDetailRow('Height', '5\'4" (162 cm)'),
    MmDetailRow('Marital status', 'Never married'),
    MmDetailRow('Religion', 'Islam · Sunni'),
    MmDetailRow('Profession', 'Banker (BRAC Bank)'),
    MmDetailRow('Education', 'BBA, Dhaka University'),
    MmDetailRow('Location', 'Dhanmondi, Dhaka'),
    MmDetailRow('Family', 'Father retired govt. officer · 1 sibling'),
  ];

  final List<MmInterest> received = const [
    MmInterest(
      code: 'SN-69440',
      score: '40',
      summary: '29 yrs · Architect · Banani',
      ago: '2 days ago',
    ),
    MmInterest(
      code: 'SN-68112',
      score: '12',
      summary: '31 yrs · Lecturer, NSU · Bashundhara',
      ago: '5 days ago',
    ),
  ];

  final List<MmInterest> sent = const [
    MmInterest(
      code: 'SN-72841',
      score: '41',
      summary: '27 yrs · Banker · Dhanmondi',
      ago: '1 day ago',
      awaiting: true,
    ),
  ];

  // ---- Navigation ----
  void openInterests() => Get.toNamed(Routes.MATCHMAKING_INTERESTS);

  void openBiodata() => Get.toNamed(Routes.MATCHMAKING_BIODATA);

  void saveBiodata() {
    Get.back();
    Get.snackbar(
      'Biodata saved',
      'Your biodata has been updated',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
  }

  void openProfile(MmMatch m) {
    selected = m;
    update();
    Get.toNamed(Routes.MATCHMAKING_PROFILE);
  }

  void expressInterest() => Get.toNamed(Routes.MATCHMAKING_INTERESTS);
}
