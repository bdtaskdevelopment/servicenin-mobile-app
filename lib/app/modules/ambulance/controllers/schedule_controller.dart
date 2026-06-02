import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class ScheduleDate {
  const ScheduleDate(this.label, this.date);
  final String label;
  final String date;
}

class ScheduleController extends GetxController {
  final String pickup = 'House 32, Rd 11, Gulshan-2';
  final String destination = 'BSMMU, Shahbag';

  final List<ScheduleDate> dates = const [
    ScheduleDate('Today', '15 May'),
    ScheduleDate('Tomorrow', '16 May'),
    ScheduleDate('Sat', '17 May'),
    ScheduleDate('Sun', '18 May'),
  ];
  int selectedDate = 1;
  void selectDate(int i) {
    selectedDate = i;
    update();
  }

  final String time = '08:30 AM';
  final String ambulanceType = 'Basic Life Support';
  final String ambulanceSub = 'Oxygen, first aid · ৳800 base + ৳35/km';

  final String patientInitials = 'MA';
  final String patientName = 'Md. Ahsan Ullah (father)';
  final String patientInfo = '68 yrs · M · B+ · Diabetic';
  final String medicalNote =
      'Post-cardiac surgery follow-up at BSMMU OPD. Carry insulin kit. Wheelchair needed at pickup.';
  final String contactPerson = 'Tanzil Ahmed · 01711-***123';

  final String fareDistance = '7.4 km';
  final String estimatedFare = '৳1,059';

  void confirmSchedule() => Get.toNamed(Routes.AMBULANCE_FARE);
}
