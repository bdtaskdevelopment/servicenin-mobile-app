import 'dart:convert';

ProfileResponse profileResponseFromMap(dynamic src) =>
    ProfileResponse.fromMap(src is String ? jsonDecode(src) : src as Map<String, dynamic>);

class ProfileResponse {
  final bool status;
  final String message;
  final ProfileData data;

  ProfileResponse({required this.status, required this.message, required this.data});

  factory ProfileResponse.fromMap(Map<String, dynamic> json) => ProfileResponse(
        status: json['status'] == true,
        message: json['message'] ?? '',
        data: ProfileData.fromMap(json['data'] ?? {}),
      );
}

class ProfileData {
  final int id;
  final String name;
  final String firstName;
  final String empId;
  final String title;
  final String? department;
  final String? joined;
  final String? reportingTo;
  final String? reportingTitle;
  final String? phone;
  final String email;
  final String? address;
  final String? dob;
  final String? bloodGroup;
  final String? maritalStatus;
  final String? avatar;
  final int rating;

  ProfileData({
    required this.id,
    required this.name,
    required this.firstName,
    required this.empId,
    required this.title,
    this.department,
    this.joined,
    this.reportingTo,
    this.reportingTitle,
    this.phone,
    required this.email,
    this.address,
    this.dob,
    this.bloodGroup,
    this.maritalStatus,
    this.avatar,
    required this.rating,
  });

  factory ProfileData.fromMap(Map<String, dynamic> json) => ProfileData(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        firstName: json['first_name'] ?? '',
        empId: json['emp_id']?.toString() ?? '',
        title: json['title'] ?? '',
        department: json['department'],
        joined: json['joined'],
        reportingTo: json['reporting_to'],
        reportingTitle: json['reporting_title'],
        phone: json['phone'],
        email: json['email'] ?? '',
        address: json['address'],
        dob: json['dob'],
        bloodGroup: json['blood_group'],
        maritalStatus: json['marital_status'] is Map
            ? json['marital_status']['name']
            : json['marital_status'],
        avatar: json['avatar'],
        rating: json['rating'] ?? 0,
      );

  String get initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String initialsOf(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '?';
    final parts = fullName.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
