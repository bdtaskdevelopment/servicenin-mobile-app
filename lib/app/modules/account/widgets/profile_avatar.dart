import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Square rounded avatar that shows [photoUrl] when present, otherwise the
/// user's [initial]. Used across the account header, profile and edit screens.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.photoUrl,
    required this.initial,
    this.size = 84,
    this.radius = 24,
    this.background,
    this.foreground = Colors.white,
    this.fontSize = 32,
  });

  final String? photoUrl;
  final String initial;
  final double size;
  final double radius;
  final Color? background;
  final Color foreground;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final bg = background ?? Colors.white.withValues(alpha: 0.18);
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;

    Widget letter() => Text(
          initial,
          style: TextStyle(
            color: foreground,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
          ),
        );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: hasPhoto
          ? CachedNetworkImage(
              imageUrl: photoUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (context, url) => letter(),
              errorWidget: (context, url, error) => letter(),
            )
          : letter(),
    );
  }
}
