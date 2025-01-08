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

  double _normalizeScore(double rawScore, String matchType) {
    final weights = {
      'exact': 1.0,
      'section': 0.8,
      'chapter': 0.6,
      'content': 0.4
    };
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
          
          // Check for number matches
          if (numbersInQuery.isNotEmpty) {
            // Chapter number match
            if (numbersInQuery.contains(chapter.chapterNumber)) {
              score = max(score, 3.0);
            }
            
            // Section number match
            if (numbersInQuery.contains(section.sectionNumber)) {
              score = max(score, 2.5);
            }
            
            // Content number match
            if (contentLower.contains(numbersInQuery.join(' '))) {
              score = max(score, 1.5);
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

    // Modified sorting logic
    results.sort((a, b) {
      // First priority: Section matches if user searched for section
      if (hasSectionTerm) {
        final aSectionMatch = a.matchedField == 'section';
        final bSectionMatch = b.matchedField == 'section';
        if (aSectionMatch != bSectionMatch) {
          return aSectionMatch ? -1 : 1;
        }
        if (aSectionMatch && bSectionMatch) {
          return (a.sectionNumber ?? 0).compareTo(b.sectionNumber ?? 0);
        }
      }
      
      // Second priority: Exact number matches
      if (isGeneralNumberSearch) {
        final aIsExactMatch = a.chapter?.chapterNumber == query.trim() || 
                            a.section?.sectionNumber == query.trim();
        final bIsExactMatch = b.chapter?.chapterNumber == query.trim() || 
                            b.section?.sectionNumber == query.trim();
        
        if (aIsExactMatch != bIsExactMatch) {
          return aIsExactMatch ? -1 : 1;
        }
      }
      
      // Third priority: Chapter number matches
      if (hasChapterTerm) {
        final aChapterMatch = a.matchedField == 'chapter';
        final bChapterMatch = b.matchedField == 'chapter';
        if (aChapterMatch != bChapterMatch) {
          return aChapterMatch ? -1 : 1;
        }
        if (aChapterMatch && bChapterMatch) {
          return (a.chapterNumber ?? 0).compareTo(b.chapterNumber ?? 0);
        }
      }
      
      // Final priority: Normalized score-based ordering
      final aNormScore = _normalizeScore(a.score, a.matchedField);
      final bNormScore = _normalizeScore(b.score, b.matchedField);
      return bNormScore.compareTo(aNormScore);
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
