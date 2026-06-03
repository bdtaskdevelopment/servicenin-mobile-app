import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class JobPost {
  const JobPost({
    required this.badge,
    required this.title,
    required this.company,
    required this.type,
    required this.location,
    required this.salary,
    required this.posted,
    required this.applied,
    this.remoteOk = false,
    this.about =
        'Build civic-tech products with React. Work on the ServiceNin '
            'super-app used across Dhaka.',
    this.skills = const ['React', 'TypeScript', 'REST APIs'],
    this.experience = '2-4 years',
    this.deadline = '15 Jun 2026',
  });
  final String badge;
  final String title;
  final String company;
  final String type;
  final String location;
  final String salary;
  final String posted;
  final int applied;
  final bool remoteOk;
  final String about;
  final List<String> skills;
  final String experience;
  final String deadline;
}

enum AppStatus { shortlisted, underReview, notSelected }

class JobApplication {
  const JobApplication({
    required this.title,
    required this.company,
    required this.applied,
    required this.status,
  });
  final String title;
  final String company;
  final String applied;
  final AppStatus status;
}

class JobsController extends GetxController {
  final List<String> categories = const [
    'All',
    'IT',
    'Sales',
    'Finance',
    'Marketing',
    'Admin',
  ];
  int categoryIndex = 0;
  void setCategory(int i) {
    categoryIndex = i;
    update();
  }

  final List<JobPost> jobs = const [
    JobPost(
      badge: 'BD',
      title: 'Frontend Engineer',
      company: 'Bdtask Limited',
      type: 'Full-time',
      location: 'Gulshan, Dhaka',
      salary: '৳60k–৳100k',
      posted: '2 days ago',
      applied: 34,
      remoteOk: true,
    ),
    JobPost(
      badge: 'PH',
      title: 'Field Sales Officer',
      company: 'Praava Health',
      type: 'Full-time',
      location: 'Dhanmondi',
      salary: '৳25k–৳40k',
      posted: '1 day ago',
      applied: 58,
      about:
          'Drive field sales for healthcare packages across Dhaka. Build '
          'relationships with clinics and corporate clients.',
      skills: ['Sales', 'Communication', 'CRM'],
      experience: '1-3 years',
      deadline: '20 Jun 2026',
    ),
    JobPost(
      badge: 'SQ',
      title: 'Accountant',
      company: 'Square Group',
      type: 'Full-time',
      location: 'Tejgaon',
      salary: '৳35k–৳55k',
      posted: '4 days ago',
      applied: 21,
      about:
          'Manage ledgers, payroll and monthly closing for a large FMCG '
          'group. VAT & tax compliance experience preferred.',
      skills: ['Accounting', 'Tally', 'VAT'],
      experience: '3-5 years',
      deadline: '25 Jun 2026',
    ),
  ];

  JobPost? selected;

  final List<JobApplication> applications = const [
    JobApplication(
      title: 'UX Designer',
      company: 'Pathao',
      applied: 'Applied 3 days ago',
      status: AppStatus.shortlisted,
    ),
    JobApplication(
      title: 'Frontend Engineer',
      company: 'Bdtask Limited',
      applied: 'Applied 1 day ago',
      status: AppStatus.underReview,
    ),
    JobApplication(
      title: 'Support Executive',
      company: 'bKash',
      applied: 'Applied 1 week ago',
      status: AppStatus.notSelected,
    ),
  ];

  // Post-a-job form dropdowns
  final List<String> postCategories = const [
    'IT',
    'Sales',
    'Finance',
    'Marketing',
    'Admin',
  ];
  final List<String> postTypes = const [
    'Full-time',
    'Part-time',
    'Contract',
    'Internship',
    'Remote',
  ];
  final List<String> postExperiences = const [
    'Fresher',
    '1-2 years',
    '2-4 years',
    '5+ years',
  ];
  int postCategoryIndex = 0;
  int postTypeIndex = 0;
  int postExperienceIndex = 0;
  void setPostCategory(int i) {
    postCategoryIndex = i;
    update();
  }

  void setPostType(int i) {
    postTypeIndex = i;
    update();
  }

  void setPostExperience(int i) {
    postExperienceIndex = i;
    update();
  }

  // ---- Navigation ----
  void openApplications() => Get.toNamed(Routes.JOBS_APPLICATIONS);

  void openJob(JobPost j) {
    selected = j;
    update();
    Get.toNamed(Routes.JOBS_DETAIL);
  }

  void applyToJob() => Get.toNamed(Routes.JOBS_APPLY);

  void submitApplication() =>
      Get.offNamed(Routes.JOBS_APPLICATIONS);

  void openPostJob() => Get.toNamed(Routes.JOBS_POST);

  void publishJob() => Get.until((r) => Get.currentRoute == Routes.JOBS);
}
