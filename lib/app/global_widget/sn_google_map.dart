import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:latlong2/latlong.dart';

import 'sn_map.dart' show SnMapMarker;

/// Google Maps-backed map — used for the ambulance address-search flow,
/// where the real Google tiles/routing are wanted. Other modules keep using
/// the free [SnMap] (OpenStreetMap via flutter_map).
class SnGoogleMap extends StatefulWidget {
  const SnGoogleMap({
    super.key,
    required this.center,
    this.zoom = 14,
    this.markers = const [],
    this.route = const [],
    this.routeColor = const Color(0xFFE23744),
    this.interactive = true,
    this.fitToRoute = false,
    this.onTap,
  });

  final LatLng center;
  final double zoom;
  final List<SnMapMarker> markers;
  final List<LatLng> route;
  final Color routeColor;
  final bool interactive;

  /// When true and [route] has 2+ points, frames the camera to show the
  /// whole route instead of using [center]/[zoom].
  final bool fitToRoute;

  /// Fired with the tapped coordinate — lets callers drop a pin there
  /// (e.g. picking a destination directly on the map).
  final void Function(LatLng point)? onTap;

  @override
  State<SnGoogleMap> createState() => _SnGoogleMapState();
}

class _SnGoogleMapState extends State<SnGoogleMap> {
  gmap.GoogleMapController? _map;

  @override
  void didUpdateWidget(covariant SnGoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fitToRoute &&
        widget.route.length >= 2 &&
        widget.route != oldWidget.route) {
      _fit();
    }
  }

  Future<void> _fit() async {
    final map = _map;
    if (map == null || widget.route.length < 2) return;
    final bounds = _boundsOf(widget.route);
    await map.animateCamera(
      gmap.CameraUpdate.newLatLngBounds(bounds, 48),
    );
  }

  gmap.LatLngBounds _boundsOf(List<LatLng> pts) {
    var minLat = pts.first.latitude, maxLat = pts.first.latitude;
    var minLng = pts.first.longitude, maxLng = pts.first.longitude;
    for (final p in pts) {
      minLat = p.latitude < minLat ? p.latitude : minLat;
      maxLat = p.latitude > maxLat ? p.latitude : maxLat;
      minLng = p.longitude < minLng ? p.longitude : minLng;
      maxLng = p.longitude > maxLng ? p.longitude : maxLng;
    }
    return gmap.LatLngBounds(
      southwest: gmap.LatLng(minLat, minLng),
      northeast: gmap.LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return gmap.GoogleMap(
      initialCameraPosition: gmap.CameraPosition(
        target: gmap.LatLng(widget.center.latitude, widget.center.longitude),
        zoom: widget.zoom,
      ),
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      scrollGesturesEnabled: widget.interactive,
      zoomGesturesEnabled: widget.interactive,
      rotateGesturesEnabled: widget.interactive,
      tiltGesturesEnabled: widget.interactive,
      markers: widget.markers.map((m) {
        return gmap.Marker(
          markerId: gmap.MarkerId('${m.point.latitude},${m.point.longitude}'),
          position: gmap.LatLng(m.point.latitude, m.point.longitude),
          icon: gmap.BitmapDescriptor.defaultMarkerWithHue(_hueFor(m.color)),
        );
      }).toSet(),
      polylines: widget.route.length >= 2
          ? {
              gmap.Polyline(
                polylineId: const gmap.PolylineId('route'),
                points: widget.route
                    .map((p) => gmap.LatLng(p.latitude, p.longitude))
                    .toList(),
                color: widget.routeColor,
                width: 4,
              ),
            }
          : const {},
      onMapCreated: (c) {
        _map = c;
        if (widget.fitToRoute && widget.route.length >= 2) _fit();
      },
      onTap: widget.onTap == null
          ? null
          : (latLng) =>
              widget.onTap!(LatLng(latLng.latitude, latLng.longitude)),
    );
  }

  /// Approximates our brand colors with Google's preset marker hues (the
  /// default marker only accepts a hue, not an arbitrary color).
  double _hueFor(Color color) {
    if (color == const Color(0xFF16A34A)) return gmap.BitmapDescriptor.hueGreen;
    if (color == const Color(0xFFE23744)) return gmap.BitmapDescriptor.hueRed;
    return gmap.BitmapDescriptor.hueAzure;
  }
}
