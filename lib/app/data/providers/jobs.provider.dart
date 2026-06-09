import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import '../data.dart';

class JobsProvider extends BaseProvider {
  Future<Response> getData(String path) => get(path);

  Future<Response> postData(String path, dynamic data) =>
      post(path, jsonEncode(data));

  /// Multipart resume upload. The API reads the `resume` field.
  Future<Response> uploadResume(String path, File file) {
    final name = p.basename(file.path);
    final form = FormData({
      'resume': MultipartFile(file, filename: name),
    });
    return post(path, form);
  }
}
