import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/document_repository.dart';
import '../../data/models/document_model.dart';

part 'document_event.dart';
part 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final DocumentRepository repository;

  DocumentBloc({required this.repository}) : super(DocumentInitial()) {
    on<LoadDocuments>(_onLoadDocuments);
    on<SearchDocuments>(_onSearchDocuments);
    on<UpdateDocument>(_onUpdateDocument);
    on<ChangeCategory>(_onChangeCategory);
    on<SectionViewed>(_onSectionViewed); // Add this line
  }

  Future<void> _onLoadDocuments(
    LoadDocuments event,
    Emitter<DocumentState> emit,
  ) async {
    emit(DocumentLoading());
    try {
      final recentDocs = await repository.getRecentDocuments();
      final categories = await repository.getCategories();
      final initialCategory = categories.first;
      final documents =
          await repository.getDocumentsByCategory(initialCategory);
      emit(DocumentLoaded(
        recentDocuments: recentDocs,
        categories: categories,
        selectedCategory: initialCategory,
        documents: documents,
      ));
    } catch (e) {
      emit(DocumentError(message: e.toString()));
    }
  }

  Future<void> _onSearchDocuments(
    SearchDocuments event,
    Emitter<DocumentState> emit,
  ) async {
    emit(DocumentLoading());
    try {
      final documents = await repository.searchDocuments(event.query);
      // Get the cached results from repository
      final results = repository._searchCache[event.query] ?? [];
      emit(DocumentSearchResults(results: results));
    } catch (e) {
      emit(DocumentError(message: e.toString()));
    }
  }

  Future<void> _onUpdateDocument(
    UpdateDocument event,
    Emitter<DocumentState> emit,
  ) async {
    try {
      await repository.updateDocument(event.document);
      add(LoadDocuments());
    } catch (e) {
      emit(DocumentError(message: e.toString()));
    }
  }

  Future<void> _onChangeCategory(
    ChangeCategory event,
    Emitter<DocumentState> emit,
  ) async {
    if (state is DocumentLoaded) {
      final currentState = state as DocumentLoaded;
      emit(DocumentLoading());
      try {
        final documents =
            await repository.getDocumentsByCategory(event.category);
        emit(currentState.copyWith(
          selectedCategory: event.category,
          documents: documents,
        ));
      } catch (e) {
        emit(DocumentError(message: e.toString()));
      }
    }
  }

  void _onSectionViewed(
    SectionViewed event,
    Emitter<DocumentState> emit,
  ) {
    if (state is DocumentLoaded) {
      final currentState = state as DocumentLoaded;

      // Create new section record
      final newSection = (
        chapter: event.chapter,
        section: event.section,
      );

      // Remove only exact duplicate sections (same chapter AND section number)
      var updatedSections = currentState.recentSections
          .where((s) => !(s.chapter.id == event.chapter.id &&
              s.section.sectionNumber == event.section.sectionNumber))
          .toList();

      // Add new section at start
      updatedSections.insert(0, newSection);

      // Limit to 7 most recent sections
      updatedSections = updatedSections.take(7).toList();

      // Emit new state
      emit(currentState.copyWith(
        recentSections: updatedSections,
      ));
    }
  }
}

extension FindChapterById on DocumentLoaded {
  DocumentChapter? findChapterById(String chapterId) {
    for (final document in documents) {
      for (final chapter in document.chapters) {
        if (chapter.id == chapterId) {
          return chapter;
        }
      }
    }
    return null;
  }
}
