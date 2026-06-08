import 'dart:convert';

import 'package:get/get.dart';

import '../data.dart';

class AmbulanceProvider extends BaseProvider {
  Future<Response> postData(String path, dynamic data) {
    return post(path, jsonEncode(data));
  }

  Future<Response> getData(String path) {
    return get(path);
  }
}
