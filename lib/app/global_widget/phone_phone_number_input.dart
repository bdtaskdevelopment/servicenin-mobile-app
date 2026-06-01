import 'package:servicenin/app/core/values/app_dismens.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../core/values/app_colors.dart';


class PhonePhoneNumberInput extends StatelessWidget {
  const PhonePhoneNumberInput({
    super.key,
    this.textController,
    this.onChanged,
    this.contentPadding,
    this.hintText
  });
  final TextEditingController? textController;
  final void Function(PhoneNumber phoneNumber)? onChanged;
  final double? contentPadding;
  final String? hintText ;

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      controller: textController,
      dropdownIconPosition: IconPosition.trailing,
      flagsButtonPadding: const EdgeInsets.symmetric(horizontal: 10),
      // style: TextStyle(fontSize: 35),
      //dropdownTextStyle: inputTextStyle,
      keyboardType: TextInputType.phone,
      //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(

        contentPadding: EdgeInsets.symmetric(vertical: contentPadding ?? 20),
        counterText: "",
        filled: true,
        hintText: hintText,
        //hintStyle: hintTextStyle,
        fillColor: AppColors.inputBackground,

        border:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDismens.size14),
          borderSide: BorderSide.none,
        ),
        enabledBorder:  OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDismens.size14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDismens.size14,),
          borderSide: BorderSide(
            color: AppColors.appColor, // <-- Focused border color
            width: 1,           // <-- Border thickness
          ),),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDismens.size14),
            borderSide: BorderSide.none),
      ),
      showCountryFlag: true,
      initialCountryCode: 'BD',
      onChanged: onChanged,
    );
  }
}
