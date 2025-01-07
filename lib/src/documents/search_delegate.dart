import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/document/document_bloc.dart';
import '../data/models/document_model.dart';
import '../data/repositories/document_repository.dart';
import 'document_detail_view.dart';
import '../settings/reading_settings.dart';

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
    if (query.isEmpty) {
      return const Center(child: Text('Enter a search term'));
    }

    documentBloc.add(SearchDocuments(query));

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

          // Group results by chapter
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
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent, // Remove divider lines
                  ),
                  child: ExpansionTile(
                  leading: const Icon(Icons.book, color: Colors.blue),
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
                  children: chapterResults.map((result) {
                    final section = result.section!;
                    final matchCount = RegExp(query, caseSensitive: false)
                        .allMatches(section.content)
                        .length;

                    return ListTile(
                      leading: const Icon(Icons.article, color: Colors.green),
                      title: Text(
                        'Section ${section.sectionNumber}: ${section.sectionTitle}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      subtitle: Text(
                        '$matchCount match${matchCount > 1 ? 'es' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: Chip(
                        label: Text(
                          '${result.score.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () {
                        if (result.section != null && result.chapter != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SectionContentView(
                                chapterNumber: result.chapter!.chapterNumber,
                                sectionTitle: result.section!.sectionTitle,
                                content: result.section!.content,
                                settings: context.read<ReadingSettings>(),
                                sectionId:
                                    '${result.chapter!.id}_${result.section!.sectionNumber}',
                                isFavorited: context
                                    .read<ReadingSettings>()
                                    .isSectionFavorite(
                                      '${result.chapter!.id}_${result.section!.sectionNumber}',
                                    ),
                              ),
                            ),
                          );
                        } else {
                          Navigator.pushNamed(
                            context,
                            DocumentDetailView.routeName,
                            arguments: result,
                          );
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            );  
              
            },
          );
        }

        return const Center(child: Text('Start searching...'));
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Start typing to search'));
    }

    documentBloc.add(SearchDocuments(query));

    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, state) {
        if (state is DocumentLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DocumentError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is DocumentSearchResults) {
          if (state.documents.isEmpty) {
            return const Center(child: Text('No suggestions found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.documents.length,
            itemBuilder: (context, index) {
              final document = state.documents[index];
              return ListTile(
                leading:
                    const Icon(Icons.insert_drive_file, color: Colors.orange),
                title: Text(document.title),
                onTap: () {
                  query = document.title;
                  showResults(context);
                },
              );
            },
          );
        }

        return const Center(child: Text('Start typing to search'));
      },
    );
  }
}
