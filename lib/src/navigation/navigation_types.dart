import '../data/models/document_model.dart';

class DocumentDetailArguments {
  final Document? document;
  final DocumentChapter? chapter;
  final String? scrollToSectionId;

  const DocumentDetailArguments({
    this.document,
    this.chapter,
    this.scrollToSectionId,
  }) : assert(document != null || chapter != null, 
         'Either document or chapter must be provided');

  // Factory constructor to handle legacy Map arguments
  factory DocumentDetailArguments.fromMap(Map<String, dynamic> args) {
    return DocumentDetailArguments(
      chapter: args['chapter'] as DocumentChapter?,
      scrollToSectionId: args['scrollToSectionId'] as String?,
    );
  }
}
