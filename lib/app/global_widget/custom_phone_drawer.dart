import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/values/app_colors.dart';
import '../core/values/app_dismens.dart';


class CustomPhoneDrawer extends StatelessWidget {
  const CustomPhoneDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
          //height: Get.height,
          decoration: BoxDecoration(color: AppColors.white),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        AppColors.appColor,
                        AppColors.appColor,
                      ],
                      begin: const FractionalOffset(0.0, 2.0),
                      end: const FractionalOffset(0.0, 0.0),
                      // stops: [0.0, 1.0],
                      tileMode: TileMode.mirror),
                ),
                height: AppDismens.size190,
                width: Get.width,
                padding: EdgeInsets.symmetric(horizontal: AppDismens.size20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                  ],
                ),
              ),

              SizedBox(
                height: AppDismens.size5,
              ),
            ],
          ),
        ),
      );
  }
}
