class DocumentSection {
  final String sectionNumber;
  final String sectionTitle;
  final String content;

  DocumentSection({
    required this.sectionNumber,
    required this.sectionTitle,
    required this.content,
  });
}

class DocumentChapter {
  final String id;
  final String chapterNumber;
  final String chapterTitle;
  final List<DocumentSection> sections;

  DocumentChapter({
    required this.id,
    required this.chapterNumber,
    required this.chapterTitle,
    required this.sections,
  });
}

class Document {
  final String id;
  final String title;
  final String category;
  final List<DocumentChapter> chapters;

  Document({
    required this.id,
    required this.title,
    required this.category,
    required this.chapters,
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
