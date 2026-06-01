class LeaveTypeItem {
  final int id;
  final String leaveType;
  final int totalDays;
  final bool isPaid;

  LeaveTypeItem({required this.id, required this.leaveType, required this.totalDays, required this.isPaid});
}

class LeaveTypesResponse {
  final List<LeaveTypeItem> data;
  LeaveTypesResponse({required this.data});
}

LeaveTypesResponse leaveTypesResponseFromMap(dynamic json) {
  return LeaveTypesResponse(
    data: (json['data'] as List? ?? []).map((e) => LeaveTypeItem(
      id: e['id'] as int,
      leaveType: e['leave_type'] as String? ?? '',
      totalDays: e['total_days'] as int? ?? 0,
      isPaid: e['is_paid'] as bool? ?? false,
    )).toList(),
  );
}
