class ProjectSummary {
  final int total;
  final int open;
  final int close;
  ProjectSummary({required this.total, required this.open, required this.close});
  factory ProjectSummary.fromMap(Map<String, dynamic> m) => ProjectSummary(
        total: m['total'] as int? ?? 0,
        open: m['open'] as int? ?? 0,
        close: m['close'] as int? ?? 0,
      );
}

class ProjectMember {
  final int id;
  final String name;
  final String initials;
  final String? avatar;
  ProjectMember(
      {required this.id,
      required this.name,
      required this.initials,
      this.avatar});
  factory ProjectMember.fromMap(Map<String, dynamic> m) => ProjectMember(
        id: m['id'] is int ? m['id'] as int : int.tryParse('${m['id']}') ?? 0,
        name: m['name']?.toString() ?? '',
        initials: m['initials']?.toString() ?? '',
        avatar: m['avatar']?.toString(),
      );
}

class ProjectItem {
  final int id;
  final String name;
  final String client;
  final String status;
  final String startDate;
  final String endDate;
  final String duration;
  final int tasksCompleted;
  final int tasksTotal;
  final String tasksPercentage;
  final String projectDurationPercentage;
  final List<ProjectMember> members;
  final int totalMembers;
  final String approximateTasks;
  final String? description;
  final String? latitude;
  final String? longitude;

  ProjectItem({
    required this.id,
    required this.name,
    required this.client,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.tasksCompleted,
    required this.tasksTotal,
    required this.tasksPercentage,
    required this.projectDurationPercentage,
    required this.members,
    required this.totalMembers,
    required this.approximateTasks,
    this.description,
    this.latitude,
    this.longitude,
  });

  static int _toInt(dynamic v, int fallback) {
    if (v == null) return fallback;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? fallback;
  }

  factory ProjectItem.fromMap(Map<String, dynamic> m) => ProjectItem(
        id: _toInt(m['id'], 0),
        name: m['name']?.toString() ?? '',
        client: m['client']?.toString() ?? '--',
        status: (m['status']?.toString() ?? '').toLowerCase(),
        startDate: m['start_date']?.toString() ?? '-',
        endDate: m['end_date']?.toString() ?? '-',
        duration: m['duration']?.toString() ?? '-',
        tasksCompleted: _toInt(m['tasks_completed'], 0),
        tasksTotal: _toInt(m['tasks_total'], 0),
        tasksPercentage: m['tasks_percentage']?.toString() ?? '0%',
        projectDurationPercentage:
            m['project_duration_percentage']?.toString() ?? '0%',
        members: (m['members'] as List? ?? [])
            .map((e) =>
                ProjectMember.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        totalMembers: _toInt(m['total_members'], 0),
        approximateTasks: m['approximate_tasks']?.toString() ?? '0',
        description: m['description']?.toString(),
        latitude: m['latitude']?.toString(),
        longitude: m['longitude']?.toString(),
      );

  int get taskPct =>
      int.tryParse(tasksPercentage.replaceAll('%', '').trim()) ?? 0;
  int get durationPct =>
      int.tryParse(projectDurationPercentage.replaceAll('%', '').trim()) ?? 0;
}

class ProjectsResponse {
  final ProjectSummary summary;
  final List<ProjectItem> list;
  ProjectsResponse({required this.summary, required this.list});
  factory ProjectsResponse.fromMap(Map<String, dynamic> m) {
    final data = m['data'] as Map<String, dynamic>;
    return ProjectsResponse(
      summary:
          ProjectSummary.fromMap(data['summary'] as Map<String, dynamic>),
      list: (data['list'] as List? ?? [])
          .map((e) =>
              ProjectItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

ProjectsResponse projectsResponseFromMap(Map<String, dynamic> m) =>
    ProjectsResponse.fromMap(m);
