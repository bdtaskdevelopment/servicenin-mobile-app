import 'dart:convert';

import 'package:intl/intl.dart';

dynamic _decode(dynamic src) => src is String ? jsonDecode(src) : src;

/// A single chat message from `/api/v1/blood/fulfillments/:id/chat`.
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.fulfillmentId,
    required this.senderId,
    required this.message,
    required this.isRead,
    this.createdAt,
    this.senderName = '',
    this.senderPhoto,
  });

  final String id;
  final String fulfillmentId;
  final String senderId;
  final String message;
  final bool isRead;
  final DateTime? createdAt;
  final String senderName;
  final String? senderPhoto;

  String get timeLabel {
    final dt = createdAt?.toLocal();
    return dt == null ? '' : DateFormat('h:mm a').format(dt);
  }

  factory ChatMessage.fromMap(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString().trim() ?? '';
    final sender = json['sender'] is Map ? json['sender'] as Map : const {};
    final profile = sender['profile'] is Map ? sender['profile'] as Map : const {};
    final created = str(json['created_at']);
    final photo = str(profile['photo_url']);
    return ChatMessage(
      id: str(json['id']),
      fulfillmentId: str(json['fulfillment_id']),
      senderId: str(json['sender_id']),
      message: str(json['message']),
      isRead: json['is_read'] == true,
      createdAt: created.isEmpty ? null : DateTime.tryParse(created),
      senderName: str(profile['full_name']),
      senderPhoto: photo.isEmpty ? null : photo,
    );
  }

  /// Parses a bare array or `{ success, message, data: [...] }`.
  static List<ChatMessage> listFromResponse(dynamic src) {
    final decoded = _decode(src);
    final list = decoded is Map
        ? (decoded['data'] is List ? decoded['data'] as List : const [])
        : (decoded is List ? decoded : const []);
    return list
        .whereType<Map>()
        .map((e) => ChatMessage.fromMap(e.cast<String, dynamic>()))
        .toList();
  }

  /// Parses the single-message envelope `{ success, message, data }`.
  static ChatMessage fromResponse(dynamic src) {
    final decoded = _decode(src);
    final data = decoded is Map && decoded['data'] is Map
        ? decoded['data'] as Map
        : decoded as Map;
    return ChatMessage.fromMap(data.cast<String, dynamic>());
  }
}
