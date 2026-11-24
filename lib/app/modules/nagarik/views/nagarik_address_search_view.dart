import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/sn_place.dart';
import '../../../data/services/geo_search.service.dart';

const _green = Color(0xFF15803C);

/// Full-screen "search for an address" page backed by Google Places
/// Autocomplete — same shape as the other modules' address-search screens
/// (e.g. FuneralAddressSearchView), just themed for Nagarik Sheba. Pop with
/// an [SnPlace] when the user picks a result, or `null` if they back out.
class NagarikAddressSearchView extends StatefulWidget {
  const NagarikAddressSearchView({super.key, required this.title});
  final String title;

  @override
  State<NagarikAddressSearchView> createState() =>
      _NagarikAddressSearchViewState();
}

class _NagarikAddressSearchViewState extends State<NagarikAddressSearchView> {
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
      backgroundColor: const Color(0xFFF4F5FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    splashRadius: 22,
                    onPressed: () => Get.back(),
                    icon: const Icon(LucideIcons.chevronLeft,
                        size: 22, color: Color(0xFF0F172A)),
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
                      child: Center(
                        child: TextField(
                          controller: _ctrl,
                          focusNode: _focus,
                          onChanged: _onChanged,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            hintText: widget.title,
                            hintStyle: const TextStyle(
                                fontSize: 14, color: Color(0xFF94A3B8)),
                            suffixIcon: _ctrl.text.isEmpty
                                ? null
                                : IconButton(
                                    splashRadius: 16,
                                    icon: const Icon(LucideIcons.x,
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
    if (_ctrl.text.trim().isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Icon(LucideIcons.search, size: 32, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 10),
            Text('Search for your street, area or landmark.'.tr,
                style:
                    const TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8))),
          ],
        ),
      );
    }
    if (_loading || _resolving) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: CircularProgressIndicator(strokeWidth: 2.4, color: _green),
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
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFEDEFF2), indent: 56),
      itemBuilder: (_, i) {
        final p = _results[i];
        return ListTile(
          onTap: () => _pick(p),
          leading: const Icon(LucideIcons.mapPin,
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
