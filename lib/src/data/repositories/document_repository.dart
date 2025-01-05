import '../models/document_model.dart';

abstract class DocumentRepository {
  Future<List<Document>> getRecentDocuments();
  Future<List<Document>> getDocumentsByCategory(String category);
  Future<List<String>> getCategories();
  Future<List<Document>> searchDocuments(String query);
  Future<void> updateDocument(Document document);
  Future<List<DocumentVersion>> getDocumentVersions(String documentId);
}

class LocalDocumentRepository implements DocumentRepository {
  @override
  Future<List<Document>> getRecentDocuments() async {
    // TODO: Implement local storage logic
    return [];
  }

  @override
  Future<List<Document>> getDocumentsByCategory(String category) async {
    // TODO: Implement local storage logic
    return [];
  }

  @override
  Future<List<String>> getCategories() async {
    return ['BNS', 'Constitutional', 'Criminal', 'Civil', 'Corporate', 'Tax'];
  }

  @override
  Future<List<Document>> searchDocuments(String query) async {
    // TODO: Implement search logic
    return [];
  }

  @override
  Future<void> updateDocument(Document document) async {
    // TODO: Implement update logic
  }

  @override
  Future<List<DocumentVersion>> getDocumentVersions(String documentId) async {
    // TODO: Implement version history logic
    return [];
  }
}
