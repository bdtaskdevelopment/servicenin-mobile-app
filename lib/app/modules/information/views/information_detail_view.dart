import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_config.dart';
import '../../../data/models/response/info_response.dart';
import '../controllers/information_controller.dart';
import 'information_view.dart' show InfoSupportIconButton;

const _blue = Color(0xFF0183C7);
const _green = Color(0xFF16A34A);
const _orange = Color(0xFFF16621);

String _mediaUrl(String path) {
  if (path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  final base = AppConfig.baseUrl.endsWith('/')
      ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
      : AppConfig.baseUrl;
  return path.startsWith('/') ? '$base$path' : '$base/$path';
}

/// Full directory-entry detail page — opened from a tap on a directory
/// card, backed by GET /api/v1/info/:id.
class InformationDetailView extends GetView<InformationController> {
  const InformationDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body: GetBuilder<InformationController>(
        builder: (con) {
          final e = con.selected;
          if (e == null) {
            return const SafeArea(
                child: Center(child: CircularProgressIndicator()));
          }
          final logo = _mediaUrl(e.logoUrl);
          final (iconBg, iconFg) = infoDomainColor(e.domain);
          final location = [e.upazila, e.district, e.division]
              .where((s) => s.isNotEmpty)
              .join(', ');

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // ── Hero banner ───────────────────────────────
                    Container(
                      padding: EdgeInsets.fromLTRB(
                          20, MediaQuery.of(context).padding.top + 8, 20, 22),
                      decoration: const BoxDecoration(
                        color: _blue,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Get.back(),
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(LucideIcons.chevronLeft,
                                      size: 18, color: Colors.white),
                                ),
                              ),
                              const Spacer(),
                              if (con.detailLoading)
                                const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  ),
                                ),
                              const InfoSupportIconButton(),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: logo.isNotEmpty
                                    ? ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: logo,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          placeholder: (_, u) =>
                                              const SizedBox.shrink(),
                                          errorWidget: (_, u, err) => Icon(
                                              infoDomainIcon(e.domain),
                                              color: iconFg,
                                              size: 28),
                                        ),
                                      )
                                    : Icon(infoDomainIcon(e.domain),
                                        color: iconFg, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(e.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 19,
                                            fontWeight: FontWeight.w800,
                                            height: 1.25)),
                                    if (e.titleBn.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(e.titleBn,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.85),
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        if (e.verified)
                                          _HeroTag('Verified'.tr,
                                              LucideIcons.badgeCheck),
                                        _HeroTag(e.tagLabel, null),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Quick actions ─────────────────────────
                          _QuickActionsRow(con: con, e: e),

                          if (e.description.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            _Card(
                              child: Text(e.description,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.55,
                                      color: Color(0xFF334155))),
                            ),
                          ],

                          // ── Contact ─────────────────────────────
                          if (e.contactPerson.isNotEmpty ||
                              e.phone.isNotEmpty ||
                              e.phone2.isNotEmpty ||
                              e.hotline.isNotEmpty ||
                              e.whatsapp.isNotEmpty ||
                              e.email.isNotEmpty ||
                              e.website.isNotEmpty ||
                              e.fax.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            Text('CONTACT'.tr,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF94A3B8),
                                    letterSpacing: 0.6)),
                            const SizedBox(height: 10),
                            if (e.hotline.isNotEmpty) ...[
                              _ContactRow(
                                  number: e.hotline,
                                  onTap: () => con.callHotline(e.hotline)),
                              const SizedBox(height: 10),
                            ],
                            if (e.phone.isNotEmpty) ...[
                              _ContactRow(
                                  number: e.phone,
                                  onTap: () => con.callHotline(e.phone)),
                              const SizedBox(height: 10),
                            ],
                            if (e.phone2.isNotEmpty) ...[
                              _ContactRow(
                                  number: e.phone2,
                                  onTap: () => con.callHotline(e.phone2)),
                              const SizedBox(height: 10),
                            ],
                            if (e.contactPerson.isNotEmpty ||
                                e.whatsapp.isNotEmpty ||
                                e.email.isNotEmpty ||
                                e.website.isNotEmpty ||
                                e.fax.isNotEmpty)
                              _Card(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    if (e.contactPerson.isNotEmpty)
                                      _InfoRow(
                                          LucideIcons.user, e.contactPerson),
                                    if (e.whatsapp.isNotEmpty)
                                      _ActionRow(
                                        icon: LucideIcons.messageCircle,
                                        text: e.whatsapp,
                                        actionIcon: LucideIcons.arrowUpRight,
                                        actionColor: _green,
                                        onTap: () =>
                                            con.openWhatsapp(e.whatsapp),
                                      ),
                                    if (e.email.isNotEmpty)
                                      _ActionRow(
                                        icon: LucideIcons.mail,
                                        text: e.email,
                                        actionIcon: LucideIcons.arrowUpRight,
                                        actionColor: _blue,
                                        onTap: () => con.openEmail(e.email),
                                      ),
                                    if (e.website.isNotEmpty)
                                      _ActionRow(
                                        icon: LucideIcons.globe,
                                        text: e.website,
                                        actionIcon: LucideIcons.arrowUpRight,
                                        actionColor: _blue,
                                        onTap: () =>
                                            con.openExternal(e.website),
                                      ),
                                    if (e.fax.isNotEmpty)
                                      _InfoRow(LucideIcons.printer, e.fax),
                                  ],
                                ),
                              ),
                          ],

                          // ── Location ────────────────────────────
                          if (e.address.isNotEmpty ||
                              location.isNotEmpty ||
                              e.wardNo.isNotEmpty ||
                              e.mapUrl.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            _Section(
                              title: 'LOCATION'.tr,
                              children: [
                                if (e.address.isNotEmpty)
                                  _InfoRow(LucideIcons.mapPin, e.address),
                                if (location.isNotEmpty)
                                  _InfoRow(LucideIcons.map, location),
                                if (e.wardNo.isNotEmpty)
                                  _InfoRow(LucideIcons.locateFixed,
                                      '${'Ward'.tr} ${e.wardNo}'),
                                if (e.mapUrl.isNotEmpty)
                                  _ActionRow(
                                    icon: LucideIcons.map,
                                    text: 'View on map'.tr,
                                    actionIcon: LucideIcons.arrowUpRight,
                                    actionColor: _blue,
                                    onTap: () => con.openExternal(e.mapUrl),
                                  ),
                              ],
                            ),
                          ],

                          // ── Additional info ─────────────────────
                          if (e.officeHours.isNotEmpty ||
                              e.ministry.isNotEmpty ||
                              e.emergencyContact.isNotEmpty ||
                              e.specialization.isNotEmpty ||
                              e.serviceArea.isNotEmpty ||
                              e.availableServices.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            _Section(
                              title: 'ADDITIONAL INFO'.tr,
                              children: [
                                if (e.officeHours.isNotEmpty)
                                  _InfoRow(LucideIcons.clock, e.officeHours),
                                if (e.ministry.isNotEmpty)
                                  _InfoRow(LucideIcons.landmark, e.ministry),
                                if (e.specialization.isNotEmpty)
                                  _InfoRow(LucideIcons.stethoscope,
                                      e.specialization),
                                if (e.serviceArea.isNotEmpty)
                                  _InfoRow(LucideIcons.compass, e.serviceArea),
                                if (e.availableServices.isNotEmpty)
                                  _InfoRow(LucideIcons.listChecks,
                                      e.availableServices),
                                if (e.emergencyContact.isNotEmpty)
                                  _ActionRow(
                                    icon: LucideIcons.siren,
                                    text: e.emergencyContact,
                                    actionIcon: LucideIcons.phone,
                                    actionColor: const Color(0xFFE4484D),
                                    onTap: () =>
                                        con.callHotline(e.emergencyContact),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (e.callNumber.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () => con.callHotline(e.callNumber),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _orange,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(LucideIcons.phone, size: 19),
                            label: Text('Call'.tr,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ),
                      if (e.whatsapp.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 52,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => con.openWhatsapp(e.whatsapp),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child:
                                const Icon(LucideIcons.messageCircle, size: 22),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Quick actions strip (Call / WhatsApp / Email / Website / Map) ────
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.con, required this.e});
  final InformationController con;
  final InfoEntry e;

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickAction>[
      if (e.callNumber.isNotEmpty)
        _QuickAction('Call'.tr, LucideIcons.phone, _green,
            () => con.callHotline(e.callNumber)),
      if (e.whatsapp.isNotEmpty)
        _QuickAction('WhatsApp'.tr, LucideIcons.messageCircle, _green,
            () => con.openWhatsapp(e.whatsapp)),
      if (e.email.isNotEmpty)
        _QuickAction('Email'.tr, LucideIcons.mail, _blue,
            () => con.openEmail(e.email)),
      if (e.website.isNotEmpty)
        _QuickAction('Website'.tr, LucideIcons.globe, _blue,
            () => con.openExternal(e.website)),
      if (e.mapUrl.isNotEmpty)
        _QuickAction('Map'.tr, LucideIcons.map, const Color(0xFFB86E00),
            () => con.openExternal(e.mapUrl)),
    ];
    if (actions.isEmpty) return const SizedBox.shrink();
    return Row(
      children: actions
          .map((a) => Expanded(
                child: GestureDetector(
                  onTap: a.onTap,
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: a.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(a.icon, color: a.color, size: 20),
                      ),
                      const SizedBox(height: 6),
                      Text(a.label,
                          style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155))),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _QuickAction {
  const _QuickAction(this.label, this.icon, this.color, this.onTap);
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _HeroTag extends StatelessWidget {
  const _HeroTag(this.text, this.icon);
  final String text;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(text,
              style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ],
      ),
    );
  }
}

/// Phone-number pill matching the mockup's "যোগাযোগ" row exactly: a light
/// rounded bar with a phone glyph, the number, and a solid blue call button.
class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.number, required this.onTap});
  final String number;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.phone, size: 17, color: _blue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(number,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: _blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.phone, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded white card wrapper used for the description and each section.
class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: child,
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 2),
          child: Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.8)),
        ),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

/// Plain, non-interactive detail row.
class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155))),
          ),
        ],
      ),
    );
  }
}

/// Tappable detail row (call / email / open link) with a trailing action
/// glyph in a tinted circle.
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.text,
    required this.actionIcon,
    required this.actionColor,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final IconData actionIcon;
  final Color actionColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF64748B)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A))),
            ),
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: actionColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(actionIcon, size: 15, color: actionColor),
            ),
          ],
        ),
      ),
    );
  }
}
