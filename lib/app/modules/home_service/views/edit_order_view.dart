import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/service_response.dart';
import '../controllers/home_service_controller.dart';

const _teal = Color(0xFF0E9F8E);
const _darkTeal = Color(0xFF0E7C6B);

/// Lets the customer revise a placed order: change quantities, drop a job,
/// add another service, or add parts.
///
/// Each change is sent immediately rather than batched behind a "save"
/// button. The server owns pricing and recomputes the whole invoice on
/// every mutation, so applying changes one at a time keeps the total on
/// screen truthful at all times — and avoids a batch that half-succeeds.
class EditOrderView extends GetView<HomeServiceController> {
  const EditOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeServiceController>(builder: (con) {
      final booking = con.orderBooking;
      if (booking == null) {
        return const Scaffold(body: Center(child: Text('No order open')));
      }
      // The booking can lock while this screen is open — the provider may
      // complete the job from their app. Drop back rather than letting
      // the user compose changes that will be rejected.
      if (booking.locked) {
        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: _bar(context, booking),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline_rounded,
                      size: 40, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 12),
                  Text(booking.lockReason.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: _bar(context, booking),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  children: [
                    _label('SERVICES'.tr),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          for (int i = 0; i < booking.items.length; i++) ...[
                            if (i > 0)
                              const Divider(
                                  height: 1, color: Color(0xFFF1F5F9)),
                            _EditableJobRow(
                              item: booking.items[i],
                              // The last job can't be removed — an order
                              // with nothing on it is a cancellation, which
                              // is a different action entirely.
                              canRemove: booking.items.length > 1,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AddButton(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'Add another service'.tr,
                      onTap: con.orderBusy
                          ? null
                          : () => _openAddJobSheet(context, con, booking),
                    ),
                    if (booking.extraItems.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      _label('PARTS & MATERIALS'.tr),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            for (int i = 0;
                                i < booking.extraItems.length;
                                i++) ...[
                              if (i > 0)
                                const Divider(
                                    height: 1, color: Color(0xFFF1F5F9)),
                              _EditablePartRow(part: booking.extraItems[i]),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _AddButton(
                      icon: Icons.handyman_outlined,
                      label: 'Add parts or materials'.tr,
                      onTap: con.orderBusy
                          ? null
                          : () => _openAddPartSheet(context, con),
                    ),
                    const SizedBox(height: 22),
                    _TotalCard(booking: booking),
                  ],
                ),
              ),
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: con.orderBusy ? null : () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Done'.tr,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  PreferredSizeWidget _bar(BuildContext context, ServiceBooking b) => AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit order'.tr,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
            Text(b.invoiceNo,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF94A3B8))),
          ],
        ),
      );

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: .8,
          color: Color(0xFF94A3B8)));

  /// Sheet for adding more sub-services from the booking's category.
  /// Selection is local until "Add", then sent as one request.
  void _openAddJobSheet(
      BuildContext context, HomeServiceController con, ServiceBooking b) {
    final selection = <String, int>{};
    con.loadAddableServices();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => GetBuilder<HomeServiceController>(
          builder: (c) {
            final subs = c.addableServices;
            return _Sheet(
              title: 'Add a service'.tr,
              child: c.loadingAddableServices
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()))
                  : subs.isEmpty
                      ? _empty('No other services in this category'.tr)
                      : Column(
                          children: [
                            Flexible(
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: subs.length,
                                separatorBuilder: (_, __) => const Divider(
                                    height: 1, color: Color(0xFFF1F5F9)),
                                itemBuilder: (_, i) {
                                  final s = subs[i];
                                  final qty = selection[s.id] ?? 0;
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(s.displayName,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700)),
                                    subtitle: Text('৳${s.price}',
                                        style: const TextStyle(
                                            fontSize: 12.5,
                                            color: Color(0xFF94A3B8))),
                                    trailing: _Stepper(
                                      qty: qty,
                                      onMinus: qty == 0
                                          ? null
                                          : () => setSheet(() {
                                                if (qty <= 1) {
                                                  selection.remove(s.id);
                                                } else {
                                                  selection[s.id] = qty - 1;
                                                }
                                              }),
                                      onPlus: () => setSheet(
                                          () => selection[s.id] = qty + 1),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: selection.isEmpty
                                    ? null
                                    : () async {
                                        Navigator.of(ctx).pop();
                                        await con.addTasks(selection);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _darkTeal,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                ),
                                child: Text('Add to order'.tr,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800)),
                              ),
                            ),
                          ],
                        ),
            );
          },
        ),
      ),
    );
  }

  /// Sheet for adding stock-tracked parts. Out-of-stock rows are shown but
  /// disabled — hiding them would leave the customer wondering why a part
  /// they expected is missing.
  void _openAddPartSheet(BuildContext context, HomeServiceController con) {
    con.loadCategoryItems();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GetBuilder<HomeServiceController>(
        builder: (c) => _Sheet(
          title: 'Add parts or materials'.tr,
          child: c.loadingCategoryItems
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()))
              : c.categoryItems.isEmpty
                  ? _empty('No parts available for this service'.tr)
                  : Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: c.categoryItems.length,
                        separatorBuilder: (_, __) => const Divider(
                            height: 1, color: Color(0xFFF1F5F9)),
                        itemBuilder: (_, i) {
                          final it = c.categoryItems[i];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            enabled: it.inStock,
                            title: Text(it.name,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: it.inStock
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFFCBD5E1))),
                            subtitle: Text(
                                it.inStock
                                    ? '৳${it.unitPrice} / ${it.unit}'
                                    : 'Out of stock'.tr,
                                style: TextStyle(
                                    fontSize: 12.5,
                                    color: it.inStock
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFFEF4444))),
                            trailing: it.inStock
                                ? const Icon(Icons.add_circle_outline_rounded,
                                    color: _teal)
                                : null,
                            onTap: it.inStock
                                ? () async {
                                    Navigator.of(context).pop();
                                    await con.addPart(it, 1);
                                  }
                                : null,
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _empty(String msg) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: Text(msg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13.5, color: Color(0xFF94A3B8))),
        ),
      );
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * .75),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 14),
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 6),
            child,
          ],
        ),
      );
}

