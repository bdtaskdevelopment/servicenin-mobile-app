import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import '../data.dart';

class BloodProvider extends BaseProvider {
  Future<Response> postData(String path, dynamic data) {
    return post(path, jsonEncode(data));
  }

  /// POST with text fields + up to a few photo files, multipart/form-data —
  /// mirrors NagarikProvider.postGrievanceMultipart. Used by "log a
  /// donation" so photos upload in the same request as the form fields.
  Future<Response> postMultipart(
    String path,
    Map<String, dynamic> fields,
    List<File> photos,
  ) {
    final form = FormData({
      for (final e in fields.entries)
        if (e.value != null && e.value.toString().isNotEmpty)
          e.key: e.value.toString(),
      if (photos.isNotEmpty)
        'photos': photos
            .map((f) => MultipartFile(f, filename: p.basename(f.path)))
            .toList(),
    });
    return post(path, form);
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

  Future<Response> deleteData(String path) {
    return delete(path);
  }
}
