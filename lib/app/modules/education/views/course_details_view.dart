import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/primary_button.dart';
import '../../../global_widget/rich_html_text.dart';
import '../controllers/education_controller.dart';

const _orange = AppColors.brandOrange;
const _darkOrange = AppColors.brandOrangeDark;
const _tile = Color(0xFFFFEDE4);

/// Course details — the page the center-view's course cards open into.
/// Shows the admin-set YouTube video (if any) playing inline, or a static
/// thumbnail when there's only an image, then the course's full
/// description and a Register CTA.
class CourseDetailsView extends GetView<EducationController> {
  const CourseDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<EducationController>(
          builder: (con) {
            final course = con.course;
            if (course == null) return const SizedBox.shrink();
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 16, 4),
                  child: Row(
                    children: [
                      IconButton(
                        splashRadius: 22,
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: Color(0xFF1A1A1A)),
                      ),
                      Expanded(
                        child: Text(
                          'Course details'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A)),
                        ),
                      ),
                      if (con.loadingCourseDetail)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: _orange),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      if (course.hasVideo)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: _YoutubeInlinePlayer(
                                videoId: course.youtubeId),
                          ),
                        )
                      else if (course.displayThumbnail.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: CachedNetworkImage(
                              imageUrl: course.displayThumbnail,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: _tile),
                              errorWidget: (_, __, ___) =>
                                  Container(color: _tile),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              course.title,
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A)),
                            ),
                          ),
                          if (course.targetClass.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                  color: _tile,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(course.targetClass,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _darkOrange)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEDEFF2)),
                        ),
                        child: Column(
                          children: [
                            if (course.instructor.isNotEmpty)
                              _InfoRow(Icons.person_outline_rounded,
                                  'Instructor'.tr, course.instructor),
                            if (course.durationText.isNotEmpty)
                              _InfoRow(Icons.timelapse_rounded,
                                  'Duration'.tr, course.durationText),
                            if (course.schedule.isNotEmpty)
                              _InfoRow(Icons.schedule_rounded,
                                  'Schedule'.tr, course.schedule),
                            _InfoRow(Icons.payments_outlined, 'Fee'.tr,
                                course.feeLabel,
                                last: true),
                          ],
                        ),
                      ),
                      if (course.description.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text('About this course'.tr,
                            style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 8),
                        RichHtmlText(
                          course.description,
                          style: const TextStyle(
                              fontSize: 13, height: 1.6, color: Color(0xFF475569)),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: PrimaryButton(
                    label: 'Register'.tr,
                    onPressed: () => con.enquire(course),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value, {this.last = false});
  final IconData icon;
  final String label;
  final String value;
  final bool last;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: Row(
        children: [
          Icon(icon, size: 17, color: _darkOrange),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A))),
          ),
        ],
      ),
    );
  }
}

/// Native YouTube player (iframe API under the hood) — same pattern as
/// content/work_detail_view.dart's inline player, duplicated per this
/// codebase's per-module widget convention.
class _YoutubeInlinePlayer extends StatefulWidget {
  const _YoutubeInlinePlayer({required this.videoId});
  final String videoId;

  @override
  State<_YoutubeInlinePlayer> createState() => _YoutubeInlinePlayerState();
}

class _YoutubeInlinePlayerState extends State<_YoutubeInlinePlayer> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: false,
    );
  }

  @override
  void didUpdateWidget(covariant _YoutubeInlinePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId) {
      _controller.loadVideoById(videoId: widget.videoId);
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(controller: _controller);
  }
}
