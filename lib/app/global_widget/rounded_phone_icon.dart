import 'package:flutter/material.dart';

import '../core/values/app_assets.dart';
import '../core/values/app_colors.dart';
import '../core/values/app_dismens.dart';

class RoundedPhoneIcon extends StatelessWidget {
  const RoundedPhoneIcon(
      {super.key,
      this.imageHeight,
      this.imageWidth,
      this.mainContainerHeight,
      this.mainContainerWidth,
      this.shadowHeight,
      this.mainPaddingHorizontal,
      this.mainPaddingVertical,
      this.shadowWidth});

  final double? imageHeight;
  final double? imageWidth;
  final double? shadowWidth;
  final double? shadowHeight;
  final double? mainContainerHeight;
  final double? mainContainerWidth;
  final double? mainPaddingHorizontal;
  final double? mainPaddingVertical;

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Container(
        padding: EdgeInsets.all(AppDismens.size6),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDismens.size140 / 2),
            color: AppColors.normalGreen.withOpacity(0.2)),
        width: shadowWidth ?? AppDismens.size140,
        height: shadowHeight ?? AppDismens.size140,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: mainPaddingHorizontal ?? AppDismens.size20,
              vertical: mainPaddingVertical ?? AppDismens.size20),
          width: mainContainerWidth ?? AppDismens.size80,
          height: mainContainerHeight ?? AppDismens.size30,
          decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(AppDismens.size140 / 2)),
          child: Center(
            // child: Image.asset(
            //   AppAssets.logo2,
            //   width: imageWidth ?? AppDismens.size140,
            //   height: imageHeight ?? AppDismens.size30,
            //   fit: BoxFit.fill,
            // ),
          ),
        ),
      ),
    );
  }
}
