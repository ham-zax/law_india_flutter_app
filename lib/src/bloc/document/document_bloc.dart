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
  }

  Future<void> _onLoadDocuments(
    LoadDocuments event,
    Emitter<DocumentState> emit,
  ) async {
    emit(DocumentLoading());
    try {
      final recentDocs = await repository.getRecentDocuments();
      final categories = await repository.getCategories();
      emit(DocumentLoaded(
        recentDocuments: recentDocs,
        categories: categories,
        selectedCategory: categories.first,
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
}
