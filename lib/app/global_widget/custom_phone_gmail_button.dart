import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/values/app_colors.dart';
import '../core/values/app_dismens.dart';

class CustomPhoneGmailButton extends StatelessWidget {
  const CustomPhoneGmailButton(
      {super.key,
      this.title,
      this.img,
      this.onTap,
      this.height,
      this.titleSize,
      this.imageWidth,
      this.loading,
      this.imageHeight});

  final String? title;
  final String? img;
  final double? height;
  final double? titleSize;
  final double? imageHeight;
  final double? imageWidth;
  final bool? loading;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height ?? AppDismens.size50,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDismens.size10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loading == true
                ? SizedBox(
                    height: AppDismens.size20,
                    width: AppDismens.size20,
                    child: CircularProgressIndicator(),
                  )
                : Image.asset(
                    img!,
                    width: imageWidth ?? AppDismens.size20,
                    height: imageHeight ?? AppDismens.size20,
                  ),
            SizedBox(
              width: AppDismens.size15,
            ),
            Text(
              "$title",
              style: context.textTheme.titleSmall?.copyWith(
                  color: AppColors.hash,
                  fontSize: titleSize ?? AppDismens.size14),
            )
          ],
        ),
      ),
    );
  }
}
