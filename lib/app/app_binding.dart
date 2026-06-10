
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_controller.dart';
import 'app_service.dart';
import 'core/values/app_config.dart';
import 'data/providers/ambulance.provider.dart';
import 'data/providers/healthcare.provider.dart';
import 'data/providers/service.provider.dart';
import 'data/providers/physio.provider.dart';
import 'data/providers/matchmaking.provider.dart';
import 'data/providers/jobs.provider.dart';
import 'data/providers/funeral.provider.dart';
import 'data/providers/education.provider.dart';
import 'data/providers/nagarik.provider.dart';
import 'data/providers/home.provider.dart';
import 'data/providers/app.provider.dart';
import 'data/providers/auth.provider.dart';
import 'data/providers/blood.provider.dart';
import 'data/providers/info.provider.dart';
import 'data/providers/profile.provider.dart';
import 'data/repositories/ambulance.repo.dart';
import 'data/repositories/healthcare.repo.dart';
import 'data/repositories/service.repo.dart';
import 'data/repositories/physio.repo.dart';
import 'data/repositories/matchmaking.repo.dart';
import 'data/repositories/jobs.repo.dart';
import 'data/repositories/funeral.repo.dart';
import 'data/repositories/education.repo.dart';
import 'data/repositories/nagarik.repo.dart';
import 'data/repositories/home.repo.dart';
import 'data/repositories/app.repo.dart';
import 'data/repositories/auth.repo.dart';
import 'data/repositories/blood.repo.dart';
import 'data/repositories/info.repo.dart';
import 'data/repositories/profile.repo.dart';
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

    Get.lazyPut<BloodProvider>(() => BloodProvider(), fenix: true);
    Get.lazyPut<BloodRepository>(
      () => BloodRepository(provider: Get.find()),
      fenix: true,
    );

    Get.lazyPut<AmbulanceProvider>(() => AmbulanceProvider(), fenix: true);
    Get.lazyPut<AmbulanceRepository>(
      () => AmbulanceRepository(provider: Get.find()),
      fenix: true,
    );

    Get.lazyPut<HealthcareProvider>(() => HealthcareProvider(), fenix: true);
    Get.lazyPut<HealthcareRepository>(
      () => HealthcareRepository(provider: Get.find()),
      fenix: true,
    );

    Get.lazyPut<ServiceProvider>(() => ServiceProvider(), fenix: true);
    Get.lazyPut<ServiceRepository>(
      () => ServiceRepository(provider: Get.find()),
      fenix: true,
    );

    Get.lazyPut<PhysioProvider>(() => PhysioProvider(), fenix: true);
    Get.lazyPut<PhysioRepository>(
      () => PhysioRepository(provider: Get.find()),
      fenix: true,
    );

    Get.lazyPut<MatchmakingProvider>(() => MatchmakingProvider(),
        fenix: true);
    Get.lazyPut<MatchmakingRepository>(
      () => MatchmakingRepository(provider: Get.find()),
      fenix: true,
    );

    Get.lazyPut<JobsProvider>(() => JobsProvider(), fenix: true);
    Get.lazyPut<JobsRepository>(
      () => JobsRepository(provider: Get.find()),
      fenix: true,
    );

    Get.lazyPut<FuneralProvider>(() => FuneralProvider(), fenix: true);
    Get.lazyPut<FuneralRepository>(
      () => FuneralRepository(provider: Get.find()),
      fenix: true,
    );

    Get.lazyPut<EducationProvider>(() => EducationProvider(), fenix: true);
    Get.lazyPut<EducationRepository>(
      () => EducationRepository(provider: Get.find()),
      fenix: true,
    );

    Get.lazyPut<NagarikProvider>(() => NagarikProvider(), fenix: true);
    Get.lazyPut<NagarikRepository>(
      () => NagarikRepository(provider: Get.find()),
      fenix: true,
    );

    Get.lazyPut<HomeProvider>(() => HomeProvider(), fenix: true);
    Get.lazyPut<HomeRepository>(
      () => HomeRepository(provider: Get.find()),
      fenix: true,
    );

    Get.lazyPut<ProfileProvider>(() => ProfileProvider(), fenix: true);
    Get.lazyPut<ProfileRepository>(
      () => ProfileRepository(provider: Get.find()),
      fenix: true,
    );

    Get.lazyPut<InfoProvider>(() => InfoProvider(), fenix: true);
    Get.lazyPut<InfoRepository>(
      () => InfoRepository(provider: Get.find()),
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
