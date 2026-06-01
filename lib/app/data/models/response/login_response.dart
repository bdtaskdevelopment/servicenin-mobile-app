import 'dart:convert';

LoginResponse loginResponseFromMap(dynamic src) =>
    LoginResponse.fromMap(src is String ? jsonDecode(src) : src as Map<String, dynamic>);

class LoginResponse {
  final bool status;
  final String message;
  final String token;
  final String tokenType;
  final int expiresIn;
  final EmployeeUser user;

  LoginResponse({
    required this.status,
    required this.message,
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory LoginResponse.fromMap(Map<String, dynamic> json) => LoginResponse(
        status: json['status'] == true || json['status'] == 'true',
        message: json['message'] ?? '',
        token: json['token'] ?? '',
        tokenType: json['token_type'] ?? 'bearer',
        expiresIn: json['expires_in'] ?? 0,
        user: EmployeeUser.fromMap(json['user'] ?? {}),
      );
}

class EmployeeUser {
  final int id;
  final String name;
  final String empId;
  final String title;
  final String? department;
  final String email;
  final String? avatar;

  EmployeeUser({
    required this.id,
    required this.name,
    required this.empId,
    required this.title,
    this.department,
    required this.email,
    this.avatar,
  });

  factory EmployeeUser.fromMap(Map<String, dynamic> json) => EmployeeUser(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        empId: json['emp_id']?.toString() ?? '',
        title: json['title'] ?? '',
        department: json['department'],
        email: json['email'] ?? '',
        avatar: json['avatar'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'emp_id': empId,
        'title': title,
        'department': department,
        'email': email,
        'avatar': avatar,
      };

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
