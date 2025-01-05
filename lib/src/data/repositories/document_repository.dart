import 'dart:convert';
import 'package:flutter/services.dart';
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
    // For now return BNS as recent document
    return await getDocumentsByCategory('BNS');
  }

  @override
  Future<List<Document>> getDocumentsByCategory(String category) async {
    if (category == 'BNS') {
      final jsonString = await rootBundle.loadString('assets/data/chapter_1.json');
      final jsonData = jsonDecode(jsonString) as List;
      
      final sections = jsonData.map((section) => DocumentSection(
        chapterNumber: section['cn'],
        sectionTitle: section['st'],
        content: section['s'],
      )).toList();

      return [
        Document(
          id: 'bns-1',
          title: 'Bharatiya Nyaya Sanhita',
          category: 'BNS',
          sections: sections,
        )
      ];
    }
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
    // Not needed for BNS document
  }

  @override
  Future<List<DocumentVersion>> getDocumentVersions(String documentId) async {
    // Not needed for BNS document
    return [];
  }
}
