import 'package:servicenin/app/core/values/app_colors.dart';
import 'package:flutter/material.dart';

class CustomPhoneButton extends StatefulWidget {
  const CustomPhoneButton({
    Key? key,
    this.width,
    this.height,
    this.titleSize,
    this.title,
    this.onTap,
    this.btnBackground,
    this.focusColor,
    this.buttonIcon,
    this.borderColor,
    this.showLoading,
    this.showButtonIcon = false,
    this.textColor,
    this.textStyle,
    this.gradientColors,
    this.shadowColor,
  }) : super(key: key);

  final double? width;
  final double? height;
  final double? titleSize;
  final String? title;
  final void Function()? onTap;
  final Color? btnBackground;
  final Color? focusColor; // Optional, not used in static gradient, but remains for API compatibility
  final Color? borderColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final String? buttonIcon;
  final bool? showButtonIcon;
  final bool? showLoading;
  final List<Color>? gradientColors;
  final Color? shadowColor; // NEW: allows custom shadow color

  @override
  State<CustomPhoneButton> createState() => _CustomPhoneButtonState();
}

class _CustomPhoneButtonState extends State<CustomPhoneButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final txtColor = widget.textColor ?? AppColors.white;
    final gradientColors = widget.gradientColors ??
        (widget.btnBackground != null
            ? [widget.btnBackground!, widget.btnBackground!]
            : [AppColors.appColor, AppColors.appColorCo2, AppColors.hardGreen]);
    final shadowColor = widget.shadowColor ?? gradientColors.last.withOpacity(0.45);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          width: widget.width ?? 280,
          height: widget.height ?? 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            border: Border.all(
                color: widget.borderColor ?? gradientColors.first, width: 1),
            boxShadow: _isPressed
                ? [
              BoxShadow(
                color: shadowColor,
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              )
            ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showButtonIcon == true && widget.buttonIcon != null)
                ...[
                  Image.asset(
                    widget.buttonIcon!,
                    width: 20,
                    height: 20,
                    color: txtColor,
                  ),
                  const SizedBox(width: 10),
                ],
              if (widget.showLoading == true)
                CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                )
              else
                Text(
                  widget.title ?? '',
                  style: widget.textStyle ??
                      TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: widget.titleSize ?? 16,
                        color: txtColor,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}