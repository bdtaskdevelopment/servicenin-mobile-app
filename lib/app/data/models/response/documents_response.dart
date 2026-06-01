class DocumentItem {
  final int id;
  final String? category;
  final String? title;
  final String fileUrl;
  final String fileSize;
  final String fileFormat;
  final String? expiryDate;
  final bool isNotify;

  DocumentItem({
    required this.id,
    this.category,
    this.title,
    required this.fileUrl,
    required this.fileSize,
    required this.fileFormat,
    this.expiryDate,
    required this.isNotify,
  });

  String get displayName => title?.isNotEmpty == true
      ? title!
      : fileUrl.split('/').last;
}

class DocumentsResponse {
  final List<DocumentItem> data;
  DocumentsResponse({required this.data});
}

DocumentsResponse documentsResponseFromMap(dynamic json) {
  final list = (json['data'] as List? ?? []);
  return DocumentsResponse(
    data: list.map((e) => DocumentItem(
      id: e['id'] as int,
      category: e['category'] as String?,
      title: e['title'] as String?,
      fileUrl: e['file_url'] as String? ?? '',
      fileSize: e['file_size'] as String? ?? '',
      fileFormat: e['file_format'] as String? ?? '',
      expiryDate: e['expiry_date'] as String?,
      isNotify: e['is_notify'] as bool? ?? false,
    )).toList(),
  );
}
