import 'dart:async';

import 'package:get/get_connect/http/src/request/request.dart';

import '../../../core/helpers/app_helper.dart';
import '../../../core/values/storage.dart';
import '../../services/storage.service.dart';

FutureOr<Request> authInterceptor(request) async {
  printLog('auth interceptor call ====');
  final token = StorageService.read(StorageConstants.accessToken);
  printLog(token);
  request.headers['Content-Type'] = 'application/json';
  request.headers['Accept'] = 'application/json';
  if (token != null && token.isNotEmpty) {
    request.headers['Authorization'] = 'Bearer $token';
  }

  return request;
}
