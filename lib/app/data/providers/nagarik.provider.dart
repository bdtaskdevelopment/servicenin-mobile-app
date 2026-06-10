import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import '../data.dart';

class NagarikProvider extends BaseProvider {
  Future<Response> getData(String path) => get(path);

  Future<Response> postData(String path, dynamic data) =>
      post(path, jsonEncode(data));

  /// Files a grievance as multipart/form-data. Text fields are sent as
  /// strings; each image is appended under a repeated `images` key.
  Future<Response> postGrievanceMultipart(
    String path,
    Map<String, dynamic> fields,
    List<File> images,
  ) {
    final form = FormData({
      for (final e in fields.entries)
        if (e.value != null && e.value.toString().isNotEmpty)
          e.key: e.value.toString(),
      if (images.isNotEmpty)
        'images': images
            .map((f) => MultipartFile(f, filename: p.basename(f.path)))
            .toList(),
    });
    return post(path, form);
  }
}
