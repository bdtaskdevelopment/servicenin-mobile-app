import 'dart:convert';

KanbanBoardResponse kanbanBoardResponseFromMap(dynamic src) =>
    KanbanBoardResponse.fromMap(src is String ? jsonDecode(src) : src as Map<String, dynamic>);

class KanbanBoardResponse {
  final bool status;
  final String message;
  final List<KanbanBoardTask> tasks;

  KanbanBoardResponse({required this.status, required this.message, required this.tasks});

  factory KanbanBoardResponse.fromMap(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    // The active status column's tasks are what we display
    final tasks = <KanbanBoardTask>[];
    for (final col in data.values) {
      if (col is Map<String, dynamic>) {
        final list = col['tasks'] as List? ?? [];
        tasks.addAll(list.map((e) => KanbanBoardTask.fromMap(e)));
      }
    }
    return KanbanBoardResponse(
      status: json['status'] == true,
      message: json['message'] ?? '',
      tasks: tasks,
    );
  }
}

class KanbanBoardTask {
  final int id;
  final String title;
  final String project;
  final String priority;
  final String due;
  final List<KanbanBoardAssignee> assignees;

  KanbanBoardTask({
    required this.id,
    required this.title,
    required this.project,
    required this.priority,
    required this.due,
    required this.assignees,
  });

  String get formattedDue {
    try {
      final parts = due.split('-');
      if (parts.length != 3) return due;
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      return '${months[month - 1]} $day';
    } catch (_) {
      return due;
    }
  }

  factory KanbanBoardTask.fromMap(Map<String, dynamic> json) => KanbanBoardTask(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        project: json['project'] ?? '',
        priority: json['priority'] ?? 'low',
        due: json['due'] ?? '',
        assignees: (json['assignees'] as List? ?? [])
            .map((e) => KanbanBoardAssignee.fromMap(e))
            .toList(),
      );
}

class KanbanBoardAssignee {
  final int id;
  final String name;
  final String initials;
  final String? avatar;

  KanbanBoardAssignee({required this.id, required this.name, required this.initials, this.avatar});

  factory KanbanBoardAssignee.fromMap(Map<String, dynamic> json) => KanbanBoardAssignee(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        initials: json['initials'] ?? '',
        avatar: json['avatar']?.toString(),
      );
}
