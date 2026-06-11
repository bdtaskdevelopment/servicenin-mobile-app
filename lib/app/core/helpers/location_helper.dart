import 'package:geolocator/geolocator.dart';

import '../values/storage.dart';
import '../../data/services/storage.service.dart';

/// Thin wrapper around `geolocator` that handles the service-enabled check,
/// the runtime permission flow, and caches the last known lat/long in storage.
class LocationService {
  LocationService._();

  /// Requests permission (the OS shows its dialog here if not yet decided) and
  /// returns the current device position, or `null` if the location service is
  /// off or the user denied access. On success the coordinates are cached in
  /// storage under [StorageConstants.latitude] / [StorageConstants.longitude].
  static Future<Position?> getCurrentPosition() async {
    // 1. Is the GPS / location service turned on at all?
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    // 2. Ask for permission — this triggers the system dialog when undecided.
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    // 3. Read the position and cache it.
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    await StorageService.save(StorageConstants.latitude, pos.latitude);
    await StorageService.save(StorageConstants.longitude, pos.longitude);
    return pos;
  }

  /// Last cached latitude, or `null` if we never captured one.
  static double? get cachedLat =>
      (StorageService.read(StorageConstants.latitude) as num?)?.toDouble();

  /// Last cached longitude, or `null` if we never captured one.
  static double? get cachedLng =>
      (StorageService.read(StorageConstants.longitude) as num?)?.toDouble();

  /// Opens the system app settings so the user can grant a permanently-denied
  /// location permission.
  static Future<bool> openSettings() => Geolocator.openAppSettings();
}
