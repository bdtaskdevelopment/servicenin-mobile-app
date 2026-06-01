import 'dart:convert';

AttendanceLocationsResponse attendanceLocationsResponseFromMap(dynamic src) =>
    AttendanceLocationsResponse.fromMap(src is String ? jsonDecode(src) : src as Map<String, dynamic>);

class AttendanceLocationsResponse {
  final bool status;
  final String message;
  final List<AttendanceLocationData> data;

  AttendanceLocationsResponse({required this.status, required this.message, required this.data});

  factory AttendanceLocationsResponse.fromMap(Map<String, dynamic> json) =>
      AttendanceLocationsResponse(
        status: json['status'] == true,
        message: json['message'] ?? '',
        data: (json['data'] as List? ?? []).map((e) => AttendanceLocationData.fromMap(e)).toList(),
      );
}

class AttendanceLocationData {
  final String type;
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int range;

  AttendanceLocationData({
    required this.type,
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.range,
  });

  factory AttendanceLocationData.fromMap(Map<String, dynamic> json) => AttendanceLocationData(
        type: json['type'] ?? '',
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        range: json['range'] ?? 100,
      );
}
