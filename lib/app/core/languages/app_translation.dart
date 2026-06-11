import 'sn_strings.dart';

abstract class AppTranslation {
  /// Locale keys match the `Locale(languageCode)` used in [GetMaterialApp]:
  /// `en` (English source text, empty map → falls back to the key) and `bn`
  /// (Bangla translations keyed by the English source text).
  static Map<String, Map<String, String>> translationsKeys = {
    'en': snEn,
    'bn': snBn,
  };
}
