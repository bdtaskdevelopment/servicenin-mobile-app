import 'dart:convert';

import 'package:get/get.dart';

import '../../core/helpers/app_helper.dart';

abstract class BaseResponse {
  BaseResponse._();
  static bool handleApiResponse(Response res) {
    try {
      if (res.statusCode == 200 || res.statusCode == 201) {
        final Map<String, dynamic> body = res.body is String
            ? jsonDecode(res.body)
            : res.body;

        final status = body['status'];
        return status == true || status == 'success';
      }
      return false;
    } catch (e) {
      printLog('API parse error: $e');
      return false;
    }
  }
}


class ApiException implements Exception {
  final int? statusCode;
  final String message;

  ApiException({this.statusCode, required this.message});
}

