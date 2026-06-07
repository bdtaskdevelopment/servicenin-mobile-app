import 'package:get/get.dart';

import '../data.dart';

class InfoProvider extends BaseProvider {
  Future<Response> getData(String path) {
    return get(path);
  }
}
