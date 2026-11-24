import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/blood_request_response.dart';
import '../../../data/models/response/blood_responder_response.dart';
import '../../../data/repositories/blood.repo.dart';
import '../../../routes/app_pages.dart';
import '../controllers/blood_controller.dart';
import '../controllers/need_blood_controller.dart';
import '../widgets/blood_widgets.dart';

const _red = Color(0xFFE5383B);
const _pinkTile = Color(0xFFFDECEC);
const _orange = Color(0xFFEA5A0C);

class BloodRequestDetailView extends GetView<BloodController> {
  const BloodRequestDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BloodController>(
      builder: (con) {
        final req = con.viewingRequest;
        if (req == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF4F5FA),
            body: SafeArea(
              child: Column(
                children: [
                  _DetailHeader(subtitle: '', onShare: null),
                  Expanded(
                    child: Center(
                      child: Text('Request not found'.tr,
                          style: const TextStyle(color: Color(0xFF94A3B8))),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final mine = con.isMyRequest(req);
        return Scaffold(
          backgroundColor: const Color(0xFFF4F5FA),
          body: SafeArea(
            child: Column(
              children: [
                _DetailHeader(
                  subtitle: req.id.isNotEmpty
                      ? 'BR-${req.id.substring(0, req.id.length < 6 ? req.id.length : 6).toUpperCase()}'
                      : '',
                  onShare: () {},
                ),
                Expanded(
                  child: mine ? _OwnerBody(con: con, req: req) : _DonorBody(req: req),
                ),
                if (!mine) _RespondBar(con: con, req: req),
                if (mine) _OwnerActionsBar(con: con, req: req),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Header ────────────────────────────────────────────────────────
class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.subtitle, required this.onShare});
  final String subtitle;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 10),
      child: Row(
        children: [
          IconButton(
            splashRadius: 22,
            onPressed: () => Get.back(),
            icon: const Icon(LucideIcons.chevronLeft,
                size: 22, color: Color(0xFF0F172A)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Blood request'.tr,
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 1),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ],
          ),
          const Spacer(),
          if (onShare != null)
            IconButton(
              splashRadius: 20,
              onPressed: onShare,
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: _pinkTile, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(LucideIcons.share2, size: 17, color: _red),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Shared info card ─────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.req, this.trailing});
  final BloodRequestEntry req;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final hospital = [req.hospitalName, req.hospitalAddress]
        .where((s) => s.isNotEmpty)
        .join(', ');
    final contact = [req.contactDisplay, req.phone].where((s) => s.isNotEmpty).join(' · ');
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BloodGroupBadge(group: req.bloodGroup, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${req.unitsNeeded} ${'bags'.tr} · ${req.bloodGroup}',
                        style: const TextStyle(
                            fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        BloodSeverityPill(severity: severityFromUrgency(req.urgency)),
                        _StatusPill(req: req),
                      ],
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          _InfoRow(icon: LucideIcons.building2, label: 'Hospital'.tr, value: hospital.isNotEmpty ? hospital : 'Not set'.tr),
          if (req.neededLabel.isNotEmpty) ...[
            const SizedBox(height: 14),
            _InfoRow(icon: LucideIcons.calendarDays, label: 'When needed'.tr, value: req.neededLabel),
          ],
          if (req.distanceLabel.isNotEmpty) ...[
            const SizedBox(height: 14),
            _InfoRow(icon: LucideIcons.mapPin, label: 'Distance from you'.tr, value: req.distanceLabel),
          ],
          const SizedBox(height: 14),
          _InfoRow(icon: LucideIcons.user, label: 'Contact'.tr, value: contact.isNotEmpty ? contact : 'Not provided'.tr),
          if (req.timeAgo.isNotEmpty) ...[
            const SizedBox(height: 14),
            _InfoRow(icon: LucideIcons.clock, label: 'Posted'.tr, value: req.timeAgo),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.req});
  final BloodRequestEntry req;

  @override
  Widget build(BuildContext context) {
    final filled = req.isFulfilled;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? const Color(0xFFDCFCE7) : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text((filled ? 'Fulfilled' : 'Active').tr,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: _pinkTile, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: _red),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Donor-facing body (someone else's request) ──────────────────────
class _DonorBody extends StatelessWidget {
  const _DonorBody({required this.req});
  final BloodRequestEntry req;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      children: [
        _InfoCard(req: req),
        if (req.notes.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text('Description'.tr,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14)),
            child: Text(req.notes,
                style: const TextStyle(fontSize: 13.5, color: Color(0xFF475569), height: 1.5)),
          ),
        ],
      ],
    );
  }
}

class _RespondBar extends StatelessWidget {
  const _RespondBar({required this.con, required this.req});
  final BloodController con;
  final BloodRequestEntry req;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Icon(LucideIcons.x, color: Color(0xFF334155)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: con.responding ? null : () => con.respondToRequest(req.id),
                icon: con.responding
                    ? const SizedBox.shrink()
                    : const Icon(LucideIcons.heart, size: 18),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _orange.withValues(alpha: 0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                label: con.responding
                    ? const SizedBox(
                        width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Text('I can donate'.tr,
                        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Owner body (my own request → absorbs the old responders screen) ──
class _OwnerBody extends StatelessWidget {
  const _OwnerBody({required this.con, required this.req});
  final BloodController con;
  final BloodRequestEntry req;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      children: [
        _InfoCard(
          req: req,
          trailing: req.status == 'open'
              ? GestureDetector(
                  onTap: () {
                    Get.find<NeedBloodController>().startEdit(req);
                    Get.toNamed(Routes.BLOOD_NEED);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.squarePen, size: 14, color: Color(0xFF334155)),
                        const SizedBox(width: 4),
                        Text('Edit'.tr,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                      ],
                    ),
                  ),
                )
              : null,
        ),
        if (req.notes.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14)),
            child: Text(req.notes,
                style: const TextStyle(fontSize: 13.5, color: Color(0xFF475569), height: 1.5)),
          ),
        ],
        if (req.status == 'open' && con.responders.length < 3) ...[
          const SizedBox(height: 14),
          _NotFindingDonorsPanel(con: con, req: req),
        ],
        const SizedBox(height: 18),
        Text('${'Who responded'.tr} (${con.responders.length})',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        const SizedBox(height: 10),
        if (con.loadingResponders && con.responders.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: _red)),
          )
        else if (con.responders.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14)),
            child: Text('No responders yet'.tr, style: const TextStyle(color: Color(0xFF94A3B8))),
          )
        else
          ...con.responders.asMap().entries.map((e) => FadeInUp(
                from: 18,
                duration: const Duration(milliseconds: 300),
                delay: Duration(milliseconds: 60 * (e.key < 6 ? e.key : 6)),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ResponderRow(r: e.value, con: con),
                ),
              )),
      ],
    );
  }
}

class _NotFindingDonorsPanel extends StatefulWidget {
  const _NotFindingDonorsPanel({required this.con, required this.req});
  final BloodController con;
  final BloodRequestEntry req;

