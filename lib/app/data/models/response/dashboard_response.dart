import 'dart:convert';

DashboardResponse dashboardResponseFromMap(dynamic src) =>
    DashboardResponse.fromMap(src is String ? jsonDecode(src) : src as Map<String, dynamic>);

class DashboardResponse {
  final bool status;
  final String message;
  final DashboardData data;

  DashboardResponse({required this.status, required this.message, required this.data});

  factory DashboardResponse.fromMap(Map<String, dynamic> json) => DashboardResponse(
        status: json['status'] == true,
        message: json['message'] ?? '',
        data: DashboardData.fromMap(json['data'] ?? {}),
      );
}

class DashboardToday {
  final String date;
  final String day;
  DashboardToday({required this.date, required this.day});
  factory DashboardToday.fromMap(Map<String, dynamic> json) => DashboardToday(
        date: json['date'] as String? ?? '',
        day: json['day'] as String? ?? '',
      );
}

class DashboardData {
  final DashboardToday today;
  final DashboardSummary summary;
  final List<DashboardTask> tasks;
  final List<DashboardNotice> notices;
  final int unreadNotifications;

  DashboardData({
    required this.today,
    required this.summary,
    required this.tasks,
    required this.notices,
    required this.unreadNotifications,
  });

  factory DashboardData.fromMap(Map<String, dynamic> json) => DashboardData(
        today: DashboardToday.fromMap(json['today'] as Map<String, dynamic>? ?? {}),
        summary: DashboardSummary.fromMap(json['summary'] ?? {}),
        tasks: (json['tasks'] as List? ?? []).map((e) => DashboardTask.fromMap(e)).toList(),
        notices: (json['notices'] as List? ?? []).map((e) => DashboardNotice.fromMap(e)).toList(),
        unreadNotifications: json['unread_notifications'] ?? 0,
      );
}

class DashboardSummary {
  final String month;
  final int onTime;
  final int late;
  final int leave;
  final String workHours;
  final String breakTime;
  final String overtime;

  DashboardSummary({
    required this.month,
    required this.onTime,
    required this.late,
    required this.leave,
    required this.workHours,
    required this.breakTime,
    required this.overtime,
  });

  factory DashboardSummary.fromMap(Map<String, dynamic> json) => DashboardSummary(
        month: json['month'] ?? '',
        onTime: json['on_time'] ?? 0,
        late: json['late'] ?? 0,
        leave: json['leave'] ?? 0,
        workHours: json['work_hours'] ?? '0h 0m',
        breakTime: json['break_time'] ?? '0h 0m',
        overtime: json['overtime'] ?? '0h 0m',
      );
}

class DashboardTask {
  final int id;
  final String title;
  final String project;
  final String status;
  final String dueDate;
  final bool isToday;
  final bool isOverdue;

  DashboardTask({
    required this.id,
    required this.title,
    required this.project,
    required this.status,
    required this.dueDate,
    required this.isToday,
    required this.isOverdue,
  });

  factory DashboardTask.fromMap(Map<String, dynamic> json) => DashboardTask(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        project: json['project'] ?? '',
        status: json['status'] ?? '',
        dueDate: json['due_date'] ?? '',
        isToday: json['is_today'] ?? false,
        isOverdue: json['is_overdue'] ?? false,
      );
}

class DashboardNotice {
  final int id;
  final String title;
  final String date;
  final String snippet;

  DashboardNotice({
    required this.id,
    required this.title,
    required this.date,
    required this.snippet,
  });

  factory DashboardNotice.fromMap(Map<String, dynamic> json) => DashboardNotice(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        date: json['date'] ?? '',
        snippet: json['snippet'] ?? '',
      );
}
