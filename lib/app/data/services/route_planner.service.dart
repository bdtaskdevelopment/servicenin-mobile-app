import 'dart:math';

import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

import '../../core/values/app_config.dart';

/// A driving route between two points.
class SnRoute {
  const SnRoute({
    required this.points,
    required this.distanceKm,
    required this.durationMin,
  });

  /// The road-following polyline, for drawing on the map.
  final List<LatLng> points;
  final double distanceKm;
  final double durationMin;
}

/// Road routing via the Google Directions API. Falls back to a straight-line
/// distance (haversine) if the request fails (offline, missing/invalid key).
class RoutePlannerService {
  RoutePlannerService._();
  static final RoutePlannerService instance = RoutePlannerService._();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
  ));

  Future<SnRoute> route(LatLng from, LatLng to) async {
    final key = AppConfig.googleMapsApiKey;
    if (key.isNotEmpty) {
      try {
        final res = await _dio.get(
          'https://maps.googleapis.com/maps/api/directions/json',
          queryParameters: {
            'origin': '${from.latitude},${from.longitude}',
            'destination': '${to.latitude},${to.longitude}',
            'mode': 'driving',
            'key': key,
          },
        );
        final routes = res.data is Map ? res.data['routes'] : null;
        if (routes is List && routes.isNotEmpty) {
          final r = routes.first as Map;
          final legs = r['legs'] as List;
          final leg = legs.first as Map;
          final encoded = (r['overview_polyline'] as Map)['points'].toString();
          return SnRoute(
            points: _decodePolyline(encoded),
            distanceKm: (leg['distance']['value'] as num).toDouble() / 1000,
            durationMin: (leg['duration']['value'] as num).toDouble() / 60,
          );
        }
      } catch (_) {
        // Fall through to the straight-line estimate below.
      }
    }
    return SnRoute(
      points: [from, to],
      distanceKm: _haversineKm(from, to),
      durationMin: 0,
    );
  }

  /// Standard Google polyline algorithm decoder.
  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0, lat = 0, lng = 0;
    while (index < encoded.length) {
      int shift = 0, result = 0, b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  double _haversineKm(LatLng a, LatLng b) {
    const earthRadiusKm = 6371.0;
    final dLat = _radians(b.latitude - a.latitude);
    final dLon = _radians(b.longitude - a.longitude);
    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(_radians(a.latitude)) *
            cos(_radians(b.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return earthRadiusKm * 2 * atan2(sqrt(h), sqrt(1 - h));
  }

  double _radians(double degrees) => degrees * pi / 180;
}
