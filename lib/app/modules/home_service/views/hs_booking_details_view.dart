import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_url.dart';
import '../../../data/models/response/service_response.dart';
import '../../../global_widget/invoice_actions.dart';
import '../controllers/home_service_controller.dart';

const _teal = Color(0xFF0E9F8E);
const _darkTeal = Color(0xFF0E7C6B);
const _tile = Color(0xFFE0F2EF);

class HsBookingDetailsView extends GetView<HomeServiceController> {
  const HsBookingDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    // GetBuilder so the invoice and line items rebuild as edits land —
    // every mutation replaces the booking and calls update().
    return GetBuilder<HomeServiceController>(builder: (con) {
      final booking = con.orderBooking;
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Booking details'.tr,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      Text(con.bookingId,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const Spacer(),
                  // Manual refresh — the provider can add parts, move the
                  // status on, or collect cash while this screen is open,
                  // none of which push to the app.
                  con.refreshingOrder
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.2, color: _darkTeal),
                          ),
                        )
                      : IconButton(
                          splashRadius: 22,
                          tooltip: 'Refresh'.tr,
                          onPressed: () =>
                              con.refreshOrder(showSpinner: true),
                          icon: const Icon(Icons.refresh_rounded,
                              size: 22, color: Color(0xFF1A1A1A)),
                        ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                children: [
                  // Service card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: _tile,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.ac_unit_rounded,
                              color: _teal, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(con.bookingSummary,
                                  style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A))),
                              const SizedBox(height: 2),
                              Text(
                                  '${con.techName} · ${con.whenSummary}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ),
                        _StatusChip(status: con.trackedBooking?.status ?? ''),
                      ],
                    ),
                  ),
                  // Status timeline & work proof hidden for now.
                  /*
                  const SizedBox(height: 18),
                  const _Label('STATUS TIMELINE'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: List.generate(con.timeline.length, (i) {
                        final t = con.timeline[i];
                        final last = i == con.timeline.length - 1;
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  const Icon(Icons.check_circle,
                                      size: 20, color: _darkTeal),
                                  if (!last)
                                    Expanded(
                                      child: Container(
                                          width: 2,
                                          color: const Color(0xFFB6E0D7)),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(bottom: last ? 8 : 18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(t.statusLabel,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0F172A))),
                                      const SizedBox(height: 1),
                                      if (t.note.isNotEmpty)
                                        Text(t.note,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF64748B))),
                                      Text(t.timeLabel,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFE07A1F))),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: const [
                      _Label('WORK PROOF'),
                      SizedBox(width: 8),
                      Text('before · after',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Expanded(child: _ProofBox(label: 'Before', tinted: false)),
                      SizedBox(width: 12),
                      Expanded(child: _ProofBox(label: 'After', tinted: true)),
                    ],
                  ),
                  */
                  // ── Every job on this order ──────────────────────────
                  if (booking != null && booking.items.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _Label('SERVICES'.tr),
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
                            _JobRow(item: booking.items[i]),
                          ],
                        ],
                      ),
                    ),
                  ],
                  // ── Parts and materials ──────────────────────────────
                  if (booking != null && booking.extraItems.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _Label('PARTS & MATERIALS'.tr),
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
                            _PartRow(part: booking.extraItems[i]),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  _Label('INVOICE'.tr),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        if (booking != null && booking.baseAmount > 0) ...[
                          _fee('Call-out charge'.tr, '৳${booking.baseAmount}'),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        ],
                        _fee('Service charge'.tr,
                            '৳${booking?.subtotal ?? con.subtotalAmount}'),
                        if (booking != null && booking.promoDiscount > 0) ...[
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _fee('Discount'.tr, '−৳${booking.promoDiscount}'),
                        ],
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        // Rate comes from the booking — it is frozen at
                        // booking time, so a later settings change must not
                        // relabel an old invoice.
                        _fee(
                            booking != null && booking.vatRate > 0
                                ? 'VAT (${booking.vatRate}%)'.tr
                                : 'VAT'.tr,
                            '৳${booking?.vatAmount ?? con.vat}'),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _fee('Total'.tr, '৳${booking?.amount ?? con.totalPaid}',
                            bold: true),
                        // Discount the provider (or an admin) granted when
                        // collecting payment. It doesn't change the Total —
                        // it reduces what the customer hands over — so it
                        // sits below Total next to what was actually paid.
                        if (con.paymentSummary?.hasDiscount == true) ...[
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _fee(
                              'Discount given'.tr,
                              '−৳${con.paymentSummary!.discountTotal.toStringAsFixed(0)}',
                              valueColor: const Color(0xFFB45309)),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _fee(
                              'Amount paid'.tr,
                              '৳${con.paymentSummary!.cashReceived.toStringAsFixed(0)}'),
                        ],
                        // Promo code — offered only while there's still a
                        // balance owed and none has been redeemed on this
                        // booking yet. Placed BEFORE the outstanding-balance
                        // row so the balance the customer is about to pay
                        // already reflects the discount, not after.
                        if (booking != null &&
                            !booking.locked &&
                            booking.promoDiscount == 0 &&
                            con.paymentSummary?.hasOutstanding == true) ...[
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          const _PromoCodeRow(),
                        ],
                        if (con.paymentSummary?.hasOutstanding == true) ...[
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          _fee(
                              'Outstanding balance'.tr,
                              '৳${con.paymentSummary!.outstanding.toStringAsFixed(0)}',
                              bold: true,
                              valueColor: const Color(0xFFDC2626)),
                        ],
                      ],
                    ),
                  ),
                  // Available whenever a balance is owed, regardless of how
                  // the booking was originally paid — the customer can
                  // always choose to settle it online instead of waiting
                  // for cash collection on-site.
                  if (con.paymentSummary?.hasOutstanding == true) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed:
                            con.isPayingOnline ? null : con.payOutstandingOnline,
                        icon: con.isPayingOnline
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.credit_card_rounded, size: 20),
                        label: Text(
                            con.isPayingOnline
                                ? 'প্রসেসিং...'
                                : 'Pay ৳${con.paymentSummary!.outstanding.toStringAsFixed(0)} online'
                                    .tr,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _darkTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                  if (booking != null) ...[
                    const SizedBox(height: 8),
                    _PaymentNote(booking: booking),
                  ],
                  if ((con.trackedBooking?.id ?? '').isNotEmpty) ...[
                    const SizedBox(height: 14),
                    InvoiceActions(
                      viewPath: ApiURL.hsInvoicePdf(con.trackedBooking!.id),
                      downloadPath:
                          ApiURL.hsInvoicePdfDownload(con.trackedBooking!.id),
                      fileName: 'invoice-${con.trackedBooking!.id}',
                      accent: _darkTeal,
                    ),
                  ],
                ],
              ),
            ),
            // Bottom actions
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  // Editing is offered only while the server would accept
                  // it; once locked we say why rather than showing a
                  // button that is guaranteed to fail.
                  if (booking != null) ...[
                    if (con.canEditOrder)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: con.openEditOrder,
                          icon: const Icon(Icons.edit_note_rounded,
                              size: 20, color: _darkTeal),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _teal),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          label: Text('Edit order'.tr,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _darkTeal)),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_outline_rounded,
                                size: 16, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(booking.lockReason.tr,
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF64748B))),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                  // Review is the only action here now — the "Report
                  // issue" button was removed from this screen, so the
                  // review button takes the full width.
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    // Once reviewed the button still opens the page (so the
                    // customer can read back what they wrote) but reads
                    // "View your review" and drops the primary styling.
                    child: con.hasReviewed
                        ? OutlinedButton(
                            onPressed: con.rateService,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFCDEBE4)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text('View your review'.tr,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _darkTeal)),
                          )
                        : ElevatedButton(
                            onPressed: con.rateService,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _darkTeal,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text('Rate service'.tr,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w800)),
                          ),
                  ),
                  // Duplicate dispute link hidden — dispute now in the row above.
                  // const SizedBox(height: 8),
                  // TextButton(
                  //   onPressed: () => _showDisputeDialog(context, con),
                  //   child: const Text('Report an issue (dispute)',
                  //       style: TextStyle(
                  //           fontSize: 13.5,
                  //           fontWeight: FontWeight.w700,
                  //           color: Color(0xFFDC2626))),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
      );
    });
  }

  Widget _fee(String label, String amount,
          {bool bold = false, Color? valueColor}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: bold ? 15 : 13.5,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                    color: bold
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF475569))),
            Text(amount,
                style: TextStyle(
                    fontSize: bold ? 16 : 14,
                    fontWeight: FontWeight.w800,
                    color: valueColor ??
                        (bold ? _darkTeal : const Color(0xFF0F172A)))),
          ],
        ),
      );
}

