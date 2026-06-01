class PolicyItem {
  final int id;
  final String title;
  final String description;
  final String? tag;
  final String createdAt;

  PolicyItem({
    required this.id,
    required this.title,
    required this.description,
    this.tag,
    required this.createdAt,
  });
}

class PoliciesResponse {
  final List<PolicyItem> data;
  PoliciesResponse({required this.data});
}

PoliciesResponse policiesResponseFromMap(dynamic json) {
  final list = (json['data'] as List? ?? []);
  return PoliciesResponse(
    data: list.map((e) => PolicyItem(
      id: e['id'] as int,
      title: e['title'] as String? ?? '',
      description: e['description'] as String? ?? '',
      tag: e['tag'] as String?,
      createdAt: e['created_at'] as String? ?? '',
    )).toList(),
  );
}