  @override
  State<_NotFindingDonorsPanel> createState() => _NotFindingDonorsPanelState();
}

class _NotFindingDonorsPanelState extends State<_NotFindingDonorsPanel> {
  int _radius = 10;

  @override
  void initState() {
    super.initState();
    _radius = widget.req.searchRadiusKm > 0 ? widget.req.searchRadiusKm : 10;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Not finding a donor?'.tr,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: _orange)),
          const SizedBox(height: 3),
          Text('Widen the alert radius and search again'.tr,
              style: const TextStyle(fontSize: 12, color: Color(0xFF92400E))),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final km in NeedBloodController.radiusOptions) ...[
                Expanded(child: _RadiusChip(km: km, selected: _radius == km, onTap: () => setState(() => _radius = km))),
                if (km != NeedBloodController.radiusOptions.last) const SizedBox(width: 6),
              ],
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () async {
                final res = await Get.find<BloodRepository>()
                    .updateRequest(widget.req.id, {'search_radius_km': _radius, 'blood_group': widget.req.bloodGroup, 'units_needed': widget.req.unitsNeeded, 'hospital_name': widget.req.hospitalName});
                if (res.success) {
                  widget.con.fetchMyRequests();
                  widget.con.fetchResponders();
                }
              },
              icon: const Icon(LucideIcons.search, size: 16),
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              label: Text('Search again'.tr, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadiusChip extends StatelessWidget {
  const _RadiusChip({required this.km, required this.selected, required this.onTap});
  final int km;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _red : AppColors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(km == 0 ? 'All'.tr : '$km km',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: selected ? Colors.white : const Color(0xFF334155))),
      ),
    );
  }
}

class _ResponderRow extends StatelessWidget {
  const _ResponderRow({required this.r, required this.con});
  final BloodResponder r;
  final BloodController con;

  @override
  Widget build(BuildContext context) {
    final confirmed = r.status == 'donated';
    final filled = con.requestCompleted;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: _pinkTile, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(r.initials,
                style: const TextStyle(color: _red, fontSize: 14, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(
                    [if (r.distanceLabel.isNotEmpty) r.distanceLabel, if (r.status.isNotEmpty) r.status]
                        .join(' · '),
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          _StatusTag(status: r.status),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: filled ? null : () => con.callResponder(r),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: const Color(0xFF16A34A), shape: BoxShape.circle),
              child: const Icon(LucideIcons.phone, size: 16, color: Colors.white),
            ),
          ),
          if (!confirmed && !filled) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: con.completing ? null : () => con.confirmReceived(r),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: _orange, shape: BoxShape.circle),
                child: const Icon(LucideIcons.circleCheck, size: 16, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final confirmed = status == 'donated';
    final bg = confirmed ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7);
    final fg = confirmed ? const Color(0xFF16A34A) : const Color(0xFF92400E);
    final label = confirmed ? 'Confirmed'.tr : 'Responded'.tr;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}

class _OwnerActionsBar extends StatelessWidget {
  const _OwnerActionsBar({required this.con, required this.req});
  final BloodController con;
  final BloodRequestEntry req;

  @override
  Widget build(BuildContext context) {
    if (req.status != 'open') return const SizedBox.shrink();
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: con.closingRequest ? null : () => con.closeRequest(req),
                icon: const Icon(LucideIcons.x, size: 17),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF334155),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                label: Text('Reject'.tr, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: con.responders.isEmpty || con.requestCompleted
                    ? null
                    : () => con.confirmReceived(con.responders.first),
                icon: const Icon(LucideIcons.circleCheck, size: 18),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFF7C4AC),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                label: Text('Donation complete'.tr,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
