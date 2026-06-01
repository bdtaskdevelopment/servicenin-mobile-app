import 'package:get/get.dart';

import '../../core/values/app_config.dart';
import '../../core/values/app_dismens.dart';
import '../../core/values/storage.dart';
import '../services/storage.service.dart';
import 'api.dart';

class BaseProvider extends GetConnect {
  @override
  void onInit() {
    final token = StorageService.read(StorageConstants.accessToken);
    httpClient.baseUrl = AppConfig.baseUrl;
    httpClient.timeout = Duration(seconds: AppDismens.timeout);
    if (token != null) {
      httpClient.addAuthenticator(authInterceptor);
    }
    httpClient.addRequestModifier(requestInterceptor);
    httpClient.addResponseModifier(responseInterceptor);
    print("base provider is connect");
  }
}
