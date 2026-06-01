AttendanceStatusResponse attendanceStatusResponseFromMap(dynamic src) {
  final m = src is Map<String, dynamic> ? src : Map<String, dynamic>.from(src as Map);
  return AttendanceStatusResponse(
    status: m['status'] as bool? ?? false,
    message: m['message'] as String? ?? '',
    data: m['data'] != null
        ? AttendanceStatusData.fromMap(m['data'] as Map)
        : null,
  );
}

class AttendanceStatusResponse {
  final bool status;
  final String message;
  final AttendanceStatusData? data;
  AttendanceStatusResponse({required this.status, required this.message, this.data});
}

class AttendanceStatusData {
  final String? checkin;
  final String? checkout;
  final String? breakOut;
  final String? breakIn;
  final String breakDuration;

  AttendanceStatusData({
    this.checkin,
    this.checkout,
    this.breakOut,
    this.breakIn,
    required this.breakDuration,
  });

  factory AttendanceStatusData.fromMap(Map m) => AttendanceStatusData(
        checkin:       m['checkin']   as String?,
        checkout:      m['checkout']  as String?,
        breakOut:      m['break_out'] as String?,
        breakIn:       m['break_in']  as String?,
        breakDuration: m['break']     as String? ?? '00:00:00',
      );
}
