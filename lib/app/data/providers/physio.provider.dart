import 'dart:convert';

import 'package:get/get.dart';

import '../data.dart';

class PhysioProvider extends BaseProvider {
  Future<Response> getData(String path) => get(path);

  Future<Response> postData(String path, dynamic data) =>
      post(path, jsonEncode(data));
}
