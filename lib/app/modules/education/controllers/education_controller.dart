import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class EduCourse {
  const EduCourse({
    required this.title,
    required this.teacher,
    required this.duration,
    required this.price,
    required this.seats,
    required this.online,
  });
  final String title;
  final String teacher;
  final String duration;
  final String price;
  final String seats;
  final bool online;
}

class EduCenter {
  const EduCenter({
    required this.name,
    required this.area,
    required this.distance,
    required this.rating,
    required this.reviews,
    required this.tags,
    required this.courses,
  });
  final String name;
  final String area;
  final String distance;
  final String rating;
  final String reviews;
  final List<String> tags;
  final List<EduCourse> courses;
}

class EducationController extends GetxController {
  final List<String> categories = const [
    'All',
    'HSC',
    'Admission',
    'Medical',
    'English',
    'IELTS',
  ];
  int categoryIndex = 0;
  void setCategory(int i) {
    categoryIndex = i;
    update();
  }

  final List<EduCenter> centers = const [
    EduCenter(
      name: 'Mentors Coaching Center',
      area: 'Dhanmondi 27',
      distance: '1.1 km',
      rating: '4.8',
      reviews: '210',
      tags: ['HSC', 'Admission', 'English'],
      courses: [
        EduCourse(
          title: 'HSC Physics (Batch 2026)',
          teacher: 'Engr. Rakib',
          duration: '4 months',
          price: '৳3,500',
          seats: '8 left',
          online: false,
        ),
        EduCourse(
          title: 'University Admission — Science',
          teacher: 'Dr. Hasan',
          duration: '6 months',
          price: '৳8,000',
          seats: '15 left',
          online: false,
        ),
        EduCourse(
          title: 'Spoken English',
          teacher: 'Ms. Farah',
          duration: '3 months',
          price: '৳2,500',
          seats: 'Open',
          online: true,
        ),
      ],
    ),
    EduCenter(
      name: 'UCC Uttara',
      area: 'Uttara Sector 6',
      distance: '5.4 km',
      rating: '4.6',
      reviews: '156',
      tags: ['Medical', 'Engineering'],
      courses: [
        EduCourse(
          title: 'Medical Admission Crash',
          teacher: 'Dr. Nabila',
          duration: '5 months',
          price: '৳12,000',
          seats: '6 left',
          online: false,
        ),
        EduCourse(
          title: 'Engineering Admission',
          teacher: 'Engr. Sami',
          duration: '5 months',
          price: '৳10,000',
          seats: '10 left',
          online: false,
        ),
      ],
    ),
    EduCenter(
      name: 'Bright Future Tutors',
      area: 'Mirpur 10',
      distance: '7.2 km',
      rating: '4.5',
      reviews: '88',
      tags: ['Class 6–10', 'Home tutor'],
      courses: [
        EduCourse(
          title: 'Class 9–10 Math & Science',
          teacher: 'Tahmid Sir',
          duration: 'Monthly',
          price: '৳4,000',
          seats: 'Open',
          online: false,
        ),
        EduCourse(
          title: 'Home Tutor (any subject)',
          teacher: 'Verified tutors',
          duration: 'Flexible',
          price: '৳3,000',
          seats: 'Open',
          online: false,
        ),
      ],
    ),
  ];

  // Selection
  EduCenter? center;
  EduCourse? course;

  // Enquiry form
  final List<String> grades = const [
    'Class 6–8',
    'SSC',
    'HSC',
    'Admission',
    'University',
  ];
  int gradeIndex = 2; // HSC default
  void setGrade(int i) {
    gradeIndex = i;
    update();
  }

  // ---- Navigation ----
  void openCenter(EduCenter c) {
    center = c;
    update();
    Get.toNamed(Routes.EDUCATION_CENTER);
  }

  void enquire(EduCourse c) {
    course = c;
    gradeIndex = 2;
    update();
    Get.toNamed(Routes.EDUCATION_ENQUIRY);
  }

  void submitEnquiry() => Get.toNamed(Routes.EDUCATION_DONE);

  void backToEducation() =>
      Get.until((r) => Get.currentRoute == Routes.EDUCATION);
}
