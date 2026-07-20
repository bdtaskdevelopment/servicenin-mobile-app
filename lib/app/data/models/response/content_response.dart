import 'dart:convert';

import 'package:intl/intl.dart';

dynamic _decode(dynamic src) => src is String ? jsonDecode(src) : src;

String _str(dynamic v) => v?.toString().trim() ?? '';

DateTime? _date(dynamic v) {
  final s = _str(v);
  return s.isEmpty ? null : DateTime.tryParse(s);
}

String _dateLabel(DateTime? dt) {
  final d = dt?.toLocal();
  return d == null ? '' : DateFormat('d MMM yyyy').format(d);
}

/// A category from `/api/v1/works/categories` or `/api/v1/news/categories`
/// (both endpoints return the same shape).
class ContentCategory {
  ContentCategory({required this.id, required this.name});

  final String id;
  final String name;

  factory ContentCategory.fromMap(Map<String, dynamic> json) {
    return ContentCategory(id: _str(json['id']), name: _str(json['name']));
  }

  static List<ContentCategory> listFromResponse(dynamic src) {
    final decoded = _decode(src);
    final list = decoded is Map
        ? (decoded['data'] is List ? decoded['data'] as List : const [])
        : (decoded is List ? decoded : const []);
    return list
        .whereType<Map>()
        .map((e) => ContentCategory.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

/// A video post from `/api/v1/works/posts` ("Our Work"). `thumbnailUrl` is
/// already the fully-resolved poster image (admin upload takes priority over
/// YouTube's auto thumbnail — computed server-side); `videoUrl` is the
/// original link, used to open the video externally.
class WorkPost {
  WorkPost({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.provider,
    required this.videoId,
    required this.thumbnailUrl,
    required this.categoryName,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String provider; // youtube / facebook / unknown
  final String videoId; // YouTube only — empty for facebook/unknown
  final String thumbnailUrl;
  final String categoryName;
  final DateTime? createdAt;

  String get dateLabel => _dateLabel(createdAt);

  /// Whether this post can be played inline with a native YouTube player.
  bool get canPlayInline => provider == 'youtube' && videoId.isNotEmpty;

  factory WorkPost.fromMap(Map<String, dynamic> json) {
    final category = json['category'] is Map ? json['category'] as Map : const {};
    return WorkPost(
      id: _str(json['id']),
      title: _str(json['title']),
      description: _str(json['description']),
      videoUrl: _str(json['video_url']),
      provider: _str(json['provider']).toLowerCase(),
      videoId: _str(json['video_id']),
      thumbnailUrl: _str(json['thumbnail_url']),
      categoryName: _str(category['name']),
      createdAt: _date(json['created_at']),
    );
  }

  static List<WorkPost> listFromResponse(dynamic src) {
    final decoded = _decode(src);
    final list = decoded is Map
        ? (decoded['data'] is List ? decoded['data'] as List : const [])
        : (decoded is List ? decoded : const []);
    return list
        .whereType<Map>()
        .map((e) => WorkPost.fromMap(e.cast<String, dynamic>()))
        .toList();
  }

  static WorkPost? fromResponse(dynamic src) {
    final decoded = _decode(src);
    final data = decoded is Map ? decoded['data'] : null;
    if (data is Map) return WorkPost.fromMap(data.cast<String, dynamic>());
    return null;
  }
}

/// An article from `/api/v1/news/posts` ("Our News").
class NewsPost {
  NewsPost({
    required this.id,
    required this.title,
    required this.body,
    required this.externalUrl,
    required this.thumbnailUrl,
    required this.detailImageUrl,
    required this.categoryName,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String externalUrl;
  final String thumbnailUrl;
  final String detailImageUrl;
  final String categoryName;
  final DateTime? createdAt;

  String get dateLabel => _dateLabel(createdAt);

  /// Plain-text preview of [body] for list cards.
  String get excerpt {
    final plain = body.replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (plain.length <= 130) return plain;
    return '${plain.substring(0, 130).trimRight()}…';
  }

  /// Best image to show — falls back to the list thumbnail if there's no
  /// dedicated detail hero image.
  String get heroImageUrl =>
      detailImageUrl.isNotEmpty ? detailImageUrl : thumbnailUrl;

  factory NewsPost.fromMap(Map<String, dynamic> json) {
    final category = json['category'] is Map ? json['category'] as Map : const {};
    return NewsPost(
      id: _str(json['id']),
      title: _str(json['title']),
      body: _str(json['body']),
      externalUrl: _str(json['external_url']),
      thumbnailUrl: _str(json['thumbnail_url']).isNotEmpty
          ? _str(json['thumbnail_url'])
          : _str(json['image_url']),
      detailImageUrl: _str(json['detail_image_url']),
      categoryName: _str(category['name']),
      createdAt: _date(json['created_at']),
    );
  }

  static List<NewsPost> listFromResponse(dynamic src) {
    final decoded = _decode(src);
    final list = decoded is Map
        ? (decoded['data'] is List ? decoded['data'] as List : const [])
        : (decoded is List ? decoded : const []);
    return list
        .whereType<Map>()
        .map((e) => NewsPost.fromMap(e.cast<String, dynamic>()))
        .toList();
  }

  static NewsPost? fromResponse(dynamic src) {
    final decoded = _decode(src);
    final data = decoded is Map ? decoded['data'] : null;
    if (data is Map) return NewsPost.fromMap(data.cast<String, dynamic>());
    return null;
  }
}
