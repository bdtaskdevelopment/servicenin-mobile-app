import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/values/app_colors.dart';
import '../core/values/app_dismens.dart';


class CustomPhoneDropdown extends StatelessWidget {
  const CustomPhoneDropdown(
      {super.key,
      required this.valueChanged,
      required this.value,
      required this.itemList,
      this.imageString,
      this.dropIconColor,
      this.hintText});

  final List itemList;
  final ValueChanged<String> valueChanged;
  final String? value;
  final String? hintText;
  final String? imageString;
  final Color? dropIconColor;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDismens.size10),
          // border: Border.all(
          //   width: 1,
          //   color: Get.theme.textTheme.bodyLarge!.color!.withOpacity(0.1),
          // ),
        ),
        child: Row(
          children: [
            Expanded(
              child: DropdownButton2<String>(
                isExpanded: true,
                //dropdownMaxHeight: Get.height * 0.5,
                //buttonHeight: 50,

                hint: Text(
                  hintText ?? "Select",
                  style: TextStyle(
                    color: AppColors.hintTextColor,
                    fontSize: AppDismens.size12,
                  ),
                ),

                onChanged: (newValue) {
                  valueChanged(newValue!);
                },
                valueListenable: ValueNotifier<String?>(value),
                items: itemList
                    .expand(
                      (item) => [
                        DropdownItem(
                          value: item.toString(),
                          child: Text(
                            item ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Get.textTheme.bodyMedium,
                          ),
                        )
                      ],
                    )
                    .toList(),
                iconStyleData: IconStyleData(
                  icon: Padding(
                    padding: EdgeInsets.only(right: AppDismens.size10),
                    child: Icon(
                      Icons.arrow_drop_down_outlined,
                      color: dropIconColor ?? AppColors.grey,
                    ),
                  ),
                  iconSize: 18,
                ),
              ),
            ),
            imageString != null
                ? Container(
                    padding: EdgeInsets.only(right: AppDismens.size10),
                    height: AppDismens.size30,
                    width: AppDismens.size30,
                    child: Center(
                      child: Image.asset(
                        "$imageString",
                        height: AppDismens.size30,
                        width: AppDismens.size30,
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
