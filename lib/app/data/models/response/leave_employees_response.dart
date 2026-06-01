class LeaveEmployee {
  final int employeeId;
  final String fullName;
  final String? position;
  final String? profileImage;

  LeaveEmployee({required this.employeeId, required this.fullName, this.position, this.profileImage});
}

class LeaveEmployeesResponse {
  final List<LeaveEmployee> data;
  LeaveEmployeesResponse({required this.data});
}

LeaveEmployeesResponse leaveEmployeesResponseFromMap(dynamic json) {
  return LeaveEmployeesResponse(
    data: (json['data'] as List? ?? []).map((e) => LeaveEmployee(
      employeeId: e['employee_id'] as int,
      fullName: e['full_name'] as String? ?? '',
      position: e['position'] as String?,
      profileImage: e['profile_image'] as String?,
    )).toList(),
  );
}
