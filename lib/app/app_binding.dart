
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_controller.dart';
import 'app_service.dart';
import 'core/values/app_config.dart';
import 'data/providers/app.provider.dart';
import 'data/providers/auth.provider.dart';
import 'data/providers/home.provider.dart';
import 'data/repositories/app.repo.dart';
import 'data/repositories/auth.repo.dart';
import 'data/repositories/home.repo.dart';
import 'data/services/storage.service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {}
}

class AppDependencyInjection {
  static void init() {
    Get.lazyPut<GetConnect>(() => GetConnect(), fenix: true);

    Get.lazyPut<AppProvider>(() => AppProvider(), fenix: true);
    Get.lazyPut<AppRepository>(
      () => AppRepository(appProvider: Get.find()),
      fenix: true,
    );

    Get.lazyPut<AuthProvider>(() => AuthProvider(), fenix: true);
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(authProvider: Get.find()),
      fenix: true,
    );
    Get.lazyPut<AppController>(() => AppController(), fenix: true);

    Get.lazyPut<HomeProvider>(() => HomeProvider(), fenix: true);
    Get.lazyPut<HomeRepository>(
      () => HomeRepository(homeProvider: Get.find()),
      fenix: true,
    );
    

    Get.lazyPut<AppService>(() => AppService());

    Get.putAsync<SharedPreferences>(() async {
      var pref = await SharedPreferences.getInstance();
      return pref;
    });
    Get.lazyPut<GetConnect>(
      () =>
          GetConnect(timeout: const Duration(seconds: 500))
            ..baseUrl = AppConfig.baseUrl,
      fenix: true,
    );
    Get.lazyPut(() => StorageService(), fenix: true);
    Get.lazyPut<AppProvider>(() => AppProvider(), fenix: true);

    Get.lazyPut<ConnectivityService>(() => ConnectivityService(), fenix: true);
  }
}
