import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// A lightweight free map (OpenStreetMap tiles via flutter_map) used across
/// the app — e.g. ambulance pickup/destination and live tracking.
class SnMap extends StatelessWidget {
  const SnMap({
    super.key,
    required this.center,
    this.zoom = 13.5,
    this.markers = const [],
    this.route = const [],
    this.routeColor = const Color(0xFFE23744),
    this.interactive = true,
  });

  final LatLng center;
  final double zoom;
  final List<SnMapMarker> markers;
  final List<LatLng> route;
  final Color routeColor;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.app.servicenin',
        ),
        if (route.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(points: route, strokeWidth: 4, color: routeColor),
            ],
          ),
        if (markers.isNotEmpty)
          MarkerLayer(
            markers: markers
                .map((m) => Marker(
                      point: m.point,
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: _Pin(color: m.color, icon: m.icon),
                    ))
                .toList(),
          ),
      ],
    );
  }
}

class SnMapMarker {
  const SnMapMarker(this.point, this.color, this.icon);
  final LatLng point;
  final Color color;
  final IconData icon;
}

class _Pin extends StatelessWidget {
  const _Pin({required this.color, required this.icon});
  final Color color;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25), blurRadius: 6),
            ],
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ],
    );
  }
}
