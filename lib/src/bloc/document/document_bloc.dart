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
    on<ChapterViewed>(_onChapterViewed);
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
      final documents = await repository.getDocumentsByCategory(initialCategory);
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
      final results = await repository.searchDocuments(event.query);
      emit(DocumentSearchResults(documents: results));
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
        final documents = await repository.getDocumentsByCategory(event.category);
        emit(currentState.copyWith(
          selectedCategory: event.category,
          documents: documents,
        ));
      } catch (e) {
        emit(DocumentError(message: e.toString()));
      }
    }
  }

  void _onChapterViewed(
    ChapterViewed event,
    Emitter<DocumentState> emit,
  ) {
    if (state is DocumentLoaded) {
      final currentState = state as DocumentLoaded;
      
      // Remove if already exists to avoid duplicates
      final updatedChapters = currentState.recentChapters
        .where((c) => c.chapterNumber != event.chapter.chapterNumber)
        .toList();
      
      // Add to beginning of list
      updatedChapters.insert(0, event.chapter);
      
      // Keep only last 3 chapters
      final recentChapters = updatedChapters.take(3).toList();
      
      emit(currentState.copyWith(
        recentChapters: recentChapters,
      ));
    }
  }
}
