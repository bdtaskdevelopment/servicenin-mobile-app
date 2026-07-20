import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/values/app_config.dart';
import '../../../data/models/response/content_response.dart';
import '../controllers/works_controller.dart';

const _teal = Color(0xFF0891B2);

String _mediaUrl(String path) {
  if (path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  final base = AppConfig.baseUrl.endsWith('/')
      ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
      : AppConfig.baseUrl;
  return path.startsWith('/') ? '$base$path' : '$base/$path';
}

/// Full "Our Work" post — opened from [WorksView]. Tapping the thumbnail
/// opens a popup player for YouTube videos ([_VideoPlayerDialog]); other
/// providers (Facebook/unknown) open the original link externally.
class WorkDetailView extends GetView<WorksController> {
  const WorkDetailView({super.key});

  void _play(BuildContext context, WorksController con, WorkPost p) {
    if (p.canPlayInline) {
      // A pushed route (not showDialog) — webview-based players are known
      // to render/respond unreliably when hosted inside a Dialog's overlay.
      Navigator.of(context, rootNavigator: true).push(
        PageRouteBuilder(
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.black87,
          pageBuilder: (_, __, ___) => _VideoPlayerPage(videoId: p.videoId),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    } else {
      con.playVideo(p.videoUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<WorksController>(
          builder: (con) {
            final p = con.selected;
            if (p == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      IconButton(
                        splashRadius: 22,
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: Color(0xFF1A1A1A)),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: GestureDetector(
                      onTap: () => _play(context, con, p),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _VideoThumbnail(
                            imageUrl: _mediaUrl(p.thumbnailUrl)),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.title,
                            style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                height: 1.3)),
                        if (p.dateLabel.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 13, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 6),
                              Text(p.dateLabel,
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ],
                        if (p.description.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Text(p.description,
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF334155),
                                  height: 1.6)),
                        ],
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () => _play(context, con, p),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _teal,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded,
                                size: 20),
                            label: Text('Watch video'.tr,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
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

/// Static thumbnail + play glyph. Tapping is handled by the parent —
/// popup player for YouTube, external link for everything else.
class _VideoThumbnail extends StatelessWidget {
  const _VideoThumbnail({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageUrl.isEmpty
              ? Container(color: const Color(0xFFE0F2FE))
              : CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, u) =>
                      Container(color: const Color(0xFFF1F5F9)),
                  errorWidget: (_, u, e) =>
                      Container(color: const Color(0xFFE0F2FE)),
                ),
          Container(
            alignment: Alignment.center,
            color: Colors.black.withValues(alpha: 0.18),
            child: Container(
              width: 56,
              height: 56,
              decoration:
                  const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow_rounded,
                  color: _teal, size: 34),
            ),
          ),
        ],
      ),
    );
  }
}

/// Popup video player — a pushed (non-Dialog) route so the underlying
/// WebView renders and responds to touch reliably. Tap the barrier
/// (outside the card) or the close button to dismiss.
///
/// The close button lives in its own row above the player rather than
/// stacked on top of it: on Android, the WebView backing the YouTube
/// player is composited as a platform surface that can visually sit above
/// Flutter-drawn widgets regardless of widget z-order, which made an
/// overlaid close icon invisible/untappable on some devices.
class _VideoPlayerPage extends StatelessWidget {
  const _VideoPlayerPage({required this.videoId});
  final String videoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                    ),
                  ),
                ),
                Material(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _YoutubeInlinePlayer(videoId: videoId),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Native YouTube player (iframe API under the hood), used inside
/// [_VideoPlayerPage]. Owns its own controller for a clean dispose when the
/// popup closes.
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
    // autoPlay left off: unmuted autoplay is silently blocked by many mobile
    // WebViews, which can look like "the video doesn't play" — the visible
    // play button in the player's own controls always works reliably.
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: false,
    );
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
