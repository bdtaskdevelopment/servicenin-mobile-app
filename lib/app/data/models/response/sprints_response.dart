class SprintItem {
  final int id;
  final String name;
  final String? startDate;
  final String? endDate;
  final String status;
  final int tasks;

  SprintItem({
    required this.id,
    required this.name,
    this.startDate,
    this.endDate,
    required this.status,
    required this.tasks,
  });

  static int _toInt(dynamic v, int fallback) {
    if (v == null) return fallback;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? fallback;
  }

  factory SprintItem.fromJson(Map<String, dynamic> j) => SprintItem(
        id: _toInt(j['id'], 0),
        name: j['name']?.toString() ?? '',
        startDate: j['start_date']?.toString(),
        endDate: j['end_date']?.toString(),
        status: j['status']?.toString() ?? 'open',
        tasks: _toInt(j['tasks'], 0),
      );
}

class SprintsResponse {
  final List<SprintItem> data;
  SprintsResponse({required this.data});
}

SprintsResponse sprintsResponseFromMap(dynamic json) {
  final map = json is Map ? json : <String, dynamic>{};
  final list = (map['data'] as List? ?? [])
      .map((e) => SprintItem.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
  return SprintsResponse(data: list);
}
