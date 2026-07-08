import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/sn_place.dart';
import '../../../data/services/geo_search.service.dart';
import '../../../global_widget/sn_google_map.dart';
import '../../../global_widget/sn_map.dart' show SnMapMarker;
import '../controllers/ambulance_controller.dart';

const _navy = Color(0xFF1E2A4A);
const _green = Color(0xFF16A34A);
const _red = Color(0xFFE23744);

/// Full-screen "search for an address" page backed by Google Places
/// Autocomplete. Pop with an [SnPlace] when the user picks a result, or
/// `null` if they back out.
class PlaceSearchView extends StatefulWidget {
  const PlaceSearchView({super.key, required this.title});
  final String title;

  @override
  State<PlaceSearchView> createState() => _PlaceSearchViewState();
}

class _PlaceSearchViewState extends State<PlaceSearchView> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  List<PlacePrediction> _results = [];
  bool _loading = false;
  bool _resolving = false;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final results = await GeoSearchService.instance.autocomplete(q);
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
        _searched = true;
      });
    });
  }

  Future<void> _pick(PlacePrediction p) async {
    setState(() => _resolving = true);
    final place = await GeoSearchService.instance.details(p);
    if (!mounted) return;
    setState(() => _resolving = false);
    if (place != null) Get.back(result: place);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    splashRadius: 22,
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: Color(0xFF1A1A1A)),
                  ),
                  Expanded(
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        focusNode: _focus,
                        onChanged: _onChanged,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: widget.title,
                          hintStyle:
                              const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                          suffixIcon: _ctrl.text.isEmpty
                              ? null
                              : IconButton(
                                  splashRadius: 16,
                                  icon: const Icon(Icons.close_rounded,
                                      size: 18, color: Color(0xFF94A3B8)),
                                  onPressed: () {
                                    _ctrl.clear();
                                    _onChanged('');
                                  },
                                ),
                        ),
                        style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    // Nothing typed yet — show the live map (with pickup/destination pins
    // already chosen) instead of a blank page. Tapping a spot on it picks
    // that point directly, same as tapping a search result below.
    if (_ctrl.text.trim().isEmpty) {
      return _PreviewMap(onPicked: (place) => Get.back(result: place));
    }
    if (_loading || _resolving) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: CircularProgressIndicator(strokeWidth: 2.4, color: _navy),
        ),
      );
    }
    if (_searched && _results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text('No matching places found.'.tr,
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8))),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _results.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: Color(0xFFEDEFF2), indent: 56),
      itemBuilder: (_, i) {
        final p = _results[i];
        return ListTile(
          onTap: () => _pick(p),
          leading: const Icon(Icons.location_on_outlined,
              color: Color(0xFF94A3B8), size: 22),
          title: Text(p.mainText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A))),
          subtitle: Text(p.secondaryText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        );
      },
    );
  }
}

/// Live map shown before the user types anything, so the page never looks
/// blank — mirrors Google Maps showing the current trip while editing it.
/// Tapping anywhere on it drops a pin there and, once confirmed, resolves
/// straight to a picked [SnPlace] — no typing required.
class _PreviewMap extends StatefulWidget {
  const _PreviewMap({required this.onPicked});
  final ValueChanged<SnPlace> onPicked;

  @override
  State<_PreviewMap> createState() => _PreviewMapState();
}

class _PreviewMapState extends State<_PreviewMap> {
  LatLng? _tapped;
  String? _address;
  bool _resolving = false;

  Future<void> _onTap(LatLng point) async {
    setState(() {
      _tapped = point;
      _address = null;
      _resolving = true;
    });
    final address = await GeoSearchService.instance.reverse(point);
    if (!mounted || _tapped != point) return;
    setState(() {
      _address = address ??
          '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
      _resolving = false;
    });
  }

  void _confirm() {
    final point = _tapped;
    final address = _address;
    if (point == null || address == null) return;
    widget.onPicked(SnPlace(label: address, address: address, point: point));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AmbulanceController>(
      builder: (amb) {
        final p = amb.pickupPoint;
        final d = amb.destPoint;
        final tapped = _tapped;
        final hasRoute = tapped == null && amb.hasTrip && amb.routePoints.length >= 2;
        return Stack(
          children: [
            SnGoogleMap(
              center: p,
              zoom: 14,
              fitToRoute: hasRoute,
              route: hasRoute ? amb.routePoints : const [],
              onTap: _onTap,
              markers: [
                SnMapMarker(p, _green, Icons.my_location_rounded),
                if (tapped != null)
                  SnMapMarker(tapped, _red, Icons.location_on_rounded)
                else if (amb.dropPlace != null)
                  SnMapMarker(d, _red, Icons.location_on_rounded),
              ],
            ),
            if (tapped != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: _ConfirmPickCard(
                  address: _address,
                  loading: _resolving,
                  onConfirm: _confirm,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Bottom card shown after tapping a point on [_PreviewMap], letting the
/// user confirm the reverse-geocoded address before it's used.
class _ConfirmPickCard extends StatelessWidget {
  const _ConfirmPickCard({
    required this.address,
    required this.loading,
    required this.onConfirm,
  });
  final String? address;
  final bool loading;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.location_on_rounded, color: _red, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: loading
                    ? Text('Locating address...'.tr,
                        style: const TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)))
                    : Text(address ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: loading ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Set this location'.tr,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
