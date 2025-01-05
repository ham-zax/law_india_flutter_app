class DocumentSection {
  final String chapterNumber;
  final String sectionTitle;
  final String content;

  DocumentSection({
    required this.chapterNumber,
    required this.sectionTitle,
    required this.content,
  });
}

class Document {
  final String id;
  final String title;
  final String category;
  final List<DocumentSection> sections;

  Document({
    required this.id,
    required this.title,
    required this.category,
    required this.sections,
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
