// lib/app/repositories.dart
// One provider per API group, all sharing the authenticated Dio (JWT interceptor).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import '../features/ambulance/data/ambulance_api.dart';
import '../features/blood/data/blood_api.dart';
import '../features/services/data/services_api.dart';
import '../features/healthcare/data/healthcare_api.dart';
import '../features/more/data/more_apis.dart';

final _dio = Provider((ref) => ref.watch(apiClientProvider).dio);

final ambulanceRepo = Provider((ref) => AmbulanceRepository(ref.watch(_dio)));
final bloodRepo = Provider((ref) => BloodRepository(ref.watch(_dio)));
final servicesRepo = Provider((ref) => ServicesRepository(ref.watch(_dio)));
final healthcareRepo = Provider((ref) => HealthcareRepository(ref.watch(_dio)));
final physioRepo = Provider((ref) => PhysioRepository(ref.watch(_dio)));
final matchmakingRepo = Provider((ref) => MatchmakingRepository(ref.watch(_dio)));
final jobsRepo = Provider((ref) => JobsRepository(ref.watch(_dio)));
final educationRepo = Provider((ref) => EducationRepository(ref.watch(_dio)));
final nagarikRepo = Provider((ref) => NagarikRepository(ref.watch(_dio)));
final infoRepo = Provider((ref) => InfoRepository(ref.watch(_dio)));
final funeralRepo = Provider((ref) => FuneralRepository(ref.watch(_dio)));
