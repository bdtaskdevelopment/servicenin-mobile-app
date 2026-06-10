import 'package:flutter/material.dart';

/// Lightweight, dependency-free shimmer used for loading skeletons across the
/// app. Wrap a tree of [SnBone]s in [SnShimmer] to animate a light band over
/// the grey placeholder shapes.
///
/// Usage:
///   const SnListSkeleton()                       // generic list placeholder
///   SnShimmer(child: Column(children: [ SnBone(...) ]))   // custom skeleton
class SnShimmer extends StatefulWidget {
  const SnShimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE9EDF2),
    this.highlightColor = const Color(0xFFF7F9FB),
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  @override
  State<SnShimmer> createState() => _SnShimmerState();
}

class _SnShimmerState extends State<SnShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final dx = bounds.width;
            // Slide the highlight band from left to right (-1 → 2).
            final slide = (t * 3) - 1;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.35, 0.5, 0.65],
              transform: _SlideGradient(slide * dx),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.dx);
  final double dx;
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(dx, 0, 0);
}

/// A single grey placeholder shape. Tinted/animated by an ancestor [SnShimmer].
class SnBone extends StatelessWidget {
  const SnBone({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 8,
    this.shape = BoxShape.rectangle,
    this.color = const Color(0xFFE9EDF2),
  });

  final double? width;
  final double height;
  final double radius;
  final BoxShape shape;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        shape: shape,
        borderRadius:
            shape == BoxShape.circle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}

/// A common "card row" skeleton: leading square, two text lines, trailing pill.
class SnCardRowSkeleton extends StatelessWidget {
  const SnCardRowSkeleton({super.key, this.showTrailing = true});
  final bool showTrailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Row(
        children: [
          const SnBone(width: 46, height: 46, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SnBone(width: 160, height: 13),
                SizedBox(height: 8),
                SnBone(width: 110, height: 11),
              ],
            ),
          ),
          if (showTrailing) ...[
            const SizedBox(width: 12),
            const SnBone(width: 58, height: 22, radius: 20),
          ],
        ],
      ),
    );
  }
}

/// A vertical list of card-row skeletons wrapped in a single shimmer.
class SnListSkeleton extends StatelessWidget {
  const SnListSkeleton({
    super.key,
    this.count = 6,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 16),
    this.showTrailing = true,
  });

  final int count;
  final EdgeInsets padding;
  final bool showTrailing;

  @override
  Widget build(BuildContext context) {
    return SnShimmer(
      child: ListView.separated(
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => SnCardRowSkeleton(showTrailing: showTrailing),
      ),
    );
  }
}

/// A grid of square tiles (icon + label) for service grids.
class SnGridSkeleton extends StatelessWidget {
  const SnGridSkeleton({
    super.key,
    this.count = 8,
    this.crossAxisCount = 3,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.childAspectRatio = 1.0,
  });

  final int count;
  final int crossAxisCount;
  final EdgeInsets padding;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return SnShimmer(
      child: GridView.builder(
        padding: padding,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
        ),
        itemBuilder: (_, _) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDEFF2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SnBone(width: 46, height: 46, radius: 14),
              SizedBox(height: 10),
              SnBone(width: 54, height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
