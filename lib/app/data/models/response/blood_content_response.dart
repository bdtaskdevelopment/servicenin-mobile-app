import 'dart:convert';

import 'package:intl/intl.dart';

dynamic _decode(dynamic src) => src is String ? jsonDecode(src) : src;

/// A blog post from `/api/v1/blood/articles`. The API returns the full
/// [body] on both the list and detail endpoints (there's no separate
/// summary field), so [excerpt] trims it down for list cards.
class BloodArticle {
  BloodArticle({
    required this.id,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.videoUrl,
    required this.isActive,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String imageUrl;
  final String videoUrl;
  final bool isActive;
  final DateTime? createdAt;

  /// Plain-text preview of [body] for list cards.
  String get excerpt {
    final plain = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (plain.length <= 130) return plain;
    return '${plain.substring(0, 130).trimRight()}…';
  }

  /// "12 Jul 2026" style label from [createdAt].
  String get dateLabel {
    final dt = createdAt?.toLocal();
    return dt == null ? '' : DateFormat('d MMM yyyy').format(dt);
  }

  factory BloodArticle.fromMap(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString().trim() ?? '';
    DateTime? date(dynamic v) {
      final s = str(v);
      return s.isEmpty ? null : DateTime.tryParse(s);
    }

    return BloodArticle(
      id: str(json['id']),
      title: str(json['title']),
      body: str(json['body']),
      imageUrl: str(json['image_url']),
      videoUrl: str(json['video_url']),
      isActive: json['is_active'] == true,
      createdAt: date(json['created_at']),
    );
  }

  /// Parses a bare array or `{ success, message, data: [...] }`.
  static List<BloodArticle> listFromResponse(dynamic src) {
    final decoded = _decode(src);
    final list = decoded is Map
        ? (decoded['data'] is List ? decoded['data'] as List : const [])
        : (decoded is List ? decoded : const []);
    return list
        .whereType<Map>()
        .map((e) => BloodArticle.fromMap(e.cast<String, dynamic>()))
        .toList();
  }

  /// Parses `{ success, message, data: {...} }` for the detail endpoint.
  static BloodArticle? fromResponse(dynamic src) {
    final decoded = _decode(src);
    final data = decoded is Map ? decoded['data'] : null;
    if (data is Map) return BloodArticle.fromMap(data.cast<String, dynamic>());
    return null;
  }
}

/// An FAQ entry from `/api/v1/blood/faqs`. The API has no per-item detail
/// route — [answer] is already the full text in the list response.
class BloodFaq {
  BloodFaq({
    required this.id,
    required this.question,
    required this.answer,
    required this.imageUrl,
    required this.videoUrl,
    required this.isActive,
  });

  final String id;
  final String question;
  final String answer;
  final String imageUrl;
  final String videoUrl;
  final bool isActive;

  factory BloodFaq.fromMap(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString().trim() ?? '';
    return BloodFaq(
      id: str(json['id']),
      question: str(json['question']),
      answer: str(json['answer']),
      imageUrl: str(json['image_url']),
      videoUrl: str(json['video_url']),
      isActive: json['is_active'] == true,
    );
  }

  static List<BloodFaq> listFromResponse(dynamic src) {
    final decoded = _decode(src);
    final list = decoded is Map
        ? (decoded['data'] is List ? decoded['data'] as List : const [])
        : (decoded is List ? decoded : const []);
    return list
        .whereType<Map>()
        .map((e) => BloodFaq.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}
