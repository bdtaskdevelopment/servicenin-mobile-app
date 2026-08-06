import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/funeral_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/funeral_controller.dart';

const _charcoal = Color(0xFF332F2C);
const _greenTile = Color(0xFFD6F5E3);
const _grayTile = Color(0xFFE8EAED);
const _subtitle = Color(0xFF6B7A99);

class FuneralRequestsView extends GetView<FuneralController> {
  const FuneralRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
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
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    'My requests'.tr,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<FuneralController>(
                builder: (con) {
                  if (con.loadingRequests && con.myRequests.isEmpty) {
                    return const SnListSkeleton();
                  }
                  if (con.myRequests.isEmpty) {
                    return const _Empty();
                  }
                  return RefreshIndicator(
                    color: _charcoal,
                    onRefresh: con.fetchMyRequests,
                    child: FadeInUp(
                      from: 18,
                      duration: const Duration(milliseconds: 350),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: con.myRequests.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _RequestCard(
                          req: con.myRequests[i],
                          onCall: con.call,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(
          Icons.receipt_long_outlined,
          size: 56,
          color: Colors.black.withValues(alpha: 0.18),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            'No requests yet'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Your funeral service requests will appear here.'.tr,
            style: const TextStyle(fontSize: 13, color: _subtitle),
          ),
        ),
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.req, required this.onCall});
  final FuneralRequest req;
  final ValueChanged<String> onCall;

  bool get _isPending => req.status == 'pending';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  req.serviceName.isNotEmpty
                      ? req.serviceName
                      : 'Funeral request'.tr,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _isPending ? const Color(0xFFFEF3C7) : _greenTile,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  req.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _isPending
                        ? const Color(0xFFB45309)
                        : const Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            req.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          if (req.address.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 15,
                  color: _subtitle,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    req.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, color: _subtitle),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _grayTile.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _row('Phone'.tr, req.phone),
                if (req.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _row('Notes'.tr, req.notes),
                ],
              ],
            ),
          ),
          // Assigned staff — who is coming, and a one-tap way to reach them.
          // Shown from the request's own snapshot, so it stays here even if
          // that person later leaves the team.
          if (req.hasStaff) ...[
            const SizedBox(height: 12),
            _AssignedStaff(req: req, onCall: onCall),
          ],
          if (req.createdLabel.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Requested ${req.createdLabel}',
              style: const TextStyle(fontSize: 11.5, color: _subtitle),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String k, String v) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 80,
        child: Text(
          k,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: _subtitle,
          ),
        ),
      ),
      Expanded(
        child: Text(
          v,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
    ],
  );
}

/// The person handling this request: photo, name, designation and a call
/// button. Rendered only when someone has actually been assigned.
class _AssignedStaff extends StatelessWidget {
  const _AssignedStaff({required this.req, required this.onCall});
  final FuneralRequest req;
  final ValueChanged<String> onCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _greenTile.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFE8D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assigned staff'.tr,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15803D),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Avatar(url: req.staffPhoto),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.staffName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (req.staffDesignation.isNotEmpty)
                      Text(
                        req.staffDesignation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11.5, color: _subtitle),
                      ),
                    if (req.staffPhone.isNotEmpty)
                      Text(
                        req.staffPhone,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),
                  ],
                ),
              ),
              if (req.staffPhone.isNotEmpty)
                GestureDetector(
                  onTap: () => onCall(req.staffPhone),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF15803D),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.call_rounded,
                            size: 15, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          'Call'.tr,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Staff photo, falling back to a neutral placeholder when there is no
/// picture on file or the image cannot be loaded.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    const size = 44.0;
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _grayTile,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: const Icon(Icons.person_rounded, color: Color(0xFF94A3B8)),
    );
    if (url.isEmpty) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }
}
