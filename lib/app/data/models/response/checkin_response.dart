CheckInResponse checkInResponseFromMap(dynamic src) {
  final m = src is Map<String, dynamic> ? src : Map<String, dynamic>.from(src as Map);
  return CheckInResponse(
    status: m['status'] as bool? ?? false,
    message: m['message'] as String? ?? '',
    data: m['data'] != null ? CheckInData.fromMap(m['data'] as Map) : null,
  );
}

class CheckInResponse {
  final bool status;
  final String message;
  final CheckInData? data;
  CheckInResponse({required this.status, required this.message, this.data});
}

class CheckInData {
  final String time;
  final String date;

  CheckInData({required this.time, required this.date});

  factory CheckInData.fromMap(Map m) => CheckInData(
        time: m['time'] as String? ?? '',
        date: m['date'] as String? ?? '',
      );
}
