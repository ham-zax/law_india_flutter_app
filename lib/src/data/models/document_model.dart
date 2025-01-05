class Document {
  final String id;
  final String title;
  final String? subtitle;
  final DateTime lastAccessed;
  final String category;
  final List<String> sections;
  final List<DocumentVersion> versions;

  Document({
    required this.id,
    required this.title,
    this.subtitle,
    required this.lastAccessed,
    required this.category,
    required this.sections,
    this.versions = const [],
  });
}

class DocumentVersion {
  final String versionId;
  final DateTime createdAt;
  final String createdBy;
  final String description;

  DocumentVersion({
    required this.versionId,
    required this.createdAt,
    required this.createdBy,
    required this.description,
  });
}
