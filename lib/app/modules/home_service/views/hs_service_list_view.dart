import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_config.dart';
import '../../../data/models/response/service_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/home_service_controller.dart';

const _teal = Color(0xFF0E9F8E);
const _darkTeal = Color(0xFF0E7C6B);

/// Resolves an admin-uploaded icon URL, which may already be absolute (S3)
/// or a server-relative path (`/static/...`, local dev storage) — same
/// convention as `_providerPhotoUrl` in hs_my_bookings_view.dart.
String _iconUrl(String path) {
  if (path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  final base = AppConfig.baseUrl.endsWith('/')
      ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
      : AppConfig.baseUrl;
  return path.startsWith('/') ? '$base$path' : '$base/$path';
}

/// Small rounded thumbnail used as the leading icon for a sub-service row —
/// the uploaded image when present, else the generic fallback icon.
Widget _serviceThumb(HsServiceItem service, {double size = 36}) {
  return Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: _teal.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
    ),
    clipBehavior: Clip.antiAlias,
    child: service.imageUrl.isEmpty
        ? Icon(service.icon, size: size * 0.5, color: _darkTeal)
        : CachedNetworkImage(
            imageUrl: _iconUrl(service.imageUrl),
            fit: BoxFit.cover,
            width: size,
            height: size,
            placeholder: (_, __) =>
                Icon(service.icon, size: size * 0.5, color: _darkTeal),
            errorWidget: (_, __, ___) =>
                Icon(service.icon, size: size * 0.5, color: _darkTeal),
          ),
  );
}

