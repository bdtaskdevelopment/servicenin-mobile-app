import 'dart:convert';

import 'package:get/get.dart';

import '../data.dart';

class HomeProvider extends BaseProvider {
  Future<Response> getData(String path) {
    return get(path);
  }

  Future<Response> getProfile(String path) {
    return get(path);
  }

  Future<Response> postData(String path, data) {
    return post(path, jsonEncode(data));
  }

  Future<Response> postModelData(String path, data) {
    return post(path, data);
  }

  Future<Response> postDataVat(String path, data) {
    return post(path, (data));
  }

  Future<Response> putData(String path, data) {
    return put(path, jsonEncode(data));
  }

  Future<Response> postDataMap(String path, data) {
    return post(path, data);
  }

  Future<Response> postMultipartData(String path, data) {
    return post(path, data);
  }

  Future<Response> putDataMap(String path, data) {
    return put(path, data);
  }

  Future<Response> deleteDataMap(String path) {
    return delete(path);
  }

  // Future<Response> postMultipartData(String path, data) {
  //   return post(path, data);
  // }

  Future<Response> deleteData(String path) {
    return delete(path);
  }

  Future<Response> patchData(String path, data) {
    return patch(path, jsonEncode(data));
  }
}
