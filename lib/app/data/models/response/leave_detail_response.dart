class LeaveDetailItem {
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
  final String? hardCopyUrl;
  final String? manager;
  final String? managerComment;
  final String? approvedDate;
  final String? approvedStart;
  final String? approvedEnd;
  final int approvedDays;

  LeaveDetailItem({
    required this.id,
    required this.reference,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.totalDays,
    required this.applyDate,
    required this.reason,
    required this.address,
    required this.status,
    required this.hardCopy,
    this.hardCopyUrl,
    this.manager,
    this.managerComment,
    this.approvedDate,
    this.approvedStart,
    this.approvedEnd,
    required this.approvedDays,
  });

  factory LeaveDetailItem.fromMap(Map<String, dynamic> m) => LeaveDetailItem(
        id: (m['id'] as num?)?.toInt() ?? 0,
        reference: m['reference'] as String? ?? '',
        leaveType: m['leave_type'] as String? ?? '',
        fromDate: m['from_date'] as String? ?? '',
        toDate: m['to_date'] as String? ?? '',
        totalDays: (m['total_days'] as num?)?.toInt() ?? 0,
        applyDate: m['apply_date'] as String? ?? '',
        reason: m['reason'] as String? ?? '',
        address: m['address'] as String? ?? '',
        status: m['status'] as String? ?? 'pending',
        hardCopy: m['hard_copy'] as String? ?? '--',
        hardCopyUrl: m['hard_copy_url'] as String?,
        manager: m['manager'] as String?,
        managerComment: m['manager_comment'] as String?,
        approvedDate: m['approved_date'] as String?,
        approvedStart: m['approved_start'] as String?,
        approvedEnd: m['approved_end'] as String?,
        approvedDays: (m['approved_days'] as num?)?.toInt() ?? 0,
      );
}

LeaveDetailItem leaveDetailFromMap(dynamic body) {
  final data = body['data'] as Map<String, dynamic>;
  return LeaveDetailItem.fromMap(data);
}
