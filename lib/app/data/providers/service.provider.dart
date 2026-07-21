import 'dart:convert';

import 'package:get/get.dart';

import '../data.dart';

class ServiceProvider extends BaseProvider {
  Future<Response> getData(String path) => get(path);

  Future<Response> postData(String path, dynamic data) =>
      post(path, jsonEncode(data));

  Future<Response> patchData(String path, dynamic data) =>
      patch(path, jsonEncode(data));

  Future<Response> deleteData(String path) => delete(path);
}
