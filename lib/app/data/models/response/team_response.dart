class TeamMember {
  final int id;
  final String name;
  final int empId;
  final String title;
  final String? department;
  final String? avatar;

  TeamMember({
    required this.id,
    required this.name,
    required this.empId,
    required this.title,
    this.department,
    this.avatar,
  });

  factory TeamMember.fromMap(Map<String, dynamic> m) => TeamMember(
        id: m['id'] as int,
        name: m['name'] as String? ?? '',
        empId: m['emp_id'] as int? ?? 0,
        title: m['title'] as String? ?? '',
        department: m['department'] as String?,
        avatar: m['avatar'] as String?,
      );

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class TeamResponse {
  final List<TeamMember> data;
  TeamResponse({required this.data});
  factory TeamResponse.fromMap(Map<String, dynamic> m) => TeamResponse(
        data: (m['data'] as List)
            .map((e) => TeamMember.fromMap(e as Map<String, dynamic>))
            .toList(),
      );
}

TeamResponse teamResponseFromMap(Map<String, dynamic> m) =>
    TeamResponse.fromMap(m);
