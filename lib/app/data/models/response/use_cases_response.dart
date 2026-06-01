class UseCaseItem {
  final int id;
  final String useCaseNo;
  final String name;
  final String priority;

  UseCaseItem({
    required this.id,
    required this.useCaseNo,
    required this.name,
    required this.priority,
  });

  factory UseCaseItem.fromJson(Map<String, dynamic> j) => UseCaseItem(
        id: j['id'] is int ? j['id'] as int : int.tryParse('${j['id']}') ?? 0,
        useCaseNo: j['use_case_no']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        priority: j['priority']?.toString() ?? 'medium',
      );
}

class UseCasesResponse {
  final List<UseCaseItem> data;
  UseCasesResponse({required this.data});
}

UseCasesResponse useCasesResponseFromMap(dynamic json) {
  final map = json is Map ? json : <String, dynamic>{};
  final list = (map['data'] as List? ?? [])
      .map((e) => UseCaseItem.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
  return UseCasesResponse(data: list);
}
