class OwnTask {
  final int id;
  final String title;
  final String project;
  final int priority;
  final int status;
  final int? sprint;
  final String? dueDate;
  final String? description;

  OwnTask({
    required this.id,
    required this.title,
    required this.project,
    required this.priority,
    required this.status,
    this.sprint,
    this.dueDate,
    this.description,
  });

  String get statusLabel => switch (status) {
        1 => 'To Do',
        2 => 'In Progress',
        3 => 'Done',
        _ => 'Unknown',
      };

  String get priorityLabel => switch (priority) {
        1 => 'Low',
        2 => 'Medium',
        3 => 'High',
        _ => 'Normal',
      };

  static int _toInt(dynamic v, int fallback) {
    if (v == null) return fallback;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? fallback;
  }

  static int? _toIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  factory OwnTask.fromJson(Map<String, dynamic> j) => OwnTask(
        id: _toInt(j['id'], 0),
        title: j['title']?.toString() ?? '',
        project: j['project']?.toString() ?? '',
        priority: _toInt(j['priority'], 1),
        status: _toInt(j['status'], 1),
        sprint: _toIntOrNull(j['sprint']),
        dueDate: j['due_date']?.toString(),
        description: j['description']?.toString(),
      );
}

class OwnTasksResponse {
  final List<OwnTask> data;
  OwnTasksResponse({required this.data});
}

OwnTasksResponse ownTasksResponseFromMap(dynamic json) {
  final map = json is Map ? json : <String, dynamic>{};
  final list = (map['data'] as List? ?? [])
      .map((e) => OwnTask.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
  return OwnTasksResponse(data: list);
}
