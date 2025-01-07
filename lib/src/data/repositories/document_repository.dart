import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import '../models/document_model.dart';
import 'package:string_similarity/string_similarity.dart';

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
  final double _similarityThreshold = 0.7;

  @override
  Map<String, List<SearchResult>> get searchCache => _searchCache;

  @override
  Future<List<Document>> getRecentDocuments() async {
    // Return BNS document with all chapters
    return await getDocumentsByCategory('BNS');
  }

  @override
  Future<List<String>> getCategories() async {
    return ['BNS', 'Constitutional', 'Criminal', 'Civil', 'Corporate', 'Tax'];
  }

  @override
  Future<List<Document>> getDocumentsByCategory(String category) async {
    if (category == 'BNS') {
      final List<DocumentChapter> chapters = [];

      // Load all 20 chapters
      for (int i = 1; i <= 20; i++) {
        final jsonString =
            await rootBundle.loadString('assets/data/chapter_$i.json');
        final jsonData = jsonDecode(jsonString) as List;

        final firstSection = jsonData.first;
        final chapterTitle = firstSection['cn'] ?? 'Chapter $i';
        final sections = jsonData.map((section) {
          final sectionTitle = section['st'] ?? 'Untitled Section';
          final sectionNumber = sectionTitle.split('.').first.trim();

          return DocumentSection(
            sectionNumber: sectionNumber,
            sectionTitle: sectionTitle,
            content: section['s'] ?? '',
          );
        }).toList();

        chapters.add(DocumentChapter(
          id: 'bns_chapter_$i',
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
  Future<void> updateDocument(Document document) async {
    // Not implemented for read-only BNS documents
  }

  @override
  Future<List<DocumentVersion>> getDocumentVersions(String documentId) async {
    // Not implemented for current BNS version
    return [];
  }

  // Your existing searchDocuments implementation...
  @override
  @override
Future<List<Document>> searchDocuments(String query) async {
    if (query.isEmpty) return [];

    if (_searchCache.containsKey(query)) {
      return _searchCache[query]!
          .map((result) => result.document)
          .toSet()
          .toList();
    }

    final allDocs = await getDocumentsByCategory('BNS');
    final results = <SearchResult>[];
    final queryLower = query.toLowerCase();

    for (final doc in allDocs) {
      for (final chapter in doc.chapters) {
        for (final section in chapter.sections) {
          double score = 0.0;
          final contentLower = section.content.toLowerCase();
          final titleLower = section.sectionTitle.toLowerCase();

          // Check for exact matches first
          if (contentLower.contains(queryLower) ||
              titleLower.contains(queryLower)) {
            score = 1.0;
          } else {
            // Fall back to similarity matching for fuzzy search
            final words = contentLower.split(RegExp(r'\s+'));
            for (final word in words) {
              final similarity = queryLower.similarityTo(word);
              score = max(score, similarity);
            }
          }

          if (score > 0.6) {
            // Lower threshold and prioritize exact matches
            results.add(SearchResult(
                document: doc,
                chapter: chapter,
                section: section,
                score: score * 100,
                matchedField: 'content'));
          }
        }
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    _searchCache[query] = results;

    return results.map((result) => result.document).toSet().toList();
  }
}
