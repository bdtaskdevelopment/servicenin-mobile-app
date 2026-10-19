import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_config.dart';
import '../../../data/models/response/service_response.dart';
import '../../../global_widget/price_text.dart';
import '../../../global_widget/rich_html_text.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_service_controller.dart';

const hsTeal = Color(0xFF0E9F8E);
const hsDarkTeal = Color(0xFF0E7C6B);
// Kept as aliases so the rest of this file doesn't need touching.
const _teal = hsTeal;
const _darkTeal = hsDarkTeal;

/// Resolves an admin-uploaded icon URL, which may already be absolute (S3)
/// or a server-relative path (`/static/...`, local dev storage) — same
/// convention as `_providerPhotoUrl` in hs_my_bookings_view.dart.
String hsIconUrl(String path) => _iconUrl(path);

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
Widget hsServiceThumb(HsServiceItem service, {double size = 36}) =>
    _serviceThumb(service, size: size);

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
                // Hero header (gradient, rounded bottom) with a floating
                // search/filter card peeking out of its lower edge.
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _CategoryHeader(con: con, isSearch: isSearch),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: -24,
                      child: _FloatingSearchField(con: con, isSearch: isSearch),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
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
                                children: [
                                  ...services.map((s) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child:
                                            _ServiceRow(service: s, con: con),
                                      )),
                                  // Category's own Description → Terms &
                                  // Conditions → FAQs, in that order, below
                                  // the sub-service list. Only meaningful in
                                  // category mode (search/all list results
                                  // from many categories at once).
                                  if (con.mode == HsListMode.category)
                                    ..._categoryInfoSections(con),
                                ],
                              ),
                            ),
                ),
                // Review booking bar
                if (con.totalItems > 0) HsReviewBar(con: con),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Gradient hero header: back/search/cart row, then the category's own
/// avatar (uploaded image, else a generic icon) beside its title — replaces
/// the old plain white app-bar row with something that actually reads as
/// "this category's own page" rather than a generic list screen. Extra
/// bottom padding leaves room for [_FloatingSearchField] to overlap its
/// rounded lower edge.
class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.con, required this.isSearch});
  final HomeServiceController con;
  final bool isSearch;

  @override
  Widget build(BuildContext context) {
    final services = con.visibleServices;
    final cat = con.selectedCat;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 6, 16, 44),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [hsTeal, hsDarkTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
              color: Color(0x330E7C6B), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HeaderIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Get.back()),
              const Spacer(),
              if (!isSearch) ...[
                _HeaderIconButton(
                    icon: Icons.search_rounded, onTap: con.openSearch),
                const SizedBox(width: 10),
              ],
              _HeaderCartButton(con: con),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Row(
              children: [
                _CategoryAvatar(cat: cat, isSearch: isSearch),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(con.listTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.1)),
                      const SizedBox(height: 3),
                      Text('${services.length} ${'services available'.tr}',
                          style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xCCFFFFFF))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The category's own uploaded image on a soft white disc, falling back to
/// its generic icon — or a plain search glyph while in search mode, where
/// there's no single category to represent.
class _CategoryAvatar extends StatelessWidget {
  const _CategoryAvatar({required this.cat, required this.isSearch});
  final HsCategory? cat;
  final bool isSearch;

  @override
  Widget build(BuildContext context) {
    const size = 50.0;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration:
          const BoxDecoration(color: Color(0x33FFFFFF), shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: isSearch
          ? const Icon(Icons.search_rounded, color: Colors.white, size: 24)
          : (cat?.imageUrl.isEmpty ?? true)
              ? Icon(cat?.icon ?? Icons.home_repair_service_outlined,
                  color: Colors.white, size: 24)
              : CachedNetworkImage(
                  imageUrl: _iconUrl(cat!.imageUrl),
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                  placeholder: (_, __) =>
                      Icon(cat!.icon, color: Colors.white, size: 24),
                  errorWidget: (_, __, ___) =>
                      Icon(cat!.icon, color: Colors.white, size: 24),
                ),
    );
  }
}

/// Small translucent circular button used for back/search in the header —
/// a consistent "glass" look instead of bare icons on the gradient.
class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0x26FFFFFF),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, color: Colors.white, size: 19),
          ),
        ),
      );
}

