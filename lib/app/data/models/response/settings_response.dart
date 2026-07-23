/// Typed view over `/api/v1/settings`. The backend returns every value as a
/// string, so parsing coerces to bool/num where appropriate. Defaults match a
/// sane offline fallback so the app works before the first fetch.
class AppSettings {
  const AppSettings({
    this.servicesVatEnabled = true,
    this.servicesVatRate = 5,
    this.currencySymbol = '৳',
    this.currencyCode = 'BDT',
    this.sslcommerzStoreId = '',
    this.sslcommerzStorePassword = '',
    this.sslcommerzIsLive = false,
    this.paymentCashEnabled = true,
    this.paymentSslcommerzEnabled = true,
    this.paymentBkashEnabled = false,
    this.paymentNagadEnabled = false,
    this.paymentCardEnabled = false,
    this.maintenanceMode = false,
    this.maintenanceMessage = '',
    this.maintenanceMessageBn = '',
    this.contactPhone = '',
    this.contactEmail = '',
    this.contactWebsite = '',
    this.contactAddress = '',
    this.contactHours = '',
    this.termsContent = '',
    this.privacyContent = '',
    this.appName = 'ServiceNin',
    this.appVersion = '',
    this.minAppVersion = '',
    this.mapApiKey = '',
  });

  // Services / VAT
  final bool servicesVatEnabled;
  final double servicesVatRate; // percent, e.g. 5 → 5%

  // Currency
  final String currencySymbol;
  final String currencyCode;

  // SSLCommerz gateway credentials
  final String sslcommerzStoreId;
  final String sslcommerzStorePassword;
  final bool sslcommerzIsLive;

  // Payment-method toggles
  final bool paymentCashEnabled;
  final bool paymentSslcommerzEnabled;
  final bool paymentBkashEnabled;
  final bool paymentNagadEnabled;
  final bool paymentCardEnabled;

  // Maintenance
  final bool maintenanceMode;
  final String maintenanceMessage;
  final String maintenanceMessageBn;

  // Contact / app info
  final String contactPhone;
  final String contactEmail;
  final String contactWebsite;
  final String contactAddress;
  final String contactHours;
  final String termsContent;
  final String privacyContent;
  final String appName;
  final String appVersion;
  final String minAppVersion;

  // Google Maps API key (Places + Directions), configured server-side
  // under the "map" settings group.
  final String mapApiKey;

  /// VAT as a fraction for math (0.05), honouring the enabled flag.
  double get vatFraction => servicesVatEnabled ? servicesVatRate / 100.0 : 0.0;

  static bool _bool(Map d, String key, bool fallback) {
    final v = d[key]?.toString().trim().toLowerCase();
    if (v == null || v.isEmpty) return fallback;
    return v == 'true' || v == '1' || v == 'yes';
  }

  static double _num(Map d, String key, double fallback) =>
      double.tryParse('${d[key]}') ?? fallback;

  static String _str(Map d, String key, [String fallback = '']) {
    final v = d[key];
    return (v == null) ? fallback : v.toString();
  }

  factory AppSettings.fromMap(Map data) => AppSettings(
        servicesVatEnabled: _bool(data, 'services_vat_enabled', true),
        servicesVatRate: _num(data, 'services_vat_rate', 5),
        currencySymbol: _str(data, 'currency_symbol', '৳'),
        currencyCode: _str(data, 'currency_code', 'BDT'),
        sslcommerzStoreId: _str(data, 'sslcommerz_store_id'),
        sslcommerzStorePassword: _str(data, 'sslcommerz_store_password'),
        sslcommerzIsLive: _bool(data, 'sslcommerz_is_live', false),
        paymentCashEnabled: _bool(data, 'payment_cash_enabled', true),
        paymentSslcommerzEnabled:
            _bool(data, 'payment_sslcommerz_enabled', true),
        paymentBkashEnabled: _bool(data, 'payment_bkash_enabled', false),
        paymentNagadEnabled: _bool(data, 'payment_nagad_enabled', false),
        paymentCardEnabled: _bool(data, 'payment_card_enabled', false),
        maintenanceMode: _bool(data, 'maintenance_mode', false),
        maintenanceMessage: _str(data, 'maintenance_message'),
        maintenanceMessageBn: _str(data, 'maintenance_message_bn'),
        contactPhone: _str(data, 'contact_phone'),
        contactEmail: _str(data, 'contact_email'),
        contactWebsite: _str(data, 'contact_website'),
        contactAddress: _str(data, 'contact_address'),
        contactHours: _str(data, 'contact_hours'),
        termsContent: _str(data, 'terms_content'),
        privacyContent: _str(data, 'privacy_content'),
        appName: _str(data, 'app_name', 'ServiceNin'),
        appVersion: _str(data, 'app_version'),
        minAppVersion: _str(data, 'min_app_version'),
        mapApiKey: _str(data, 'map_api_key'),
      );
}
