import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import '../data.dart';

class HealthcareProvider extends BaseProvider {
  Future<Response> getData(String path) => get(path);

  Future<Response> postData(String path, dynamic data) =>
      post(path, jsonEncode(data));

  Future<Response> patchData(String path, dynamic data) =>
      patch(path, jsonEncode(data));

  /// Multipart upload of a report/attachment. The API reads the `file` field.
  Future<Response> uploadFile(String path, File file) {
    final name = p.basename(file.path);
    final form = FormData({
      'file': MultipartFile(file, filename: name),
    });
    return post(path, form);
  }
}
