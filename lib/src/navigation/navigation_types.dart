import '../data/models/document_model.dart';

class DocumentDetailArguments {
  final Document? document;
  final DocumentChapter? chapter;
  final String? scrollToSectionId;

  DocumentDetailArguments({
    this.document,
    this.chapter,
    this.scrollToSectionId,
  }) : assert(document != null || chapter != null);
}
