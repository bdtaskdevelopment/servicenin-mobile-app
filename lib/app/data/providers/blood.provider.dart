import 'dart:convert';

import 'package:get/get.dart';

import '../data.dart';

class BloodProvider extends BaseProvider {
  Future<Response> postData(String path, dynamic data) {
    return post(path, jsonEncode(data));
  }

  Future<Response> patchData(String path, dynamic data) {
    return patch(path, jsonEncode(data));
  }

  Future<Response> putData(String path, dynamic data) {
    return put(path, jsonEncode(data));
  }

  Future<Response> getData(String path) {
    return get(path);
  }
}
