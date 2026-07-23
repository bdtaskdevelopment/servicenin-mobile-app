import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

import '../models/sn_place.dart';
import 'settings.service.dart';

/// A place suggestion from Google Places Autocomplete. Doesn't carry
/// coordinates yet — call [GeoSearchService.details] with [placeId] to
/// resolve them (a separate Place Details call, same as the Google Maps app).
class PlacePrediction {
  const PlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });
  final String placeId;
  final String mainText;
  final String secondaryText;
}

/// Place search (Google Places Autocomplete + Place Details) and reverse
/// geocoding (Google Geocoding), biased to Bangladesh.
class GeoSearchService {
  GeoSearchService._();
  static final GeoSearchService instance = GeoSearchService._();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
  ));

  String get _key => SettingsService.to.googleMapsApiKey;

  /// Autocomplete predictions for [query]. Returns an empty list on any
  /// failure (offline, missing/invalid key, malformed response) — search is
  /// a nice-to-have, not something that should crash the screen.
  Future<List<PlacePrediction>> autocomplete(String query) async {
    final q = query.trim();
    if (q.isEmpty || _key.isEmpty) return const [];
    try {
      final res = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': q,
          'components': 'country:bd',
          'key': _key,
        },
      );
      final preds = res.data is Map ? res.data['predictions'] : null;
      if (preds is! List) return const [];
      return preds.whereType<Map>().map((p) {
        final structured = p['structured_formatting'];
        final main = structured is Map
            ? (structured['main_text'] ?? '').toString()
            : (p['description'] ?? '').toString();
        final secondary =
            structured is Map ? (structured['secondary_text'] ?? '').toString() : '';
        return PlacePrediction(
          placeId: (p['place_id'] ?? '').toString(),
          mainText: main.isEmpty ? (p['description'] ?? '').toString() : main,
          secondaryText: secondary,
        );
      }).where((p) => p.placeId.isNotEmpty).toList();
    } catch (_) {
      return const [];
    }
  }

  /// Resolves a predicted place to its coordinates via Place Details.
  Future<SnPlace?> details(PlacePrediction prediction) async {
    if (_key.isEmpty) return null;
    try {
      final res = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': prediction.placeId,
          'fields': 'geometry,formatted_address,name',
          'key': _key,
        },
      );
      final result = res.data is Map ? res.data['result'] : null;
      if (result is! Map) return null;
      final loc = (result['geometry'] as Map?)?['location'];
      if (loc is! Map) return null;
      final lat = (loc['lat'] as num?)?.toDouble();
      final lng = (loc['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) return null;
      final address = (result['formatted_address'] ?? prediction.secondaryText)
          .toString();
      return SnPlace(
        label: prediction.mainText,
        address: address,
        point: LatLng(lat, lng),
      );
    } catch (_) {
      return null;
    }
  }

  /// Reverse-geocodes a point to a display address, or `null` on failure.
  Future<String?> reverse(LatLng point) async {
    if (_key.isEmpty) return null;
    try {
      final res = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'latlng': '${point.latitude},${point.longitude}',
          'key': _key,
        },
      );
      final results = res.data is Map ? res.data['results'] : null;
      if (results is List && results.isNotEmpty) {
        return (results.first['formatted_address'] ?? '').toString();
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
