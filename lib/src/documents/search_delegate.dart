import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import '../bloc/document/document_bloc.dart';
import '../data/models/document_model.dart';
import '../data/repositories/document_repository.dart';
import 'document_detail_view.dart';
import '../settings/reading_settings.dart';

Widget buildScoreIndicator(double score, BuildContext context) {
  return Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Theme.of(context).colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).shadowColor.withOpacity(0.1),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            value: score / 100,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              score > 75 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary,
            ),
            strokeWidth: 3,
          ),
        ),
        Text(
          '${score.round()}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

class DocumentSearchDelegate extends SearchDelegate<String> {
  final DocumentBloc documentBloc;

  DocumentSearchDelegate(this.documentBloc);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Just use the same implementation as suggestions
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Trigger search immediately when text changes
    if (query.isNotEmpty) {
      documentBloc.add(SearchDocuments(query));
    }

    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, state) {
        if (state is DocumentLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DocumentError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is DocumentSearchResults) {
          if (state.results.isEmpty) {
            return const Center(child: Text('No results found'));
          }

          // Use the same results display as buildResults
          final resultsByChapter = <String, List<SearchResult>>{};
          for (final result in state.results) {
            if (result.chapter != null) {
              final chapterKey = 'Chapter ${result.chapter!.chapterNumber}';
              resultsByChapter.putIfAbsent(chapterKey, () => []).add(result);
            }
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: resultsByChapter.length,
            itemBuilder: (context, index) {
              final chapterEntry = resultsByChapter.entries.elementAt(index);
              final chapterName = chapterEntry.key;
              final chapterResults = chapterEntry.value;

              // Count total matches in this chapter
              final totalMatches = chapterResults.fold(0, (sum, result) {
                final content = result.section?.content ?? '';
                return sum +
                    RegExp(query, caseSensitive: false)
                        .allMatches(content)
                        .length;
              });

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    width: 1.0,
                  ),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    leading: const Icon(Icons.book, color: Colors.blue),
                    backgroundColor:
                        Theme.of(context).colorScheme.surface.withOpacity(0.3),
                    collapsedBackgroundColor: Colors.transparent,
                    title: Text(
                      chapterName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${chapterResults.length} sections with $totalMatches matches',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    children: chapterResults.asMap().entries.map((entry) {
                      final index = entry.key;
                      final result = entry.value;
                      final section = result.section!;
                      final matchCount = RegExp(query, caseSensitive: false)
                          .allMatches(section.content)
                          .length;
                      final isLastItem = index == chapterResults.length - 1;

                      return InkWell(
                        onTap: () {
                          try {
                            if (result.section != null && result.chapter != null) {
                              final sectionId = '${result.chapter!.id}_${result.section!.sectionNumber}';
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SectionContentView(
                                    chapterNumber: result.chapter!.chapterNumber,
                                    sectionTitle: result.section!.sectionTitle,
                                    content: result.section!.content,
                                    settings: context.read<ReadingSettings>(),
                                    sectionId: sectionId,
                                    isFavorited: context
                                        .read<ReadingSettings>()
                                        .isSectionFavorite(sectionId),
                                    showNavigation: false,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Invalid section data'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error navigating to section: ${e.toString()}'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.article,
                                  color: Colors.green),
                              title: Text(
                                'Section ${section.sectionNumber}: ${section.sectionTitle.replaceFirst(
                                  RegExp(r'^\d+\.\s*'),
                                  '',
                                )}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              subtitle: Text(
                                '$matchCount match${matchCount > 1 ? 'es' : ''}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              trailing: buildScoreIndicator(result.score, context),
                            ),
                            if (!isLastItem && chapterResults.length > 1)
                              const Divider(height: 1, thickness: 1),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          );
        }

        return const Center(child: Text('Start typing to search'));
      },
    );
  }
}
