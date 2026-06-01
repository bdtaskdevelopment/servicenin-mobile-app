import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();
  static final String baseUrl = dotenv.get('BASE_URL', fallback: '');
  static final String imageUrl = dotenv.get('IMAGE_URL', fallback: '');
  // static final String imageUrl = dotenv.get('chat_image_url', fallback: null);
  // static final String appId = dotenv.get('app_id', fallback: null);
  // static final String socketBaseUrl =
  //     dotenv.get('socket_base_url', fallback: null);
  // static final kApiUrl = defaultTargetPlatform == TargetPlatform.android
  //     ? 'http://10.0.2.2:4242'
  //     : 'http://localhost:4242';
  // static String sandboxBaseUrl = dotenv.get('sendBoxPaypalBaseUrl');
  // static String stripBaseUrl = dotenv.get('stripeBaseUrl');
  // static String messageCryptKey = "Sheba@#!404";
}
