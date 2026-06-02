import 'package:get/get.dart';

class Medicine {
  const Medicine(this.name, this.dose, this.duration, this.timing);
  final String name;
  final String dose; // e.g. "1 + 0 + 0"
  final String duration; // "30 days" / "Continue"
  final String timing; // "After breakfast"
}

class PrescriptionController extends GetxController {
  final String apptId = 'APT-7702';
  final String date = '6 May';
  final String doctor = 'Dr. Tanvir Hasan';
  final String degree = 'MBBS, DDV · BMDC 19478';
  final String patient = 'Tanzil Ahmed · 32y · M';
  final String diagnosis = 'Mild dermatitis';

  final List<Medicine> meds = const [
    Medicine('Tab. Bisoprolol 5mg', '1 + 0 + 0', '30 days', 'After breakfast'),
    Medicine('Tab. Atorvastatin 10mg', '0 + 0 + 1', '30 days', 'After dinner'),
    Medicine('Tab. Aspirin 75mg', '0 + 1 + 0', 'Continue', 'After lunch'),
  ];

  final String advice =
      'Avoid fragranced soap. Use moisturiser twice daily. Follow up in 2 weeks if no improvement.';
}
