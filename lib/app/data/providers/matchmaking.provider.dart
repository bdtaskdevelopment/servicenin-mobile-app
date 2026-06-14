import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import '../data.dart';

class MatchmakingProvider extends BaseProvider {
  Future<Response> getData(String path) => get(path);

  Future<Response> postData(String path, dynamic data) =>
      post(path, jsonEncode(data));

  Future<Response> putData(String path, dynamic data) =>
      put(path, jsonEncode(data));

  Future<Response> patchData(String path, dynamic data) =>
      patch(path, jsonEncode(data));

  /// Multipart document upload: `kind` + optional `remarks` + the `file`.
  Future<Response> uploadDocument(String path, File file,
      {required String kind, String remarks = ''}) {
    final name = p.basename(file.path);
    final form = FormData({
      'kind': kind,
      if (remarks.isNotEmpty) 'remarks': remarks,
      'file': MultipartFile(file, filename: name),
    });
    return post(path, form);
  }
}
