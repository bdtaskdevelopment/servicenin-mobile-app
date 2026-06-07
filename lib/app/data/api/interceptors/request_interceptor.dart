import 'dart:async';

import 'package:servicenin/app/data/api/interceptors/response_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get_connect/http/src/request/request.dart';

import '../../../core/helpers/app_helper.dart';
import '../../../core/values/storage.dart';
import '../../services/storage.service.dart';

FutureOr<Request> requestInterceptor(request) async {
  if (await checkInternetConnection()) {
    final token = StorageService.read(StorageConstants.accessToken);

    // GetConnect sets the body content-type with a LOWERCASE key
    // (e.g. `content-type: multipart/form-data; boundary=...`). A
    // case-sensitive `['Content-Type']` lookup would miss it and add a second
    // `Content-Type: application/json` header, which makes the server ignore
    // the multipart body. Match the header case-insensitively so multipart
    // (and any pre-set content type) is preserved.
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
    // request.headers['Authorization'] = 'Bearer $token';

    printLog(request.headers);
    printLog(request);

    // Optionally show loading for non-GET requests
    if (request.method != 'get' && !EasyLoading.isShow) {
      // await EasyLoading.show(status: 'Loading...');
    }

    requestLogger(request);
    return request;
  } else {
    Helpers.toastSuccess("Internet connection failed !");
    throw Exception("No internet connection");
  }
}

void requestLogger(Request request) {
  print('URL => ${request.url}');
print('METHOD => ${request.method}');
print('HEADERS => ${request.headers}');

  debugPrint('Url====: ${request.method} ${request.url}\n');
}
