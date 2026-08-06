import 'package:get/get.dart';

import '../data.dart';

class SupportProvider extends BaseProvider {
  Future<Response> getData(String path) => get(path);
}
