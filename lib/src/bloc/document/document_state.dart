part of 'document_bloc.dart';

abstract class DocumentState extends Equatable {
  const DocumentState();

  @override
  List<Object> get props => [];
}

class DocumentInitial extends DocumentState {}

class DocumentLoading extends DocumentState {}

class DocumentLoaded extends DocumentState {
  final List<Document> recentDocuments;
  final List<Document> documents;
  final List<String> categories;
  final String selectedCategory;
  final List<({DocumentChapter chapter, DocumentSection section})> recentSections;

  const DocumentLoaded({
    required this.recentDocuments,
    required this.categories,
    this.selectedCategory = 'BNS',
    this.documents = const [],
    this.recentSections = const [],
  });

  DocumentLoaded copyWith({
    List<Document>? recentDocuments,
    List<Document>? documents,
    List<String>? categories,
    String? selectedCategory,
    List<({DocumentChapter chapter, DocumentSection section})>? recentSections,
  }) {
    return DocumentLoaded(
      recentDocuments: recentDocuments ?? this.recentDocuments,
      documents: documents ?? this.documents,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      recentSections: recentSections ?? this.recentSections,
    );
  }


  @override
  List<Object> get props => [
        recentDocuments,
        documents,
        categories,
        selectedCategory,
        recentSections,
      ];
}

class DocumentSearchResults extends DocumentState {
  final List<SearchResult> results;

  const DocumentSearchResults({required this.results});

  List<Document> get documents => results
      .map((result) => result.document)
      .toSet()
      .toList();

  @override
  List<Object> get props => [results];
}

class DocumentError extends DocumentState {
  final String message;

  const DocumentError({required this.message});

  @override
  List<Object> get props => [message];
}
