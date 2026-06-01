// To parse this JSON data, do
//
//     final commonResponse = commonResponseFromMap(jsonString);

import 'dart:convert';

CommonResponse commonResponseFromMap(dynamic str) => CommonResponse.fromMap((str as dynamic));

String commonResponseToMap(CommonResponse data) => json.encode(data.toMap());

class CommonResponse {
  String? status;
  String? message;

  CommonResponse({
    this.status,
    this.message,
  });

  CommonResponse copyWith({
    String? status,
    String? message,
  }) =>
      CommonResponse(
        status: status ?? this.status,
        message: message ?? this.message,
      );

  factory CommonResponse.fromMap(Map<String, dynamic> json) => CommonResponse(
    status: json["status"]?.toString(),
    message: json["message"],
  );

  Map<String, dynamic> toMap() => {
    "status": status,
    "message": message,
  };
}
