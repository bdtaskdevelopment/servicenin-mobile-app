class LeaveBreakdown {
  final String leaveType;
  final int total;
  final int used;
  final int remaining;

  LeaveBreakdown({required this.leaveType, required this.total, required this.used, required this.remaining});
}

class LeaveBalance {
  final int totalRemaining;
  final int leaveTypeCount;
  final List<LeaveBreakdown> breakdown;

  LeaveBalance({required this.totalRemaining, required this.leaveTypeCount, required this.breakdown});
}

class LeaveListItem {
  final int id;
  final String reference;
  final String leaveType;
  final String fromDate;
  final String toDate;
  final int totalDays;
  final String applyDate;
  final String reason;
  final String address;
  final String status;
  final String hardCopy;
  final String? manager;
  final String? approvedDate;
  final int approvedDays;

  LeaveListItem({
    required this.id, required this.reference, required this.leaveType,
    required this.fromDate, required this.toDate, required this.totalDays,
    required this.applyDate, required this.reason, required this.address,
    required this.status, required this.hardCopy,
    this.manager, this.approvedDate, required this.approvedDays,
  });
}

class LeaveResponse {
  final LeaveBalance balance;
  final List<LeaveListItem> list;
  LeaveResponse({required this.balance, required this.list});
}

LeaveResponse leaveResponseFromMap(dynamic json) {
  final d = json['data'] as Map<String, dynamic>? ?? {};
  final b = d['balance'] as Map<String, dynamic>? ?? {};
  return LeaveResponse(
    balance: LeaveBalance(
      totalRemaining: b['total_remaining'] as int? ?? 0,
      leaveTypeCount: b['leave_type_count'] as int? ?? 0,
      breakdown: (b['breakdown'] as List? ?? []).map((e) => LeaveBreakdown(
        leaveType: e['leave_type'] as String? ?? '',
        total: e['total'] as int? ?? 0,
        used: e['used'] as int? ?? 0,
        remaining: e['remaining'] as int? ?? 0,
      )).toList(),
    ),
    list: (d['list'] as List? ?? []).map((e) => LeaveListItem(
      id: e['id'] as int,
      reference: e['reference'] as String? ?? '',
      leaveType: e['leave_type'] as String? ?? '',
      fromDate: e['from_date'] as String? ?? '',
      toDate: e['to_date'] as String? ?? '',
      totalDays: e['total_days'] as int? ?? 0,
      applyDate: e['apply_date'] as String? ?? '',
      reason: e['reason'] as String? ?? '',
      address: e['address'] as String? ?? '',
      status: e['status'] as String? ?? 'pending',
      hardCopy: e['hard_copy'] as String? ?? '--',
      manager: e['manager'] as String?,
      approvedDate: e['approved_date'] as String?,
      approvedDays: e['approved_days'] as int? ?? 0,
    )).toList(),
  );
}
