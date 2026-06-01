import 'package:servicenin/app/core/values/app_colors.dart';
import 'package:servicenin/app/core/values/app_dismens.dart';
import 'package:flutter/material.dart';

class Appbar extends StatelessWidget implements PreferredSizeWidget{
  final Widget? avatar; // Pass any widget (e.g., Image/NetworkImage/Asset.)
  final String title;
  final String subtitle;
  final Widget rewardIcon;
  final String rewardLabel;
  final String rewardValue;
  final String rewardStatus;
  final void Function()? onTapReward ;

  const Appbar({
    Key? key,
    this.avatar,
    this.onTapReward,
    required this.title,
    required this.subtitle,
    required this.rewardIcon,
    required this.rewardLabel,
    required this.rewardValue,
    required this.rewardStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding:  EdgeInsets.symmetric(horizontal: AppDismens.size20),
      child: Row(
        children: [
          // Avatar
          avatar ??
               SizedBox(
                width: AppDismens.size45,
                height: AppDismens.size45,
                child: CircleAvatar(
                  backgroundColor: AppColors.grey,
                  child: Icon(Icons.person, color: AppColors.white),
                ),
              ),
           SizedBox(width:AppDismens.size16),
          // Greeting Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style:  TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppDismens.size16,
                    color: AppColors.black,
                  ),
                ),
                 SizedBox(height: AppDismens.size4),
                Text(
                  subtitle,
                  style:  TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: AppDismens.size11,
                    color: AppColors.blackButton,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Reward Point Card
          InkWell(
            onTap:onTapReward,
            child:Container(
              padding:  EdgeInsets.symmetric( horizontal: AppDismens.size14),
                // decoration: BoxDecoration(
                //   color: AppColors.appBarEarnBack,
                //   borderRadius: BorderRadius.circular(AppDismens.size10),
                // ),
              child: Column(
                children: [
                  Container(

                    // decoration: BoxDecoration(
                    //   color: AppColors.appBarEarnBack,
                    //   borderRadius: BorderRadius.circular(AppDismens.size10),
                    // ),
                    child: Row(

                      children: [
                        rewardIcon,
                        // const SizedBox(width: 8),
                        // Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     // Text(
                        //     //   rewardLabel,
                        //     //   style:  TextStyle(
                        //     //     color: AppColors.headingColor,
                        //     //     fontSize: AppDismens.size12,
                        //     //     fontWeight: FontWeight.w400,
                        //     //   ),
                        //     // ),
                        //     // const SizedBox(height: 1),
                        //     Text(
                        //       rewardValue,
                        //       style:  TextStyle(
                        //         color: AppColors.headingColor,
                        //         fontSize: AppDismens.size15,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                  // Text(
                  //   "STATUS:${rewardStatus}",
                  //   style:  TextStyle(
                  //     color: AppColors.headingColor,
                  //     fontSize: AppDismens.size13,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(74);
}