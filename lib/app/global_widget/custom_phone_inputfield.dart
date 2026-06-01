import 'package:servicenin/app/core/values/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

import '../core/values/app_colors.dart';
import '../core/values/app_dismens.dart';

class CustomPhoneInputfield extends StatelessWidget {
  CustomPhoneInputfield(
      {super.key,
      this.keyboardType,
      this.errorText,
      this.title,
      this.subtitle,
      this.hintTitle,
      this.controller,
      this.showRightIcon,
      this.rightIconOnTap,
      this.maxLines,
      this.fromFieldBackground,
      this.obscureText = false,
      this.enabled,
      this.onChanged,
      this.titleSize,
      this.containerHeight,
      this.rightIconHeight,
      this.rightIconWidth,
      this.rightIcon,
      this.leftIcon,
      this.leftIconOnTap,
        this.Focuscolor,
        this.showTitleImage,
        this.titleImage,
        this.readOnly,
      this.showLeftIcon});

  final TextInputType? keyboardType;
  final TextEditingController? controller;
  bool? showRightIcon = false;
  bool? enabled;
  final String? errorText;
  final String? title;
  final String? subtitle;
  final String? hintTitle;
  final void Function()? rightIconOnTap;
  final void Function()? leftIconOnTap;
  final String? rightIcon;
  final String? leftIcon;
  final int? maxLines;
  final Color? fromFieldBackground;
  final void Function(String)? onChanged;
  final double? titleSize;
  final double? containerHeight;
  final double? rightIconHeight;
  final double? rightIconWidth;
  final bool? showLeftIcon;
  final Color? Focuscolor;
  final bool? showTitleImage;
  final String? titleImage;
   bool? readOnly = false;
  bool? obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title == "" ? Container() :
        Row(
          children: [
            RichText(
              text: TextSpan(
                text: "$title",
                style: context.textTheme.titleMedium?.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: titleSize ?? AppDismens.size12),
                children: <TextSpan>[
                  TextSpan(
                    text: subtitle ?? "",
                    style: context.textTheme.titleSmall
                        ?.copyWith(color: AppColors.black),
                  ),
                ],
              ),
            ),
            showTitleImage == true ?
                Padding(
                  padding: EdgeInsets.only(left: AppDismens.size5),
                  child: SizedBox(
                    height: AppDismens.size13,
                    width: AppDismens.size13,
                    child: Image.asset(titleImage ??AppAssets.what,height:AppDismens.size13,width:AppDismens.size13 ,),
                  ),
                ) :
                Container()
          ],
        ),

        SizedBox(
          height:title == "" ? 0 : AppDismens.size10,
        ),
        Container(
          //height: containerHeight ?? AppDismens.size50,
          decoration: BoxDecoration(
            color: fromFieldBackground ?? AppColors.inputBackground,
            border: Border.all(
              color: errorText != null
                  ? AppColors.red
                  : (Focuscolor ?? Colors.transparent),
              width: 1,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(AppDismens.size10),
            ),
          ),
          child: Row(
            children: [
              showLeftIcon == false
                  ? Container()
                  : InkWell(
                onTap: rightIconOnTap,
                child: Padding(
                  padding: EdgeInsets.only(left: AppDismens.size10),
                  child: Image.asset(
                    "$leftIcon",
                    height: rightIconHeight ?? AppDismens.size20,
                    width: rightIconWidth ?? AppDismens.size20,
                  ),
                ),
              ),
              Flexible(
                child: TextFormField(
                  enabled: enabled ?? true,
                  controller: controller,
                  readOnly:readOnly??false,
                  cursorColor: AppColors.black,
                  keyboardType: keyboardType,
                  maxLines: maxLines ?? 1,
                  obscureText: obscureText!,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color:Focuscolor ?? AppColors.appColor, // <-- Focused border color
                          width: 1.0,             // Thickness
                        ),
                        borderRadius: BorderRadius.circular(10), // Same as your container
                      ),
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintStyle: TextStyle(
                          color: AppColors.hash, fontSize: AppDismens.size14),
                      contentPadding: EdgeInsets.only(
                          left: AppDismens.size10, right: AppDismens.size20,top: AppDismens.size20,bottom: AppDismens.size20),
                      hintText: hintTitle),

                  onChanged: onChanged,
                ),
              ),
              showRightIcon == false
                  ? Container()
                  : InkWell(
                      onTap: rightIconOnTap,
                      child: Padding(
                        padding: EdgeInsets.only(right: AppDismens.size10),
                        child: Image.asset(
                          "$rightIcon",
                          height: rightIconHeight ?? AppDismens.size20,
                          width: rightIconWidth ?? AppDismens.size20,
                        ),
                      ),
                    )
            ],
          ),
        ),
        SizedBox(
          height:errorText == null ? AppDismens.size10 : 0,
        ),
        if (errorText != null) ...[
          SizedBox(
            height: AppDismens.size10,
          ),
          Padding(
            padding: EdgeInsets.only(left: AppDismens.size10),
            child: Text(
              errorText!,
              style: TextStyle(
                color: AppColors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