/// Inline promo-code entry shown before the outstanding-balance row (see
/// HsBookingDetailsView above). A StatefulWidget purely so the TextField's
/// controller survives the GetBuilder rebuilds every mutation triggers —
/// the applied/loading state itself still comes straight from the
/// controller, read fresh on every rebuild.
class _PromoCodeRow extends StatefulWidget {
  const _PromoCodeRow();

  @override
  State<_PromoCodeRow> createState() => _PromoCodeRowState();
}

class _PromoCodeRowState extends State<_PromoCodeRow> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final con = Get.find<HomeServiceController>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              enabled: !con.isApplyingPromo,
              decoration: InputDecoration(
                hintText: 'Promo code'.tr,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _darkTeal),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: con.isApplyingPromo
                  ? null
                  : () => con.applyPromoCode(_codeController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: _darkTeal,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: con.isApplyingPromo
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text('Apply'.tr,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Status chip — same mapping as the bookings list and tracking sheet so the
/// status shown here always matches.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    final done = s == 'completed';
    final bad = s == 'cancelled' || s == 'canceled';
    final bg = bad
        ? const Color(0xFFFEE2E2)
        : done
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEF3C7);
    final fg = bad
        ? const Color(0xFFDC2626)
        : done
            ? const Color(0xFF15803D)
            : const Color(0xFFB45309);
    final label = status.isEmpty
        ? 'Pending'
        : status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.6));
}

