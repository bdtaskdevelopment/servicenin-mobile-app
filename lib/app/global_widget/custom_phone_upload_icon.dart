import 'package:flutter/material.dart';

import '../core/values/app_colors.dart';
import '../core/values/app_dismens.dart';

class CustomPhoneUploadIcon extends StatelessWidget {
  const CustomPhoneUploadIcon({super.key, this.img, this.width, this.height});

  final String? img;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: height ?? AppDismens.size100,
        width: width ?? AppDismens.size100,
        decoration: BoxDecoration(
          color: AppColors.hashShadow,
          borderRadius: BorderRadius.circular(AppDismens.size145),
        ),
        child: Center(
          child: Container(
            height: AppDismens.size70,
            width: AppDismens.size70,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDismens.size120),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: AppDismens.size10, vertical: AppDismens.size8),
                height: AppDismens.size30,
                width: AppDismens.size30,
                decoration: BoxDecoration(
                    color: AppColors.normalGreen,
                    borderRadius: BorderRadius.circular(AppDismens.size10)),
                child: Image.asset(
                  "$img",
                  height: AppDismens.size30,
                  width: AppDismens.size30,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
