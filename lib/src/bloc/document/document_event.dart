part of 'document_bloc.dart';

abstract class DocumentEvent extends Equatable {
  const DocumentEvent();

  @override
  List<Object> get props => [];
}

class LoadDocuments extends DocumentEvent {}

class SearchDocuments extends DocumentEvent {
  final String query;

  const SearchDocuments(this.query);

  @override
  List<Object> get props => [query];
}

class UpdateDocument extends DocumentEvent {
  final Document document;

  const UpdateDocument(this.document);

  @override
  List<Object> get props => [document];
}

class ChangeCategory extends DocumentEvent {
  final String category;

  const ChangeCategory(this.category);

  @override
  List<Object> get props => [category];
}

class SectionViewed extends DocumentEvent {
  final DocumentChapter chapter;
  final DocumentSection section;

  const SectionViewed(this.chapter, this.section);

  @override
  List<Object> get props => [chapter, section];
}
