import 'dart:convert';

NoticeResponse noticeResponseFromMap(dynamic src) =>
    NoticeResponse.fromMap(src is String ? jsonDecode(src) : src as Map<String, dynamic>);

class NoticeResponse {
  final bool status;
  final String message;
  final List<NoticeItem> data;

  NoticeResponse({required this.status, required this.message, required this.data});

  factory NoticeResponse.fromMap(Map<String, dynamic> json) => NoticeResponse(
        status: json['status'] == true,
        message: json['message'] ?? '',
        data: (json['data'] as List? ?? []).map((e) => NoticeItem.fromMap(e)).toList(),
      );
}

class NoticeItem {
  final int id;
  final String title;
  final String details;
  final String publishedDate;
  final String validDate;
  final String? attachment;

  NoticeItem({
    required this.id,
    required this.title,
    required this.details,
    required this.publishedDate,
    required this.validDate,
    this.attachment,
  });

  String get plainDetails => details
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&#39;', "'")
      .replaceAll('&quot;', '"')
      .trim();

  factory NoticeItem.fromMap(Map<String, dynamic> json) => NoticeItem(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        details: json['details'] ?? '',
        publishedDate: json['published_date'] ?? '',
        validDate: json['valid_date'] ?? '',
        attachment: json['attachment']?.toString(),
      );
}
