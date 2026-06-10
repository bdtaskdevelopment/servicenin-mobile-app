import 'package:flutter/material.dart';

/// Lightweight, dependency-free shimmer used for loading skeletons across the
/// app. Wrap a tree of [SnBone]s in [SnShimmer]; a light band sweeps across the
/// grey placeholder shapes continuously.
///
/// Important: skeleton card backgrounds are kept transparent so that `srcATop`
/// only tints the opaque [SnBone]s — this keeps the individual shapes visible
/// (a solid card fill would flatten everything into one grey block).
///
/// Usage:
///   const SnListSkeleton()                              // generic list
///   SnShimmer(child: Column(children: [ SnBone(...) ])) // custom skeleton
class SnShimmer extends StatefulWidget {
  const SnShimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFD9DFE6),
    this.highlightColor = const Color(0xFFF3F6F9),
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
      duration: const Duration(milliseconds: 1100),
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
        // Sweep the highlight band continuously from left to right.
        final slide = (_controller.value * 2.0) - 1.0; // -1 → 1
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(slide - 1.0, -0.25),
              end: Alignment(slide + 1.0, 0.25),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.25, 0.5, 0.75],
              tileMode: TileMode.clamp,
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A single grey placeholder shape. Tinted/animated by an ancestor [SnShimmer].
class SnBone extends StatelessWidget {
  const SnBone({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 8,
    this.shape = BoxShape.rectangle,
    this.color = const Color(0xFFD9DFE6),
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
/// Transparent fill (only the bones are opaque) so the shimmer stays visible.
class SnCardRowSkeleton extends StatelessWidget {
  const SnCardRowSkeleton({super.key, this.showTrailing = true});
  final bool showTrailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF1)),
      ),
      child: Row(
        children: [
          const SnBone(width: 46, height: 46, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SnBone(width: 170, height: 13),
                SizedBox(height: 9),
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
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8ECF1)),
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
