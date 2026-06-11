import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart' as sa;

/// Facebook-style shimmer for loading skeletons across the app. Wrap a tree of
/// grey [SnBone]s in [SnShimmer]; a soft highlight sweeps across them.
///
/// Built on the `shimmer_animation` package (a `CustomPaint` overlay — robust
/// across render backends). Skeleton card backgrounds are kept transparent so
/// the individual bone shapes stay distinct.
///
/// Usage:
///   const SnListSkeleton()                              // generic list
///   SnShimmer(child: Column(children: [ SnBone(...) ])) // custom skeleton
class SnShimmer extends StatelessWidget {
  const SnShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return sa.Shimmer(
      duration: const Duration(milliseconds: 1300),
      interval: Duration.zero,
      color: Colors.white,
      colorOpacity: 0.65,
      direction: const sa.ShimmerDirection.fromLeftToRight(),
      child: child,
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
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => SnCardRowSkeleton(showTrailing: showTrailing),
      ),
    );
  }
}

/// A horizontal strip of card placeholders (for horizontal ListViews:
/// service shortcuts, date pickers, doctor/center rails, etc.).
class SnStripSkeleton extends StatelessWidget {
  const SnStripSkeleton({
    super.key,
    this.count = 5,
    this.itemWidth = 150,
    this.height = 110,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final int count;
  final double itemWidth;
  final double height;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: SnShimmer(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: padding,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, _) => SnBone(
            width: itemWidth,
            height: height,
            radius: 16,
          ),
        ),
      ),
    );
  }
}

/// A wrapping row of small pill placeholders (for chip/filter rows).
class SnChipsSkeleton extends StatelessWidget {
  const SnChipsSkeleton({super.key, this.count = 6});
  final int count;

  @override
  Widget build(BuildContext context) {
    return SnShimmer(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(
          count,
          (i) => SnBone(width: 78.0 + (i % 3) * 22, height: 34, radius: 20),
        ),
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
          // Adapt to the tile shape: tall square-ish tiles (categories /
          // departments) show an icon + label; short wide tiles (e.g. time
          // slots) show a single chip-like bone so nothing overflows.
          child: LayoutBuilder(
            builder: (context, c) {
              if (c.maxHeight.isFinite && c.maxHeight < 70) {
                return Center(
                  child: SnBone(
                    width: c.maxWidth.isFinite ? c.maxWidth * 0.55 : 40,
                    height: 12,
                    radius: 6,
                  ),
                );
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SnBone(width: 46, height: 46, radius: 14),
                  SizedBox(height: 10),
                  SnBone(width: 54, height: 10),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
