import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/values/app_assets.dart';
import '../core/values/app_colors.dart';
import '../core/values/app_dismens.dart';

class AppbarWidget extends StatelessWidget {
  const AppbarWidget({super.key,this.title,this.onTap,this.showRightBtn,this.rightBtnTitle,this.rightBtnOnTap});
  final void Function()? onTap ;
  final String? title ;
  final bool? showRightBtn;
  final String? rightBtnTitle;
  final void Function()? rightBtnOnTap;

  @override
  Widget build(BuildContext context) {
    const arrowColor = AppColors.appColor;
    return Row(children: [
      InkWell(
        onTap: onTap,
        child: Container(
          height: AppDismens.size100,
          width: AppDismens.size50,
          alignment: Alignment.center,
          child: Image.asset(
            AppAssets.arrow_left,
            height: AppDismens.size24,
            width: AppDismens.size24,
            color: arrowColor,
            colorBlendMode: BlendMode.srcIn,
          ),
        ),
      ),
      Expanded(
        child: Text(
          "$title",
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.headingColor,
            fontWeight: FontWeight.bold,
            fontSize: AppDismens.size15,
          ),
        ),
      ),
      showRightBtn == true ?
      InkWell(
        onTap: rightBtnOnTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppDismens.size10,vertical: AppDismens.size10 ),
          decoration: BoxDecoration(
              border: Border.all(width: 1,color: AppColors.appColor),
              borderRadius: BorderRadius.circular(AppDismens.size10)
          ),
          child: Text("$rightBtnTitle",style: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.headingColor,
            fontSize: AppDismens.size14,
          ),),
        ),
      ):Container()
    ]);
  }
}
