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
  final List<DocumentChapter> recentChapters;

  const DocumentLoaded({
    required this.recentDocuments,
    required this.categories,
    this.selectedCategory = 'BNS',
    this.documents = const [],
    this.recentChapters = const [],
  });

  DocumentLoaded copyWith({
    List<Document>? recentDocuments,
    List<Document>? documents,
    List<String>? categories,
    String? selectedCategory,
    List<DocumentChapter>? recentChapters,
  }) {
    return DocumentLoaded(
      recentDocuments: recentDocuments ?? this.recentDocuments,
      documents: documents ?? this.documents,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object> get props => [
        recentDocuments,
        documents,
        categories,
        selectedCategory,
        recentChapters,
      ];
}

class DocumentSearchResults extends DocumentState {
  final List<Document> documents;

  const DocumentSearchResults({required this.documents});

  @override
  List<Object> get props => [documents];
}

class DocumentError extends DocumentState {
  final String message;

  const DocumentError({required this.message});

  @override
  List<Object> get props => [message];
}
