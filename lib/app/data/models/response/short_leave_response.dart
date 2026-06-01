class ShortLeaveItem {
  final int id;
  final String reference;
  final String applyDate;
  final String leaveDate;
  final String startTime;
  final String endTime;
  final String totalTime;
  final String reason;
  final String status;
  final int statusCode;

  ShortLeaveItem({
    required this.id, required this.reference, required this.applyDate,
    required this.leaveDate, required this.startTime, required this.endTime,
    required this.totalTime, required this.reason,
    required this.status, required this.statusCode,
  });
}

class ShortLeaveResponse {
  final List<ShortLeaveItem> data;
  ShortLeaveResponse({required this.data});
}

ShortLeaveResponse shortLeaveResponseFromMap(dynamic json) {
  return ShortLeaveResponse(
    data: (json['data'] as List? ?? []).map((e) => ShortLeaveItem(
      id: e['id'] as int,
      reference: e['reference'] as String? ?? '',
      applyDate: e['apply_date'] as String? ?? '',
      leaveDate: e['leave_date'] as String? ?? '',
      startTime: e['start_time'] as String? ?? '',
      endTime: e['end_time'] as String? ?? '',
      totalTime: e['total_time'] as String? ?? '',
      reason: e['reason'] as String? ?? '',
      status: e['status'] as String? ?? 'Pending',
      statusCode: e['status_code'] as int? ?? 0,
    )).toList(),
  );
}
