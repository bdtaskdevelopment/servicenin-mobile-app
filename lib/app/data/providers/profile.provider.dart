import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import '../data.dart';

class ProfileProvider extends BaseProvider {
  Future<Response> getData(String path) {
    return get(path);
  }

  Future<Response> putData(String path, dynamic data) {
    return put(path, jsonEncode(data));
  }

  /// Multipart upload of the avatar. The API reads it from the `photo` field.
  Future<Response> uploadPhoto(String path, File file) {
    final name = p.basename(file.path);
    final form = FormData({
      'photo': MultipartFile(
        file,
        filename: name,
        contentType: _imageContentType(name),
      ),
    });
    return post(path, form);
  }

  String _imageContentType(String filename) {
    final ext = p.extension(filename).toLowerCase();
    switch (ext) {
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.heic':
        return 'image/heic';
      case '.jpg':
      case '.jpeg':
      default:
        return 'image/jpeg';
    }
  }
}
