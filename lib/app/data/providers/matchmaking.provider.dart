import 'dart:convert';

import 'package:get/get.dart';

import '../data.dart';

class MatchmakingProvider extends BaseProvider {
  Future<Response> getData(String path) => get(path);

  Future<Response> postData(String path, dynamic data) =>
      post(path, jsonEncode(data));

  Future<Response> putData(String path, dynamic data) =>
      put(path, jsonEncode(data));

  Future<Response> patchData(String path, dynamic data) =>
      patch(path, jsonEncode(data));
}
