import 'dart:async';

import 'package:get/get_connect/http/src/request/request.dart';

import '../../../core/helpers/app_helper.dart';
import '../../../core/values/storage.dart';
import '../../services/storage.service.dart';

FutureOr<Request> authInterceptor(request) async {
  printLog('auth interceptor call ====');
  final token = StorageService.read(StorageConstants.accessToken);
  printLog(token);
  // Preserve a multipart content-type (file uploads set it with a boundary).
  // Forcing application/json here would strip the boundary and the server
  // would fail to parse the uploaded file (e.g. job resume/CV upload).
  final existingCt = request.headers.entries
      .firstWhere(
        (e) => e.key.toLowerCase() == 'content-type',
        orElse: () => const MapEntry('', ''),
      )
      .value;
  if (!existingCt.toLowerCase().contains('multipart')) {
    request.headers['Content-Type'] = 'application/json';
  }
  request.headers['Accept'] = 'application/json';
  if (token != null && token.isNotEmpty) {
    request.headers['Authorization'] = 'Bearer $token';
  }

  return request;
}