/// Cart button, same "glass" circle as the other header icons, with the
/// live item-count badge kept from the old header.
class _HeaderCartButton extends StatelessWidget {
  const _HeaderCartButton({required this.con});
  final HomeServiceController con;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: con.openCart,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: const Color(0x26FFFFFF),
              shape: const CircleBorder(),
              child: const SizedBox(
                width: 38,
                height: 38,
                child: Icon(Icons.shopping_cart_outlined,
                    color: Colors.white, size: 19),
              ),
            ),
            if (con.totalItems > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  constraints:
                      const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: const BoxDecoration(
                      color: AppColors.brandOrange, shape: BoxShape.circle),
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
      );
}

/// The always-visible filter/search field, now a floating white card that
/// overlaps the header's rounded lower edge instead of sitting flush below
/// it. In category mode it instantly filters the currently loaded
/// sub-services by name (no network call); in search mode (reached via the
/// header's search icon, or Home's "Search…"/"All →") it runs the
/// cross-category search as before.
class _FloatingSearchField extends StatelessWidget {
  const _FloatingSearchField({required this.con, required this.isSearch});
  final HomeServiceController con;
  final bool isSearch;

  @override
  Widget build(BuildContext context) => Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x1A0F172A), blurRadius: 16, offset: Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: _teal),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                autofocus: isSearch,
                onChanged:
                    isSearch ? con.onQueryChanged : con.onSubFilterChanged,
                decoration: InputDecoration(
                  hintText: (isSearch
                          ? 'Search services…'
                          : 'Filter services in this category…')
                      .tr,
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
                style:
                    const TextStyle(fontSize: 14.5, color: Color(0xFF0F172A)),
              ),
            ),
          ],
        ),
      );
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.service, required this.con});
  final HsServiceItem service;
  final HomeServiceController con;

  @override
  Widget build(BuildContext context) {
    // A sub-service with variants (e.g. AC capacity) opens its own page to
    // pick one — cleaner than expanding every option inline on this list.
    if (service.hasVariants) {
      return _VariantServiceRow(service: service, con: con);
    }
    final qty = con.qtyOf(service);
    final selected = qty > 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: selected ? _teal : const Color(0xFFEEF1F4),
            width: selected ? 1.5 : 1),
        boxShadow: [
          BoxShadow(
              color: selected
                  ? _teal.withValues(alpha: 0.14)
                  : const Color(0x0A0F172A),
              blurRadius: selected ? 14 : 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _serviceThumb(service, size: 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(service.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                _DurationPriceRow(
                    duration: service.duration,
                    price: service.price,
                    originalPrice: service.originalPrice),
              ],
            ),
          ),
          const SizedBox(width: 10),
          selected
              ? HsQtyStepper(
                  qty: qty,
                  onMinus: () => con.dec(service),
                  onPlus: () => con.add(service))
              : HsAddButton(onTap: () => con.add(service)),
        ],
      ),
    );
  }
}

/// "⏱ 60 min · ৳800" row shared by the plain and variant-summary cards —
/// keeps duration + price on one line instead of two, so the card doesn't
/// grow taller than its thumbnail and leave blank space beside it.
class _DurationPriceRow extends StatelessWidget {
  const _DurationPriceRow({
    required this.duration,
    required this.price,
    this.originalPrice,
    this.prefix,
  });
  final String duration;

  /// What the customer pays.
  final int price;

  /// The list price, shown struck through beside [price] when discounted.
  final int? originalPrice;

  /// Optional lead-in word, e.g. "From" on a variant summary.
  final String? prefix;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (duration.isNotEmpty) ...[
          const Icon(Icons.access_time_rounded,
              size: 13, color: Color(0xFF94A3B8)),
          const SizedBox(width: 3),
          Text(duration,
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          const SizedBox(width: 8),
          const Text('·', style: TextStyle(color: Color(0xFFCBD5E1))),
          const SizedBox(width: 8),
        ],
        Flexible(
            child: PriceText(
                price: price, originalPrice: originalPrice, prefix: prefix)),
      ],
    );
  }
}

/// A sub-service that has variants (e.g. AC capacity) — summarised here with
/// its cheapest price ("From ৳X") and an in-cart count; tapping opens
/// [HsVariantPickerView] to actually choose one and add it.
class _VariantServiceRow extends StatelessWidget {
  const _VariantServiceRow({required this.service, required this.con});
  final HsServiceItem service;
  final HomeServiceController con;