class HsServiceListView extends GetView<HomeServiceController> {
  const HsServiceListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<HomeServiceController>(
          builder: (con) {
            final services = con.visibleServices;
            final isSearch = con.mode == HsListMode.search;
            return Column(
              children: [
                // Header
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(con.listTitle,
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                          Text('${services.length} ${'services available'.tr}',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                      const Spacer(),
                      if (!isSearch) ...[
                        GestureDetector(
                          onTap: con.openSearch,
                          child: const Icon(Icons.search_rounded,
                              color: Color(0xFF1A1A1A), size: 22),
                        ),
                        const SizedBox(width: 16),
                      ],
                      // Cart with live item-count badge → opens the cart page.
                      GestureDetector(
                        onTap: con.openCart,
                        behavior: HitTestBehavior.opaque,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.shopping_cart_outlined,
                                color: Color(0xFF1A1A1A), size: 24),
                            if (con.totalItems > 0)
                              Positioned(
                                right: -7,
                                top: -7,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  constraints: const BoxConstraints(
                                      minWidth: 18, minHeight: 18),
                                  decoration: const BoxDecoration(
                                      color: AppColors.brandOrange,
                                      shape: BoxShape.circle),
                                  alignment: Alignment.center,
                                  child: Text('${con.totalItems}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Always-visible filter/search bar: in category mode it
                // instantly filters the currently loaded sub-services by
                // name (no network call); in search mode (reached via the
                // search icon, or Home's "Search…"/"All →") it runs the
                // cross-category search as before.
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEFF1F4),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded,
                            color: Color(0xFF94A3B8)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            autofocus: isSearch,
                            onChanged: isSearch
                                ? con.onQueryChanged
                                : con.onSubFilterChanged,
                            decoration: InputDecoration(
                              hintText: (isSearch
                                      ? 'Search services…'
                                      : 'Filter services in this category…')
                                  .tr,
                              hintStyle:
                                  const TextStyle(color: Color(0xFF94A3B8)),
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                            style: const TextStyle(
                                fontSize: 14.5, color: Color(0xFF0F172A)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: (con.loadingSub || con.searching) && services.isEmpty
                      ? const SnListSkeleton(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 16))
                      : services.isEmpty
                          ? Center(
                              child: Text(
                                  isSearch
                                      ? 'Search for a service'.tr
                                      : 'No services found'.tr,
                                  style: const TextStyle(
                                      color: Color(0xFF94A3B8))))
                          : FadeInUp(
                              from: 18,
                              duration: const Duration(milliseconds: 350),
                              child: ListView(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                children: services
                                    .map((s) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child:
                                              _ServiceRow(service: s, con: con),
                                        ))
                                    .toList(),
                              ),
                            ),
                ),
                // Review booking bar
                if (con.totalItems > 0) _ReviewBar(con: con),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.service, required this.con});
  final HsServiceItem service;
  final HomeServiceController con;

  @override
  Widget build(BuildContext context) {
    // A sub-service with variants (e.g. AC capacity) expands in place to
    // show each option with its own price + Add/stepper, instead of a plain
    // single Add button — the customer books everything from this one page.
    if (service.hasVariants) {
      return _VariantAccordionRow(service: service, con: con);
    }
    final qty = con.qtyOf(service);
    final selected = qty > 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: selected ? _teal : const Color(0xFFEDEFF2),
            width: selected ? 1.5 : 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _serviceThumb(service),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(service.displayName,
                          style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${service.bnName} · ${service.duration}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
                const SizedBox(height: 8),
                Text(service.desc,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                Text('৳${service.price}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Align(
            alignment: Alignment.center,
            child: selected
                ? _Stepper(
                    qty: qty,
                    onMinus: () => con.dec(service),
                    onPlus: () => con.add(service))
                : _AddButton(onTap: () => con.add(service)),
          ),
        ],
      ),
    );
  }
}

/// A sub-service that has variants (e.g. AC capacity) — expands in place to
/// list every variant with its own price + Add/stepper, so the customer books
/// straight from this page instead of a separate picker screen.
class _VariantAccordionRow extends StatefulWidget {
  const _VariantAccordionRow({required this.service, required this.con});
  final HsServiceItem service;
  final HomeServiceController con;

  @override
  State<_VariantAccordionRow> createState() => _VariantAccordionRowState();
}

class _VariantAccordionRowState extends State<_VariantAccordionRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final con = widget.con;
    // Any variant already in the cart? Keep the card highlighted like a
    // normal selected row, and auto-open so the customer sees what's in it.
    final anyInCart =
        service.variants.any((v) => con.qtyOf(con.lineFor(service, v)) > 0);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: anyInCart ? _teal : const Color(0xFFEDEFF2),
          width: anyInCart ? 1.5 : 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _serviceThumb(service),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(service.displayName,
                        style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF7F8FA),
                border:
                    Border(top: BorderSide(color: Color(0xFFEDEFF2), width: 1)),
              ),
              child: Column(
                children: [
                  for (final v in service.variants)
                    _VariantRow(service: service, variant: v, con: con),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _VariantRow extends StatelessWidget {
  const _VariantRow(
      {required this.service, required this.variant, required this.con});
  final HsServiceItem service;
  final SubServiceVariant variant;
  final HomeServiceController con;

  @override
  Widget build(BuildContext context) {
    final line = con.lineFor(service, variant);
    final qty = con.qtyOf(line);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEDEFF2), width: 1)),
      ),
      child: Row(
        children: [
          _serviceThumb(service),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(variant.displayName,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('৳${variant.price}',
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _darkTeal)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          qty > 0
              ? _Stepper(
                  qty: qty,
                  onMinus: () => con.dec(line),
                  onPlus: () => con.add(service, variant: variant))
              : _AddButton(onTap: () => con.add(service, variant: variant)),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _teal, width: 1.4),
        ),
        child: Text('Add +'.tr,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800, color: _teal)),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper(
      {required this.qty, required this.onMinus, required this.onPlus});
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: _darkTeal, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          _btn(Icons.remove_rounded, onMinus),
          SizedBox(
            width: 30,
            child: Text('$qty',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
          ),
          _btn(Icons.add_rounded, onPlus),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );
}

class _ReviewBar extends StatelessWidget {
  const _ReviewBar({required this.con});
  final HomeServiceController con;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${con.totalItems} item${con.totalItems > 1 ? 's' : ''}',
                  style: const TextStyle(
                      fontSize: 11.5, color: Color(0xFF94A3B8))),
              Text('৳${con.totalPrice}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: con.reviewBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _darkTeal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Review booking →'.tr,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
