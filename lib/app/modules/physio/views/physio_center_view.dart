import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/physio_response.dart';
import '../../../global_widget/price_text.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/physio_controller.dart';
import '../physio_palette.dart';

class PhysioCenterView extends GetView<PhysioController> {
  const PhysioCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    final center = con.center;
    if (center == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<PhysioController>(
          builder: (con) {
            final center = con.center;
            if (center == null) return const SizedBox.shrink();
            // Same color this center shows on the picker — carried through
            // so the whole detail → catalog → cart journey reads as one
            // consistently-branded place, not a generic brown screen.
            final style = physioStyleFor(center.id);
            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 16, 4),
                  child: Row(
                    children: [
                      IconButton(
                        splashRadius: 22,
                        onPressed: () {
                          if (con.selectedKind != null) {
                            con.backToKindPicker();
                          } else {
                            Get.back();
                          }
                        },
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: Color(0xFF1A1A1A)),
                      ),
                      Container(
                        width: 34,
                        height: 34,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              style.accent,
                              style.accent.withValues(alpha: 0.75)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(style.icon, color: Colors.white, size: 18),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(center.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A))),
                            if (con.selectedKind != null)
                              Text(
                                  con.selectedKind == 'lab'
                                      ? 'Lab services'.tr
                                      : 'Patient care services'.tr,
                                  style: const TextStyle(
                                      fontSize: 12, color: Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: con.selectedKind == null
                      ? _KindPicker(center: center, style: style)
                      : RefreshIndicator(
                          color: style.accent,
                          onRefresh: con.refreshCenter,
                          child: _CatalogList(con: con, style: style),
                        ),
                ),
                if (con.totalItems > 0) _CartBar(con: con, style: style),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _KindPicker extends StatelessWidget {
  const _KindPicker({required this.center, required this.style});
  final PhysioCenter center;
  final PhysioCenterStyle style;

  @override
  Widget build(BuildContext context) {
    final con = Get.find<PhysioController>();
    // Patient care gets a gentle hue-shift off the center's own accent so
    // the two kind cards read as siblings, not identical twins.
    final hsl = HSLColor.fromColor(style.accent);
    final secondary = hsl
        .withHue((hsl.hue + 36) % 360)
        .withSaturation((hsl.saturation * 0.9).clamp(0.0, 1.0))
        .toColor();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (center.area.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 14, color: style.accent.withValues(alpha: 0.85)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(center.area,
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF94A3B8))),
              ),
            ],
          ),
          const SizedBox(height: 18),
        ],
        Text('What do you need?'.tr,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A))),
        const SizedBox(height: 14),
        FadeInUp(
          from: 18,
          duration: const Duration(milliseconds: 300),
          child: _KindCard(
            icon: Icons.biotech_rounded,
            accent: style.accent,
            title: 'Lab services'.tr,
            subtitle: 'Blood tests & diagnostics'.tr,
            onTap: () => con.selectKind('lab'),
          ),
        ),
        const SizedBox(height: 12),
        FadeInUp(
          from: 18,
          duration: const Duration(milliseconds: 350),
          child: _KindCard(
            icon: Icons.accessibility_new_rounded,
            accent: secondary,
            title: 'Patient care services'.tr,
            subtitle: 'Manual therapy, electrotherapy & more'.tr,
            onTap: () => con.selectKind('patient_care'),
          ),
        ),
      ],
    );
  }
}

class _KindCard extends StatelessWidget {
  const _KindCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                  color: accent.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 6)),
            ]),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12.5, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: accent.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}

class _CatalogList extends StatelessWidget {
  const _CatalogList({required this.con, required this.style});
  final PhysioController con;
  final PhysioCenterStyle style;

