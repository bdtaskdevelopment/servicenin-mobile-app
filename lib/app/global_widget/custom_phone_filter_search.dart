import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/values/app_assets.dart';
import '../core/values/app_colors.dart';
import '../core/values/app_dismens.dart';

class CustomPhoneFilterSearch extends StatelessWidget {
  const CustomPhoneFilterSearch(
      {super.key,
      this.onTap,
      this.showFilter = true,
      this.title,
      this.hintTitle,
      this.onChanged,
      this.controller});

  final void Function()? onTap;
  final bool? showFilter;
  final String? title;
  final String? hintTitle;
  final TextEditingController? controller;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey.withValues(alpha: 0.5),
                    spreadRadius: 1,
                    blurRadius: 0,
                    offset: Offset(0, 0), // changes position of shadow
                  ),
                ],
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDismens.size10)),
            width: Get.width,
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              controller: controller,
              cursorColor: AppColors.black,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintStyle: TextStyle(color: AppColors.hash),
                contentPadding: EdgeInsets.only(
                    left: AppDismens.size10, right: AppDismens.size20),
                prefixIcon: SizedBox(
                  height: AppDismens.size24,
                  width: AppDismens.size24,
                  child: Center(
                    // child: Image.asset(
                    //   AppAssets.search,
                    //   height: AppDismens.size24,
                    //   width: AppDismens.size24,
                    // ),
                  ),
                ),
                hintText: title ?? "Search here".tr,
              ),
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: showFilter == false ? 0 : AppDismens.size10,
        ),
        showFilter == false
            ? Container()
            : InkWell(
                onTap: onTap,
                child: Container(
                  height: AppDismens.size45,
                  width: AppDismens.size45,
                  decoration: BoxDecoration(
                      color: AppColors.bottomNavBack,
                      borderRadius: BorderRadius.circular(AppDismens.size10)),
                  child: Center(
                    // child: Image.asset(
                    //   AppAssets.filter,
                    //   height: AppDismens.size20,
                    //   width: AppDismens.size20,
                    // ),
                  ),
                ),
              ),
      ],
    );
  }
}
