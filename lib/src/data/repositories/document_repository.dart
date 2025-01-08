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
  final int? chapterNumber;
  final int? sectionNumber;

  SearchResult({
    required this.document,
    this.chapter,
    this.section, 
    required this.score,
    required this.matchedField,
    this.chapterNumber,
    this.sectionNumber,
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
  static const int MAX_CACHE_SIZE = 100;
  static const double SIMILARITY_THRESHOLD = 0.6;
  final Map<String, List<SearchResult>> _searchCache = {};

  // Pre-compile RegExp patterns
  static final numberPattern = RegExp(r'\d+');
  static final chapterTerms = RegExp(r'ch(apter)?(?:\s+|\d+|$)');
  static final sectionTerms = RegExp(r'sec(tion)?(?:\s+|\d+|$)');
  
  // Score normalization weights
  static final weights = {
    'exact': 1.0,
    'section': 0.8,
    'chapter': 0.6,
    'content': 0.4,
    'combined': 0.9  // New weight for combined matches
  };

  @override
  Map<String, List<SearchResult>> get searchCache => _searchCache;

  void _manageCache() {
    if (_searchCache.length > MAX_CACHE_SIZE) {
      final entriesToRemove = _searchCache.length - MAX_CACHE_SIZE;
      final oldestEntries = _searchCache.entries.take(entriesToRemove);
      for (var entry in oldestEntries) {
        _searchCache.remove(entry.key);
      }
    }
  }

  // Normalize during score calculation
  double _calculateScore(String matchType, double rawScore) {
    return (rawScore * (weights[matchType] ?? 0.5)).clamp(0.0, 1.0);
  }

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
    try {
      // Manage cache before adding new results
      _manageCache();
      
      if (_searchCache.containsKey(query)) {
      return _searchCache[query]!
          .map((result) => result.document)
          .toSet()
          .toList();
    }

    if (query.length < 2) {
      return [];
    }

    final allDocs = await getDocumentsByCategory('BNS');
    final results = <SearchResult>[];
    final queryLower = query.toLowerCase();

    // Helper to extract numbers from query
    final numberPattern = RegExp(r'\d+');
    final numberMatches = numberPattern.allMatches(queryLower);
    final numbersInQuery = numberMatches.map((m) => m.group(0)).toSet();
    
    // Check if query contains chapter/section terms
    final chapterTerms = RegExp(r'ch(apter)?(?:\s+|$)');
    final sectionTerms = RegExp(r'sec(tion)?(?:\s+|$)');
    
    bool hasChapterTerm = chapterTerms.hasMatch(queryLower);
    bool hasSectionTerm = sectionTerms.hasMatch(queryLower);
    
    // If no specific terms, treat as general number search
    final isGeneralNumberSearch = !hasChapterTerm && !hasSectionTerm && numbersInQuery.isNotEmpty;

    for (final doc in allDocs) {
      for (final chapter in doc.chapters) {

        for (final section in chapter.sections) {
          double score = 0.0;
          final contentLower = section.content.toLowerCase();
          final titleLower = section.sectionTitle.toLowerCase();
          
          // Check for number matches with normalized scores
          if (numbersInQuery.isNotEmpty) {
            // Chapter number match
            if (numbersInQuery.contains(chapter.chapterNumber)) {
              score = max(score, _calculateScore('chapter', 3.0));
            }
            
            // Section number match
            if (numbersInQuery.contains(section.sectionNumber)) {
              score = max(score, _calculateScore('section', 2.5));
            }
            
            // Combined chapter-section match
            if (numbersInQuery.contains(chapter.chapterNumber) && 
                numbersInQuery.contains(section.sectionNumber)) {
              score = max(score, _calculateScore('combined', 4.0));
            }
            
            // Content number match
            if (contentLower.contains(numbersInQuery.join(' '))) {
              score = max(score, _calculateScore('content', 1.5));
            }
          }
          
          // If general number search, boost score for exact matches
          if (isGeneralNumberSearch) {
            if (chapter.chapterNumber == query.trim() || 
                section.sectionNumber == query.trim()) {
              score = max(score, 4.0);
            }
          }
          
          // Regular content matching
          final contentWords = contentLower.split(RegExp(r'\s+'));
          for (final word in contentWords) {
            final similarity = queryLower.similarityTo(word);
            score = max(score, similarity);
          }
          
          // Check title similarity
          final titleSimilarity = queryLower.similarityTo(titleLower);
          score = max(score, titleSimilarity);

          if (score > 0.6) {
            results.add(SearchResult(
              document: doc,
              chapter: chapter,
              section: section,
              score: score * 100,
              matchedField: numbersInQuery.contains(chapter.chapterNumber) ? 'chapter' :
                           numbersInQuery.contains(section.sectionNumber) ? 'section' : 'content',
              chapterNumber: int.tryParse(chapter.chapterNumber ?? ''),
              sectionNumber: int.tryParse(section.sectionNumber)
            ));
          }
        }
      }
    }

    // Updated sorting logic
    results.sort((a, b) {
      // Handle combined chapter-section queries
      if (hasChapterTerm && hasSectionTerm) {
        final aMatch = a.matchedField == 'chapter' && numbersInQuery.contains(a.chapter?.chapterNumber) &&
                      numbersInQuery.contains(a.section?.sectionNumber);
        final bMatch = b.matchedField == 'chapter' && numbersInQuery.contains(b.chapter?.chapterNumber) &&
                      numbersInQuery.contains(b.section?.sectionNumber);
        if (aMatch != bMatch) return aMatch ? -1 : 1;
      }
      
      // Prioritize section matches when explicitly searching for section
      if (hasSectionTerm) {
        final aSectionMatch = numbersInQuery.contains(a.section?.sectionNumber);
        final bSectionMatch = numbersInQuery.contains(b.section?.sectionNumber);
        if (aSectionMatch != bSectionMatch) return aSectionMatch ? -1 : 1;
        if (aSectionMatch && bSectionMatch) {
          return (a.sectionNumber ?? 0).compareTo(b.sectionNumber ?? 0);
        }
      }

      // Final priority: Score-based ordering
      return b.score.compareTo(a.score);
    });

    _manageCache();

    _searchCache[query] = results;
      return results.map((result) => result.document).toSet().toList();
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }
}
