import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_config.dart';
import '../../../data/models/response/info_response.dart';
import '../controllers/information_controller.dart';

const _purple = Color(0xFF6366F1);
const _red = Color(0xFFE8333A);
const _green = Color(0xFF16A34A);

String _mediaUrl(String path) {
  if (path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  final base = AppConfig.baseUrl.endsWith('/')
      ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
      : AppConfig.baseUrl;
  return path.startsWith('/') ? '$base$path' : '$base/$path';
}

/// Hero background gradient — a soft, light indigo for emergency entries
/// (matches the app's primary accent, used consistently across the page's
/// quick actions and tags), otherwise a color keyed off the entry's domain
/// so different categories feel distinct.
List<Color> _heroColors(String domain, bool isEmergency) {
  if (isEmergency) return const [Color(0xFF93A5FD), Color(0xFF7C8EF5)];
  switch (domain) {
    case 'health':
      return const [Color(0xFF5EEAD4), Color(0xFF2DD4BF)];
    case 'government':
      return const [Color(0xFF93A5FD), Color(0xFF7C8EF5)];
    case 'utility':
      return const [Color(0xFFFCD34D), Color(0xFFFBBF24)];
    default:
      return const [Color(0xFFB0BAC9), Color(0xFF94A3B8)];
  }
}

/// Full directory-entry detail page — opened from a tap on a directory
/// card, backed by GET /api/v1/info/:id.
class InformationDetailView extends GetView<InformationController> {
  const InformationDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: GetBuilder<InformationController>(
        builder: (con) {
          final e = con.selected;
          if (e == null) {
            return const SafeArea(
                child: Center(child: CircularProgressIndicator()));
          }
          final logo = _mediaUrl(e.logoUrl);
          final emoji = con.domainFor(e.domain)?.emoji ?? '📌';
          final location = [e.upazila, e.district, e.division]
              .where((s) => s.isNotEmpty)
              .join(', ');
          final heroColors = _heroColors(e.domain, e.isEmergency);

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
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: heroColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
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
                                  child: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 16,
                                      color: Colors.white),
                                ),
                              ),
                              const Spacer(),
                              if (con.detailLoading)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                ),
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
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      width: 2),
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
                                          errorWidget: (_, u, err) => Text(
                                              emoji,
                                              style: const TextStyle(
                                                  fontSize: 26)),
                                        ),
                                      )
                                    : Text(emoji,
                                        style: const TextStyle(fontSize: 26)),
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
                                              Icons.verified_rounded),
                                        if (e.typeLabel.isNotEmpty)
                                          _HeroTag(e.typeLabel, null),
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
                              e.fax.isNotEmpty ||
                              e.email.isNotEmpty ||
                              e.website.isNotEmpty ||
                              e.whatsapp.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            _Section(
                              title: 'CONTACT'.tr,
                              children: [
                                if (e.contactPerson.isNotEmpty)
                                  _InfoRow(Icons.person_outline_rounded,
                                      e.contactPerson),
                                if (e.hotline.isNotEmpty)
                                  _ActionRow(
                                    icon: Icons.support_agent_rounded,
                                    text: e.hotline,
                                    actionIcon: Icons.call_rounded,
                                    actionColor: _green,
                                    onTap: () => con.callHotline(e.hotline),
                                  ),
                                if (e.phone.isNotEmpty)
                                  _ActionRow(
                                    icon: Icons.call_outlined,
                                    text: e.phone,
                                    actionIcon: Icons.call_rounded,
                                    actionColor: _green,
                                    onTap: () => con.callHotline(e.phone),
                                  ),
                                if (e.phone2.isNotEmpty)
                                  _ActionRow(
                                    icon: Icons.call_outlined,
                                    text: e.phone2,
                                    actionIcon: Icons.call_rounded,
                                    actionColor: _green,
                                    onTap: () => con.callHotline(e.phone2),
                                  ),
                                if (e.whatsapp.isNotEmpty)
                                  _ActionRow(
                                    icon: Icons.chat_outlined,
                                    text: e.whatsapp,
                                    actionIcon: Icons.arrow_outward_rounded,
                                    actionColor: _green,
                                    onTap: () => con.openWhatsapp(e.whatsapp),
                                  ),
                                if (e.email.isNotEmpty)
                                  _ActionRow(
                                    icon: Icons.email_outlined,
                                    text: e.email,
                                    actionIcon: Icons.arrow_outward_rounded,
                                    actionColor: _purple,
                                    onTap: () => con.openEmail(e.email),
                                  ),
                                if (e.website.isNotEmpty)
                                  _ActionRow(
                                    icon: Icons.language_rounded,
                                    text: e.website,
                                    actionIcon: Icons.arrow_outward_rounded,
                                    actionColor: _purple,
                                    onTap: () => con.openExternal(e.website),
                                  ),
                                if (e.fax.isNotEmpty)
                                  _InfoRow(Icons.print_outlined, e.fax),
                              ],
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
                                  _InfoRow(
                                      Icons.location_on_outlined, e.address),
                                if (location.isNotEmpty)
                                  _InfoRow(Icons.map_outlined, location),
                                if (e.wardNo.isNotEmpty)
                                  _InfoRow(Icons.pin_drop_outlined,
                                      '${'Ward'.tr} ${e.wardNo}'),
                                if (e.mapUrl.isNotEmpty)
                                  _ActionRow(
                                    icon: Icons.map_rounded,
                                    text: 'View on map'.tr,
                                    actionIcon: Icons.arrow_outward_rounded,
                                    actionColor: _purple,
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
                                  _InfoRow(
                                      Icons.schedule_rounded, e.officeHours),
                                if (e.ministry.isNotEmpty)
                                  _InfoRow(Icons.account_balance_outlined,
                                      e.ministry),
                                if (e.specialization.isNotEmpty)
                                  _InfoRow(Icons.medical_services_outlined,
                                      e.specialization),
                                if (e.serviceArea.isNotEmpty)
                                  _InfoRow(
                                      Icons.explore_outlined, e.serviceArea),
                                if (e.availableServices.isNotEmpty)
                                  _InfoRow(Icons.checklist_rounded,
                                      e.availableServices),
                                if (e.emergencyContact.isNotEmpty)
                                  _ActionRow(
                                    icon: Icons.emergency_share_rounded,
                                    text: e.emergencyContact,
                                    actionIcon: Icons.call_rounded,
                                    actionColor: _red,
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
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => con.callHotline(e.callNumber),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.call_rounded, size: 20),
                      label: Text('Call ${e.callNumber}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
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
        _QuickAction('Call'.tr, Icons.call_rounded, _green,
            () => con.callHotline(e.callNumber)),
      if (e.whatsapp.isNotEmpty)
        _QuickAction('WhatsApp'.tr, Icons.chat_rounded, _green,
            () => con.openWhatsapp(e.whatsapp)),
      if (e.email.isNotEmpty)
        _QuickAction('Email'.tr, Icons.email_rounded, _purple,
            () => con.openEmail(e.email)),
      if (e.website.isNotEmpty)
        _QuickAction('Website'.tr, Icons.language_rounded, _purple,
            () => con.openExternal(e.website)),
      if (e.mapUrl.isNotEmpty)
        _QuickAction('Map'.tr, Icons.map_rounded, const Color(0xFFF59E0B),
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
                        child: Icon(a.icon, color: a.color, size: 22),
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
