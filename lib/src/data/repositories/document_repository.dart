import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import '../models/document_model.dart';

class SearchResult {
  final Document document;
  final DocumentChapter? chapter;
  final DocumentSection? section;
  final double score;
  final String matchedField;

  SearchResult({
    required this.document,
    this.chapter,
    this.section, 
    required this.score,
    required this.matchedField
  });
}

abstract class DocumentRepository {
  Future<List<Document>> getRecentDocuments();
  Future<List<Document>> getDocumentsByCategory(String category);
  Future<List<String>> getCategories();
  Future<List<Document>> searchDocuments(String query);
  Future<void> updateDocument(Document document);
  Future<List<DocumentVersion>> getDocumentVersions(String documentId);
  
  // Add this getter
  Map<String, List<SearchResult>> get searchCache;
}

class LocalDocumentRepository implements DocumentRepository {
  final Map<String, List<SearchResult>> _searchCache = {};

  @override
  Map<String, List<SearchResult>> get searchCache => _searchCache;
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
    
    // Check cache first
    if (_searchCache.containsKey(query)) {
      return _searchCache[query]!
          .map((result) => result.document)
          .toSet()
          .toList();
    }

    final allDocs = await getDocumentsByCategory('BNS');
    final results = <SearchResult>[];
    
    for (final doc in allDocs) {
      // Search document title
      final titleScore = tokenSetRatio(
        query.toLowerCase(),
        doc.title.toLowerCase()
      ) * 1.5; // Weight title matches higher
      
      if (titleScore > 60) {
        results.add(SearchResult(
          document: doc,
          score: titleScore,
          matchedField: 'title'
        ));
      }
      
      // Search chapters
      for (final chapter in doc.chapters) {
        final chapterScore = tokenSetRatio(
          query.toLowerCase(), 
          chapter.chapterTitle.toLowerCase()
        ) * 1.2;
        
        if (chapterScore > 60) {
          results.add(SearchResult(
            document: doc,
            chapter: chapter,
            score: chapterScore,
            matchedField: 'chapter'
          ));
        }
        
        // Search sections
        for (final section in chapter.sections) {
          final titleScore = tokenSetRatio(
            query.toLowerCase(),
            section.sectionTitle.toLowerCase()
          );
          
          final contentScore = tokenSetRatio(
            query.toLowerCase(),
            section.content.toLowerCase()
          ) * 0.8; // Weight content matches lower
          
          final maxScore = max(titleScore, contentScore);
          
          if (maxScore > 60) {
            results.add(SearchResult(
              document: doc,
              chapter: chapter,
              section: section,
              score: maxScore.toDouble(),
              matchedField: titleScore > contentScore ? 'section_title' : 'content'
            ));
          }
        }
      }
    }
    
    // Sort by score descending
    results.sort((a, b) => b.score.compareTo(a.score));
    
    // Cache results
    _searchCache[query] = results;
    
    // Return unique documents
    return results
        .map((result) => result.document)
        .toSet()
        .toList();
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
