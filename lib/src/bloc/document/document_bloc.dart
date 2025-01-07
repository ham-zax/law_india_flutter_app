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

      // Debug - Initial State
      print('=== START: Section Viewed Event ===');
      print('Viewing Chapter ID: ${event.chapter.id}');
      print('Viewing Section Number: ${event.section.sectionNumber}');
      print('\nCurrent Recent Sections:');
      currentState.recentSections.forEach((s) => print(
          'Chapter ID: ${s.chapter.id}, Section: ${s.section.sectionNumber}'));

      // Create new section record
      final newSection = (
        chapter: event.chapter,
        section: event.section,
      );

      // Create fresh list for modification
      var updatedSections =
          List<({DocumentChapter chapter, DocumentSection section})>.from(
              currentState.recentSections);

      print('\nProcessing Updates:');

      // Check for exact same section
      final exactMatchIndex = updatedSections.indexWhere((s) =>
          s.chapter.id == event.chapter.id &&
          s.section.sectionNumber == event.section.sectionNumber);

      print('Exact match found at index: $exactMatchIndex');

      if (exactMatchIndex != -1) {
        print('Removing existing section at index: $exactMatchIndex');
        updatedSections.removeAt(exactMatchIndex);
      }

      // Always add new section at start
      print('Adding new section at beginning');
      updatedSections.insert(0, newSection);

      // Limit to 7 most recent
      updatedSections = updatedSections.take(7).toList();

      print('\nFinal Recent Sections:');
      updatedSections.forEach((s) => print(
          'Chapter ID: ${s.chapter.id}, Section: ${s.section.sectionNumber}'));

      // Emit new state with updated sections
      emit(currentState.copyWith(
        recentSections: updatedSections,
      ));

      print('=== END: Section Viewed Event ===\n');
    } else {
      print('DEBUG: State is not DocumentLoaded');
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
