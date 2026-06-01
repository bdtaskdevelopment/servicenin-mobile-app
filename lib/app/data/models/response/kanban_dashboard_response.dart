import 'dart:convert';

KanbanDashboardResponse kanbanDashboardResponseFromMap(dynamic src) =>
    KanbanDashboardResponse.fromMap(src is String ? jsonDecode(src) : src as Map<String, dynamic>);

class KanbanDashboardResponse {
  final bool status;
  final String message;
  final KanbanDashboardData data;

  KanbanDashboardResponse({required this.status, required this.message, required this.data});

  factory KanbanDashboardResponse.fromMap(Map<String, dynamic> json) => KanbanDashboardResponse(
        status: json['status'] == true,
        message: json['message'] ?? '',
        data: KanbanDashboardData.fromMap(json['data'] ?? {}),
      );
}

class KanbanDashboardData {
  final KanbanSummary summary;
  final List<KanbanHistoryItem> history;

  KanbanDashboardData({required this.summary, required this.history});

  factory KanbanDashboardData.fromMap(Map<String, dynamic> json) => KanbanDashboardData(
        summary: KanbanSummary.fromMap(json['summary'] ?? {}),
        history: (json['history'] as List? ?? []).map((e) => KanbanHistoryItem.fromMap(e)).toList(),
      );
}

class KanbanSummary {
  final int totalTasks;
  final int totalProjects;
  final int todo;
  final int doing;
  final int done;

  KanbanSummary({
    required this.totalTasks,
    required this.totalProjects,
    required this.todo,
    required this.doing,
    required this.done,
  });

  factory KanbanSummary.fromMap(Map<String, dynamic> json) {
    final counts = (json['counts'] as Map<String, dynamic>?) ?? {};
    return KanbanSummary(
      totalTasks: json['total_tasks'] ?? 0,
      totalProjects: json['total_projects'] ?? 0,
      todo: counts['todo'] ?? 0,
      doing: counts['doing'] ?? 0,
      done: counts['done'] ?? 0,
    );
  }
}

class KanbanHistoryItem {
  final int id;
  final String description;
  final String time;
  final String type;

  KanbanHistoryItem({
    required this.id,
    required this.description,
    required this.time,
    required this.type,
  });

  factory KanbanHistoryItem.fromMap(Map<String, dynamic> json) => KanbanHistoryItem(
        id: json['id'] ?? 0,
        description: json['description'] ?? '',
        time: json['time'] ?? '',
        type: json['type'] ?? '',
      );
}