/// A job row with quantity controls. Rows the provider has already started
/// are shown read-only with an explanation — the server refuses to change
/// them, and silently hiding the controls would look like a bug.
class _EditableJobRow extends GetView<HomeServiceController> {
  const _EditableJobRow({required this.item, required this.canRemove});
  final ServiceBookingItem item;
  final bool canRemove;

  @override
  Widget build(BuildContext context) {
    final con = controller;
    final busy = con.isMutating(item.id);
    final locked = !item.editable;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name.isEmpty ? 'Service'.tr : item.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 3),
                Text('৳${item.unitPrice} · ৳${item.lineTotal} total',
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF94A3B8))),
                if (locked) ...[
                  const SizedBox(height: 4),
                  Text('Provider has started this job'.tr,
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB45309))),
                ],
              ],
            ),
          ),
          if (busy)
            const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2))
          else if (locked)
            Text('×${item.quantity}',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF94A3B8)))
          else
            _Stepper(
              qty: item.quantity,
              // At quantity 1 the minus button removes the line, unless
              // it's the only job left.
              onMinus: (item.quantity == 1 && !canRemove) || con.orderBusy
                  ? null
                  : () => con.changeTaskQuantity(item, -1),
              onPlus: con.orderBusy
                  ? null
                  : () => con.changeTaskQuantity(item, 1),
              minusIcon: item.quantity == 1
                  ? Icons.delete_outline_rounded
                  : Icons.remove_rounded,
            ),
        ],
      ),
    );
  }
}

class _EditablePartRow extends GetView<HomeServiceController> {
  const _EditablePartRow({required this.part});
  final ServiceBookingExtraItem part;

  @override
  Widget build(BuildContext context) {
    final con = controller;
    final busy = con.isMutating(part.id);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(part.name.isEmpty ? 'Part'.tr : part.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 3),
                Text('${part.quantityWithUnit} · ৳${part.lineTotal}',
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          if (busy)
            const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2))
          else
            IconButton(
              splashRadius: 20,
              onPressed:
                  con.orderBusy ? null : () => con.removePart(part),
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 20, color: Color(0xFFDC2626)),
            ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
    this.minusIcon = Icons.remove_rounded,
  });
  final int qty;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;
  final IconData minusIcon;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(minusIcon, onMinus),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('$qty',
                style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
          ),
          _btn(Icons.add_rounded, onPlus),
        ],
      );

  Widget _btn(IconData icon, VoidCallback? onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: onTap == null ? const Color(0xFFF1F5F9) : const Color(0xFFE0F2EF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              size: 17,
              color: onTap == null ? const Color(0xFFCBD5E1) : _darkTeal),
        ),
      );
}

class _AddButton extends StatelessWidget {
  const _AddButton(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 19, color: _darkTeal),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFB6E0D7)),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          label: Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _darkTeal)),
        ),
      );
}

/// Live total. Repeated here so the customer sees the price move as they
/// edit, without going back to the details screen.
class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.booking});
  final ServiceBooking booking;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            _row('Subtotal'.tr, '৳${booking.subtotal}'),
            const SizedBox(height: 8),
            _row(
                booking.vatRate > 0
                    ? 'VAT (${booking.vatRate}%)'.tr
                    : 'VAT'.tr,
                '৳${booking.vatAmount}'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            _row('New total'.tr, '৳${booking.amount}', bold: true),
          ],
        ),
      );

  Widget _row(String l, String v, {bool bold = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l,
              style: TextStyle(
                  fontSize: bold ? 15 : 13.5,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                  color: bold
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF475569))),
          Text(v,
              style: TextStyle(
                  fontSize: bold ? 16 : 14,
                  fontWeight: FontWeight.w800,
                  color: bold ? _darkTeal : const Color(0xFF0F172A))),
        ],
      );
}
