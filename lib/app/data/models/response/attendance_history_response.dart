AttendanceHistoryResponse attendanceHistoryResponseFromMap(dynamic src) {
  final m = src is Map<String, dynamic> ? src : Map<String, dynamic>.from(src as Map);
  final list = m['data'] as List? ?? [];
  return AttendanceHistoryResponse(
    status: m['status'] as bool? ?? false,
    message: m['message'] as String? ?? '',
    data: list.map((e) => AttendanceHistoryItem.fromMap(e as Map)).toList(),
  );
}

class AttendanceHistoryResponse {
  final bool status;
  final String message;
  final List<AttendanceHistoryItem> data;
  AttendanceHistoryResponse({required this.status, required this.message, required this.data});
}

class AttendanceHistoryItem {
  final String? checkIn;
  final String? checkOut;
  final String? workHours;
  final String status;

  AttendanceHistoryItem({
    this.checkIn,
    this.checkOut,
    this.workHours,
    required this.status,
  });

  factory AttendanceHistoryItem.fromMap(Map m) => AttendanceHistoryItem(
        checkIn: m['check_in'] as String?,
        checkOut: m['check_out'] as String?,
        workHours: m['work_hours'] as String?,
        status: m['status'] as String? ?? '',
      );
}