  @override
  Widget build(BuildContext context) {
    if (con.loadingCatalog && con.catalog.isEmpty) {
      return const SnListSkeleton(count: 4);
    }
    if (con.catalog.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Text('No services available at this center yet.'.tr,
                style: const TextStyle(color: Color(0xFF94A3B8))),
          ),
        ],
      );
    }
    final filtered = con.filteredCatalog;
    final categories = con.catalogCategories;
    return FadeInUp(
      from: 18,
      duration: const Duration(milliseconds: 300),
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, con.totalItems > 0 ? 100 : 24),
        children: [
          _SearchBox(con: con, style: style),
          if (categories.length > 1) ...[
            const SizedBox(height: 10),
            _CategoryChips(con: con, style: style, categories: categories),
          ],
          const SizedBox(height: 14),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text('No services match your search.'.tr,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF94A3B8))),
              ),
            )
          else
            ...filtered.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CatalogRow(item: item, con: con, style: style),
                )),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.con, required this.style});
  final PhysioController con;
  final PhysioCenterStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.accent.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded,
              size: 20, color: style.accent.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: con.catalogSearchCtrl,
              onChanged: con.setCatalogSearch,
              decoration: InputDecoration(
                hintText: 'Search services…'.tr,
                hintStyle:
                    const TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
              style: const TextStyle(fontSize: 13.5),
            ),
          ),
          if (con.catalogSearch.isNotEmpty)
            GestureDetector(
              onTap: () {
                con.catalogSearchCtrl.clear();
                con.setCatalogSearch('');
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                margin: const EdgeInsets.only(left: 4),
                child: const Icon(Icons.close_rounded,
                    size: 17, color: Color(0xFF94A3B8)),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips(
      {required this.con, required this.style, required this.categories});
  final PhysioController con;
  final PhysioCenterStyle style;
  final List<MapEntry<String, String>> categories;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _CategoryChip(
            label: 'All'.tr,
            selected: con.selectedCategoryId == null,
            style: style,
            onTap: () => con.selectCategory(null),
          ),
          ...categories.map((e) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _CategoryChip(
                  label: e.value,
                  selected: con.selectedCategoryId == e.key,
                  style: style,
                  onTap: () => con.selectCategory(e.key),
                ),
              )),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.style,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final PhysioCenterStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? style.accent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected
                  ? style.accent
                  : style.accent.withValues(alpha: 0.25)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : const Color(0xFF475569))),
      ),
    );
  }
}

class _CatalogRow extends StatelessWidget {
  const _CatalogRow(
      {required this.item, required this.con, required this.style});
  final PhysioCatalogItem item;
  final PhysioController con;
  final PhysioCenterStyle style;

  @override
  Widget build(BuildContext context) {
    final qty = con.qtyOf(item.id);
    // Catalog browse happens before a visit type is chosen, so the
    // center-visit price is shown here — checkout re-resolves per item
    // against whichever visit type is actually picked.
    final price = item.priceFor('center');
    final original = item.originalPriceFor('center');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color:
                  qty > 0 ? style.accent : style.accent.withValues(alpha: 0.14),
              width: qty > 0 ? 1.4 : 1)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF94A3B8))),
                ],
                const SizedBox(height: 6),
                PriceText(
                    price: price,
                    originalPrice: original,
                    baseColor: style.accent),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Patient-care is a single pick, not a quantity — how many
          // sessions that becomes is set up on the backend afterwards, so
          // there's no +/- here, just selected/not-selected.
          con.selectedKind == 'patient_care'
              ? (qty > 0
                  ? _SelectedButton(
                      accent: style.accent,
                      tile: style.tile,
                      onTap: () => con.removeFromCart(item))
                  : _AddButton(
                      accent: style.accent, onTap: () => con.addToCart(item)))
              : (qty > 0
                  ? _Stepper(
                      qty: qty,
                      accent: style.accent,
                      tile: style.tile,
                      onMinus: () => con.removeFromCart(item),
                      onPlus: () => con.addToCart(item),
                    )
                  : _AddButton(
                      accent: style.accent, onTap: () => con.addToCart(item))),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.accent, required this.onTap});
  final Color accent;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        side: BorderSide(color: accent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text('Add'.tr,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
    );
  }
}

class _SelectedButton extends StatelessWidget {
  const _SelectedButton(
      {required this.accent, required this.tile, required this.onTap});
  final Color accent;
  final Color tile;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        backgroundColor: tile,
        side: BorderSide(color: accent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 15, color: accent),
          const SizedBox(width: 4),
          Text('Added'.tr,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.qty,
    required this.accent,
    required this.tile,
    required this.onMinus,
    required this.onPlus,
  });
  final int qty;
  final Color accent;
  final Color tile;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: tile, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onMinus,
            icon: Icon(Icons.remove, size: 16, color: accent),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          Text('$qty',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: accent)),
          IconButton(
            onPressed: onPlus,
            icon: Icon(Icons.add, size: 16, color: accent),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar({required this.con, required this.style});
  final PhysioController con;
  final PhysioCenterStyle style;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: GestureDetector(
        onTap: con.proceedToCheckout,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [style.accent, style.accent.withValues(alpha: 0.82)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: style.accent.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8)),
                child: Text('${con.totalItems}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                    '${con.totalItems} ${con.totalItems == 1 ? 'item'.tr : 'items'.tr} · ৳${con.cartTotal}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800)),
              ),
              Text('View cart'.tr,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
