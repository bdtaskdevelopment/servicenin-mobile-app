class NotificationResponse {
  final List<NotificationItem> data;
  NotificationResponse({required this.data});
  factory NotificationResponse.fromMap(Map<String, dynamic> m) => NotificationResponse(
        data: (m['data'] as List).map((e) => NotificationItem.fromMap(e)).toList(),
      );
}

NotificationResponse notificationResponseFromMap(Map<String, dynamic> m) =>
    NotificationResponse.fromMap(m);

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type;
  bool isRead;
  final String time;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.time,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> m) => NotificationItem(
        id: m['id']?.toString() ?? '',
        title: m['title'] ?? '',
        message: m['message'] ?? '',
        type: m['type'] ?? '',
        isRead: m['is_read'] == true,
        time: m['time'] ?? '',
      );
}