// ignore: unused_element
class _ProofBox extends StatelessWidget {
  const _ProofBox({required this.label, required this.tinted});
  final String label;
  final bool tinted;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 110,
          decoration: BoxDecoration(
              color: tinted ? _tile : const Color(0xFFE9EDF1),
              borderRadius: BorderRadius.circular(14)),
          child: Icon(Icons.photo_camera_outlined,
              color: tinted ? _teal : const Color(0xFF94A3B8), size: 30),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155))),
      ],
    );
  }
}

/// One service job line. Shows what the provider is doing, at what unit
/// price, and — when it was added after the order was placed — who added
/// it, so a customer isn't surprised by a charge they didn't make.
class _JobRow extends StatelessWidget {
  const _JobRow({required this.item});
  final ServiceBookingItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Text('${item.quantity} × ৳${item.unitPrice}',
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF94A3B8))),
                if (item.notes.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(item.notes,
                      style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF94A3B8))),
                ],
                if (item.addedLater) ...[
                  const SizedBox(height: 5),
                  _Tag(
                    label: item.addedByRole == 'customer'
                        ? 'Added by you'.tr
                        : 'Added by ${item.addedByRole}'.tr,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('৳${item.lineTotal}',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}

/// One part/material line. Quantity carries a unit (litre, piece) because
/// materials are not sold as whole counts.
class _PartRow extends StatelessWidget {
  const _PartRow({required this.part});
  final ServiceBookingExtraItem part;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Text('${part.quantityWithUnit} × ৳${part.unitPrice}',
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF94A3B8))),
                if (part.addedByRole.isNotEmpty &&
                    part.addedByRole != 'customer') ...[
                  const SizedBox(height: 5),
                  _Tag(label: 'Added by ${part.addedByRole}'.tr),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('৳${part.lineTotal}',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(6)),
        child: Text(label,
            style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2563EB))),
      );
}

/// Tells the customer where they stand on payment. The total can move
/// after an edit, so a previously-settled order may show a balance again.
class _PaymentNote extends StatelessWidget {
  const _PaymentNote({required this.booking});
  final ServiceBooking booking;

  @override
  Widget build(BuildContext context) {
    late final String text;
    late final Color fg;
    late final Color bg;
    switch (booking.paymentStatus) {
      case 'paid':
        text = 'Paid in full'.tr;
        fg = const Color(0xFF047857);
        bg = const Color(0xFFECFDF5);
        break;
      case 'partial':
        text = 'Partially paid — balance due on completion'.tr;
        fg = const Color(0xFFB45309);
        bg = const Color(0xFFFFFBEB);
        break;
      case 'refunded':
        text = 'Refunded'.tr;
        fg = const Color(0xFF64748B);
        bg = const Color(0xFFF1F5F9);
        break;
      default:
        text = 'Payment due'.tr;
        fg = const Color(0xFF475569);
        bg = const Color(0xFFF1F5F9);
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(text,
          style: TextStyle(
              fontSize: 12.5, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}
