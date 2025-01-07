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
    if (query.isEmpty) return [];
    
    final allDocs = await getDocumentsByCategory('BNS');
    final results = <Document>[];
    
    for (final doc in allDocs) {
      // Search document title
      final docScore = extractOne(
        query: query.toLowerCase(),
        choices: [doc.title.toLowerCase()]
      ).score;
      
      // Search chapters
      final chapterScores = doc.chapters.map((chapter) {
        return extractOne(
          query: query.toLowerCase(),
          choices: [chapter.chapterTitle.toLowerCase()]
        ).score;
      }).toList();
      
      // Search sections
      final sectionScores = doc.chapters.expand((chapter) {
        return chapter.sections.map((section) {
          final titleScore = extractOne(
            query: query.toLowerCase(),
            choices: [section.sectionTitle.toLowerCase()]
          ).score;
          
          final contentScore = extractOne(
            query: query.toLowerCase(),
            choices: [section.content.toLowerCase()]
          ).score;
          
          return max(titleScore, contentScore);
        });
      }).toList();
      
      // Get the highest score for this document
      final maxScore = max(
        docScore,
        max(
          chapterScores.isNotEmpty ? chapterScores.reduce(max) : 0,
          sectionScores.isNotEmpty ? sectionScores.reduce(max) : 0,
        ),
      );
      
      // Add to results if score is above threshold
      if (maxScore > 60) {
        results.add(doc);
      }
    }
    
    // Sort results by relevance
    results.sort((a, b) {
      final aScore = extractOne(
        query: query.toLowerCase(),
        choices: [a.title.toLowerCase()]
      ).score;
      
      final bScore = extractOne(
        query: query.toLowerCase(),
        choices: [b.title.toLowerCase()]
      ).score;
      
      return bScore.compareTo(aScore);
    });
    
    return results;
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
