import 'dart:convert';

import 'package:get/get.dart';

import '../data.dart';

class AppProvider extends BaseProvider {
  Future<Response> getData(String path) {
    return get(path);
  }

  Future<Response> postData(String path, data) {
    return post(path, jsonEncode(data));
  }

  Future<Response> postMultipartData(String path, data) {
    return post(path, data);
  }

  Future<Response> putData(String path, data) {
    return put(path, jsonEncode(data));
  }
}
