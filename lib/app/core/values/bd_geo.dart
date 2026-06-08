import 'package:latlong2/latlong.dart';

/// Approximate coordinates for Bangladesh divisions/districts so the ambulance
/// map can drop pickup & destination pins from names alone (the locations API
/// returns names only). Coordinates are district-centre approximations — good
/// enough for a preview map, not for navigation.
class BdGeo {
  BdGeo._();

  /// Geographic centre of Bangladesh — last-resort fallback.
  static const LatLng country = LatLng(23.6850, 90.3563);

  static const Map<String, LatLng> _districts = {
    // Dhaka
    'Dhaka': LatLng(23.8103, 90.4125),
    'Faridpur': LatLng(23.6070, 89.8429),
    'Gazipur': LatLng(24.0023, 90.4264),
    'Gopalganj': LatLng(23.0050, 89.8266),
    'Kishoreganj': LatLng(24.4449, 90.7766),
    'Madaripur': LatLng(23.1641, 90.1897),
    'Manikganj': LatLng(23.8617, 90.0003),
    'Munshiganj': LatLng(23.5422, 90.5305),
    'Narayanganj': LatLng(23.6238, 90.4990),
    'Narsingdi': LatLng(23.9322, 90.7150),
    'Rajbari': LatLng(23.7574, 89.6446),
    'Shariatpur': LatLng(23.2423, 90.4348),
    'Tangail': LatLng(24.2513, 89.9167),
    // Chattogram
    'Chattogram': LatLng(22.3569, 91.7832),
    "Cox's Bazar": LatLng(21.4395, 92.0050),
    'Cumilla': LatLng(23.4607, 91.1809),
    'Brahmanbaria': LatLng(23.9571, 91.1119),
    'Chandpur': LatLng(23.2333, 90.6712),
    'Feni': LatLng(23.0159, 91.3976),
    'Khagrachhari': LatLng(23.1193, 91.9847),
    'Lakshmipur': LatLng(22.9447, 90.8418),
    'Noakhali': LatLng(22.8696, 91.0995),
    'Rangamati': LatLng(22.6533, 92.1750),
    'Bandarban': LatLng(22.1953, 92.2184),
    // Rajshahi
    'Rajshahi': LatLng(24.3636, 88.6241),
    'Bogura': LatLng(24.8466, 89.3776),
    'Joypurhat': LatLng(25.0968, 89.0227),
    'Naogaon': LatLng(24.7936, 88.9318),
    'Natore': LatLng(24.4206, 89.0001),
    'Chapainawabganj': LatLng(24.5965, 88.2776),
    'Pabna': LatLng(24.0064, 89.2372),
    'Sirajganj': LatLng(24.4534, 89.7006),
    // Khulna
    'Khulna': LatLng(22.8456, 89.5403),
    'Bagerhat': LatLng(22.6516, 89.7859),
    'Chuadanga': LatLng(23.6402, 88.8418),
    'Jashore': LatLng(23.1667, 89.2167),
    'Jhenaidah': LatLng(23.5449, 89.1726),
    'Kushtia': LatLng(23.9013, 89.1206),
    'Magura': LatLng(23.4855, 89.4198),
    'Meherpur': LatLng(23.7622, 88.6318),
    'Narail': LatLng(23.1728, 89.5126),
    'Satkhira': LatLng(22.7185, 89.0705),
    // Barishal
    'Barishal': LatLng(22.7010, 90.3535),
    'Barguna': LatLng(22.0953, 90.1121),
    'Bhola': LatLng(22.6859, 90.6482),
    'Jhalokati': LatLng(22.6406, 90.1987),
    'Patuakhali': LatLng(22.3596, 90.3299),
    'Pirojpur': LatLng(22.5841, 89.9720),
    // Sylhet
    'Sylhet': LatLng(24.8949, 91.8687),
    'Habiganj': LatLng(24.3745, 91.4155),
    'Moulvibazar': LatLng(24.4829, 91.7774),
    'Sunamganj': LatLng(25.0658, 91.3950),
    // Rangpur
    'Rangpur': LatLng(25.7439, 89.2752),
    'Dinajpur': LatLng(25.6217, 88.6354),
    'Gaibandha': LatLng(25.3288, 89.5283),
    'Kurigram': LatLng(25.8054, 89.6362),
    'Lalmonirhat': LatLng(25.9923, 89.2847),
    'Nilphamari': LatLng(25.9310, 88.8560),
    'Panchagarh': LatLng(26.3411, 88.5542),
    'Thakurgaon': LatLng(26.0337, 88.4616),
    // Mymensingh
    'Mymensingh': LatLng(24.7471, 90.4203),
    'Jamalpur': LatLng(24.9375, 89.9372),
    'Netrokona': LatLng(24.8709, 90.7279),
    'Sherpur': LatLng(25.0205, 90.0153),
  };

  static const Map<String, LatLng> _divisions = {
    'Dhaka': LatLng(23.8103, 90.4125),
    'Chattogram': LatLng(22.3569, 91.7832),
    'Rajshahi': LatLng(24.3636, 88.6241),
    'Khulna': LatLng(22.8456, 89.5403),
    'Barishal': LatLng(22.7010, 90.3535),
    'Sylhet': LatLng(24.8949, 91.8687),
    'Rangpur': LatLng(25.7439, 89.2752),
    'Mymensingh': LatLng(24.7471, 90.4203),
  };

  /// Best-effort coordinate for a district (falls back to its division centre,
  /// then the country centre).
  static LatLng point(String district, [String division = '']) {
    return _districts[district.trim()] ??
        _divisions[division.trim()] ??
        country;
  }
}
