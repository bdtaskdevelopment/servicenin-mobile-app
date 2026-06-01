class DailyTaskItem {
  final int id;
  final String title;
  final String employeeName;
  final int employeeId;
  final String date;
  final bool isApproved;
  final String approvalStatus;
  final String? attachment;
  final String? description;

  DailyTaskItem({
    required this.id,
    required this.title,
    required this.employeeName,
    required this.employeeId,
    required this.date,
    required this.isApproved,
    required this.approvalStatus,
    this.attachment,
    this.description,
  });
}

DailyTaskItem dailyTaskDetailFromMap(dynamic json) {
  final e = json['data'] as Map<String, dynamic>;
  return DailyTaskItem(
    id:             e['id'] as int? ?? 0,
    title:          e['title'] as String? ?? '',
    employeeName:   e['employee_name'] as String? ?? '',
    employeeId:     e['employee_id'] as int? ?? 0,
    date:           e['date'] as String? ?? '',
    isApproved:     e['is_approved'] == true || e['is_approved'] == 1,
    approvalStatus: e['approval_status'] as String? ?? 'Pending',
    attachment:     e['attachment'] as String?,
    description:    e['description'] as String?,
  );
}

class DailyTaskMeta {
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  DailyTaskMeta({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });
}

class DailyTaskResponse {
  final List<DailyTaskItem> items;
  final DailyTaskMeta meta;

  DailyTaskResponse({required this.items, required this.meta});
}

DailyTaskResponse dailyTaskResponseFromMap(dynamic json) {
  final d = json['data'] as Map<String, dynamic>;
  return DailyTaskResponse(
    items: (d['data'] as List? ?? []).map((e) => DailyTaskItem(
      id: e['id'] as int? ?? 0,
      title: e['title'] as String? ?? '',
      employeeName: e['employee_name'] as String? ?? '',
      employeeId: e['employee_id'] as int? ?? 0,
      date: e['date'] as String? ?? '',
      isApproved: e['is_approved'] == true || e['is_approved'] == 1,
      approvalStatus: e['approval_status'] as String? ?? 'Pending',
      attachment: e['attachment'] as String?,
    )).toList(),
    meta: DailyTaskMeta(
      currentPage: d['current_page'] as int? ?? 1,
      lastPage: d['last_page'] as int? ?? 1,
      total: d['total'] as int? ?? 0,
      perPage: d['per_page'] as int? ?? 15,
    ),
  );
}
