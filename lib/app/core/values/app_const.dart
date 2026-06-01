class AppConst {
  AppConst._();
  // String
  static const String success = "success";
  static const String statusCode = "status_code";
  static const String data = "data";
  static const String patientInfo = "patientinfo";
  static const String message = "message";
  static const String allDepartment = "alldepartment";
  static const String doctorList = "doctorlist";
  static const String doctors = "doctors";
  static const String langCodeBn = "bn";
  static const String langCodeEn = "en";
  static const String takaIcon = "৳";
  static const String imgPng = "png";
  static const int statusCodeOne = 1;
  static const int statusCodeZero = 0;
  static const String TAG_BACKUP_FILE = "backup_file";
  static const String TAG_INVOICE = "invoice";
  static const String TAG_PRESCRIPTION = "Prescription";
  static const String TAG_THUMBNAIL = "thumbnail";
  static const String TAG_PROGRESS = "progress";
  static const String TAG_ISDELETE = "isDelete";
  static const String TAG_CALL_ID = "call_id";
  static const String TAG_CALLER_ID = "caller_id";
  static const String TAG_CALL_STATUS = "call_status";
  static const String TAG_CALL_TYPE = "call_type";
  static String CLICK_HERE_TO_JOIN = "CLICK HERE TO JOIN";

  /*Used for Intent and other purpose*/
  static const String TAG_LANGUAGE = "language";
  static const String TAG_LANGUAGE_CODE = "language_code";
  static const String ENGLISH_CODE = "en";
  static const String DEFAULT_LANGUAGE = "English";
  static const String TAG_DEFAULT_LANGUAGE_CODE = ENGLISH_CODE;
  static const String TAG_NOTIFICATION = "notification";
  static const String TAG_FROM = "from";
  static const String TAG_VIDEO = "video";
  static const String TAG_AUDIO = "audio";
  static const String TAG_DOCUMENT = "document";
  static const String TAG_LOCATION = "location";
  static const String TAG_CONTACT = "contact";
  static const String TAG_STORY = "story";
  static const String TAG_SEND = "send";
  static const String TAG_RECEIVE = "receive";
  static const String TAG_CALL_ANSWER = "call_answer";
  static const String POP_UP_WINDOW_PERMISSION = "popup_window_permission";
  static const int OVERLAY_REQUEST_CODE = 303;

  // Table column name:
  static const String TAG_STATUS = "status";
  static String TAG_USER_NAME = "user_name";
  static String TAG_USER_IMAGE = "user_image";
  static String TAG_ABOUT = "about";
  static String TAG_PHONE = "phone";
  static const String TAG_USER_ID = "user_id";
  static String TAG_CONTACT_ID = "contact_id";
  static String TAG_SENDER_ID = "sender_id";
  static String TAG_RECEIVER_ID = "receiver_id";
  static String TAG_RECEIVER_DEVICE_TOKEN = "device_token";
  static String TAG_RECEIVER_APN_TOKEN = "apns_token";
  static String TAG_USER_DEVICE_TOKEN = "user_device_token";
  static String TAG_USER_DEVICE_TYPE = "user_device_type";
  static String TAG_USER_BIO = "user_bio";
  static String TAG_DEVICE_TYPE = "device_type";
  static String TAG_MESSAGE_ID = "message_id";
  static String TAG_MESSAGE_TYPE = "message_type";
  static String TAG_CHAT_TYPE = "chat_type";
  static String TAG_PLATFORM = "platform";
  static String TAG_MESSAGE = "message";
  static String TAG_MESSAGE_DATA = "message_data";
  static String TAG_ATTACHMENT = "attachment";
  static String TAG_LAT = "lat";
  static String TAG_LON = "lon";
  static String TAG_CONTACT_NAME = "contact_name";
  static String TAG_CONTACT_PHONE_NO = "contact_phone_no";
  static String TAG_CONTACT_COUNTRY_CODE = "contact_country_code";
  static String TAG_CHAT_TIME = "chat_time";
  static String TAG_DELIVERY_STATUS = "delivery_status";
  static String TAG_CHAT_ID = "chat_id";
  static String TAG_TYPE = "type";

  static String CALL_TYPE = "created";
  static String CALL_TYPE_END = "ended";
  static String TAG_CREATED_AT = "created_at";
  static String TAG_SINGLE = "single";
  static String TAG_CALL = "call";
  static String TAG_DOCTOR_REQUEST = "doctor_request";
  static String TAG_IS_DELETE = "is_delete";
  static String TAG_STATUS_DATA = "status_data";
  static const String TAG_RECORDING = "recording";
  static int BLUR_RADIUS = 30;
  static const String TAG_SUCCESS = "success";
  static const String TAG_MISSED = "missed";
  static const String TAG_IMAGE = "image";
  static const String TAG_TEXT = "text";
  static const String TAG_TEXT_REPLY = "text_reply";
  static String TAG_NAV_HEIGHT = "nav_height";
  static String TAG_STATUS_HEIGHT = "status_height";

  /*Intent Request Code*/
  static const int CAMERA_REQUEST_CODE = 234;
  static const int GALLERY_REQUEST_CODE = 150;
  static const int REQUEST_PICTURE_CAPTURE = 160;
  static const int DOCS_REQUEST_CODE = 151;
  static const int AUDIO_REQUEST_CODE = 152;
  static const int LOCATION_REQUEST_CODE = 153;
  static const int DEFAULT_REQUEST_CODE = 420;

  static bool isChatOpened = false, isExternalPlay = false;

  static const String TAG_GIF = "gif";
  static const String eventChatBox = "chatbox";
  static const String eventReceiveChat = "receivechat";
  static const String eventOnlineStatus = "onlinestatus";
  static const String eventDoctorJoin = "doctor_join";
  static const String eventDoctorLeave = "doctor_leave";
  static const String eventListenTyping = "listenTyping";
  static const String eventEndChat = "endChat";
  static const String eventViewChat = "viewchat";
  static const String eventOfflineReadStatus = "offlinereadstatus";
  static const String eventOfflineDeliveryStatus = "offlinedeliverystatus";
  static const String eventCallCreated = "callCreated";
  static const String online = "online";
}
