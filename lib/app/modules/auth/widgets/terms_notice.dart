import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helpers/app_helper.dart';
import '../../../core/values/app_colors.dart';

const _termsUrl = 'https://servicenin.net/terms';
const _privacyUrl = 'https://servicenin.net/privacy-policy';

/// "By continuing you agree to the Terms and Privacy Policy." with the two
/// links tappable — shown under the primary action on both the login and
/// registration screens.
class TermsNotice extends StatelessWidget {
  const TermsNotice({super.key});

  @override
  Widget build(BuildContext context) {
    // The trailing agreement suffix may begin with a possessive that hugs
    // the "Privacy Policy" link (e.g. the Bangla "র" → নীতির). Colour that
    // hugging part the same orange as the link; keep the rest grey. In
    // English the suffix is just ".", so nothing splits.
    final tail = '.'.tr;
    final sp = tail.indexOf(' ');
    final hug = sp > 0 ? tail.substring(0, sp) : '';
    final tailRest = sp > 0 ? tail.substring(sp) : tail;
    const linkStyle = TextStyle(
        color: AppColors.brandOrange, fontWeight: FontWeight.w600);

    return Center(
      child: Text.rich(
        TextSpan(
          text: 'By continuing you agree to the '.tr,
          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          children: [
            TextSpan(
              text: 'Terms'.tr,
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => Helpers.launchWebsite(_termsUrl),
            ),
            TextSpan(text: ' and '.tr),
            TextSpan(
              text: 'Privacy Policy'.tr,
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => Helpers.launchWebsite(_privacyUrl),
            ),
            if (hug.isNotEmpty)
              TextSpan(
                text: hug,
                style: linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Helpers.launchWebsite(_privacyUrl),
              ),
            TextSpan(text: tailRest),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
