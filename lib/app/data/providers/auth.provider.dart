import 'dart:convert';

import 'package:get/get.dart';

import '../../core/helpers/app_helper.dart';
import '../data.dart';

class AuthProvider extends BaseProvider {
  Future<Response> getData(String path) {
    return get(path);
  }

  Future<Response> postData(String path, data) {
    printLog(data);
    printLog("data===");
    return post(path, jsonEncode(data));
  }

  Future<Response> putData(String path, data) {
    return put(path, jsonEncode(data));
  }
}
