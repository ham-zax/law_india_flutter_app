import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
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
    // Return BNS document with all chapters
    return await getDocumentsByCategory('BNS');
  }

  @override
  Future<List<Document>> getDocumentsByCategory(String category) async {
    if (category == 'BNS') {
      final List<DocumentChapter> chapters = [];
      
      // Load all 20 chapters
      for (int i = 1; i <= 20; i++) {
        final jsonString = await rootBundle.loadString('assets/data/chapter_$i.json');
        final jsonData = jsonDecode(jsonString) as List;
        
        final firstSection = jsonData.first;
        final chapterTitle = firstSection['cn'] ?? 'Chapter $i'; // Use 'cn' for chapter name
        final sections = jsonData.map((section) {
          // Extract section number from title (e.g. "4. Punishments" -> "4")
          final sectionTitle = section['st'] ?? 'Untitled Section';
          final sectionNumber = sectionTitle.split('.').first.trim();
          
          return DocumentSection(
            sectionNumber: sectionNumber,
            sectionTitle: sectionTitle,
            content: section['s'] ?? '',
          );
        }).toList();

        chapters.add(DocumentChapter(
          id: 'bns_chapter_$i', // Unique ID for each chapter
          chapterNumber: i.toString(),
          chapterTitle: chapterTitle,
          sections: sections,
        ));
      }

      return [
        Document(
          id: 'bns',
          title: 'Bharatiya Nyaya Sanhita',
          category: 'BNS',
          chapters: chapters,
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
    final allDocs = await getDocumentsByCategory('BNS');
    
    return allDocs.where((doc) {
      // Search in document title
      if (extractOne(
        query: query.toLowerCase(),
        choices: [doc.title.toLowerCase()]
      ).score > 80) {
        return true;
      }
      
      // Search in chapters
      for (final chapter in doc.chapters) {
        if (extractOne(
          query: query.toLowerCase(),
          choices: [chapter.chapterTitle.toLowerCase()]
        ).score > 80) {
          return true;
        }
        
        // Search in sections
        for (final section in chapter.sections) {
          final titleMatch = extractOne(
            query: query.toLowerCase(),
            choices: [section.sectionTitle.toLowerCase()]
          ).score > 80;
          
          final contentMatch = extractOne(
            query: query.toLowerCase(),
            choices: [section.content.toLowerCase()]
          ).score > 80;
          
          if (titleMatch || contentMatch) {
            return true;
          }
        }
      }
      return false;
    }).toList();
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