  @override
  Widget build(BuildContext context) {
    final totalQty = service.variants
        .map((v) => con.qtyOf(con.lineFor(service, v)))
        .fold<int>(0, (a, b) => a + b);
    final selected = totalQty > 0;
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.HS_VARIANTS, arguments: service),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: selected ? _teal : const Color(0xFFEEF1F4),
              width: selected ? 1.5 : 1),
          boxShadow: [
            BoxShadow(
                color: selected
                    ? _teal.withValues(alpha: 0.14)
                    : const Color(0x0A0F172A),
                blurRadius: selected ? 14 : 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _serviceThumb(service, size: 52),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(service.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  _DurationPriceRow(
                      duration: service.duration,
                      price: service.fromPrice,
                      originalPrice: service.fromOriginalPrice,
                      prefix: 'From'.tr),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (selected) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                    color: _darkTeal, borderRadius: BorderRadius.circular(8)),
                child: Text('$totalQty',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              const SizedBox(width: 4),
            ],
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

/// One variant's price row with its own Add/stepper — shared by
/// [HsVariantPickerView].
class HsVariantRow extends StatelessWidget {
  const HsVariantRow(
      {super.key,
      required this.service,
      required this.variant,
      required this.con});
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
                PriceText(
                    price: variant.effective,
                    originalPrice:
                        variant.discountPrice != null ? variant.price : null),
              ],
            ),
          ),
          const SizedBox(width: 8),
          qty > 0
              ? HsQtyStepper(
                  qty: qty,
                  onMinus: () => con.dec(line),
                  onPlus: () => con.add(service, variant: variant))
              : HsAddButton(onTap: () => con.add(service, variant: variant)),
        ],
      ),
    );
  }
}

class HsAddButton extends StatelessWidget {
  const HsAddButton({super.key, required this.onTap});
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

class HsQtyStepper extends StatelessWidget {
  const HsQtyStepper(
      {super.key,
      required this.qty,
      required this.onMinus,
      required this.onPlus});
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

class HsReviewBar extends StatelessWidget {
  const HsReviewBar({super.key, required this.con});
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

/// Category's own Description → Terms & Conditions → FAQs, in that exact
/// order, each only shown when the category actually has content for it
/// (an admin may set none, some, or all three).
List<Widget> _categoryInfoSections(HomeServiceController con) {
  final sections = <Widget>[];
  if (con.categoryDescription.isNotEmpty) {
    sections.addAll([
      const SizedBox(height: 8),
      _InfoSectionLabel(Icons.info_outline_rounded, 'Description'.tr),
      const SizedBox(height: 10),
      _InfoTextCard(con.categoryDescription),
    ]);
  }
  if (con.categoryTerms.isNotEmpty) {
    sections.addAll([
      const SizedBox(height: 20),
      _InfoSectionLabel(Icons.description_outlined, 'Terms & Conditions'.tr),
      const SizedBox(height: 10),
      _InfoTextCard(con.categoryTerms),
    ]);
  }
  if (con.categoryFaqs.isNotEmpty) {
    sections.addAll([
      const SizedBox(height: 20),
      _InfoSectionLabel(Icons.help_outline_rounded, 'FAQ'.tr),
      const SizedBox(height: 10),
      _FaqCard(faqs: con.categoryFaqs),
    ]);
  }
  return sections;
}

/// A small teal icon chip beside an uppercase label — gives the
/// Description/Terms/FAQ sections a bit more presence than a bare grey
/// caption, while staying quiet next to the service cards above them.
class _InfoSectionLabel extends StatelessWidget {
  const _InfoSectionLabel(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: _teal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 14, color: _darkTeal),
          ),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF475569),
                  letterSpacing: 0.5)),
        ],
      );
}

class _InfoTextCard extends StatelessWidget {
  const _InfoTextCard(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A0F172A), blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: RichHtmlText(text),
      );
}

/// Expandable Q&A list — collapsed by default so a category with many FAQs
/// doesn't push the page into a wall of text.
class _FaqCard extends StatelessWidget {
  const _FaqCard({required this.faqs});
  final List<ServiceCategoryFaq> faqs;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A0F172A), blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: Column(
            children: [
              for (int i = 0; i < faqs.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ExpansionTile(
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  iconColor: _teal,
                  collapsedIconColor: const Color(0xFF94A3B8),
                  title: Text(faqs[i].question,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A))),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: RichHtmlText(faqs[i].answer),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
}
