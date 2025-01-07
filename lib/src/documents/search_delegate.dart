import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/document/document_bloc.dart';
import '../data/models/document_model.dart';
import 'document_detail_view.dart';

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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              final result = state.results[index];
              final document = result.document;
                
              String subtitle = '';
              if (result.chapter != null) {
                subtitle = 'Chapter ${result.chapter!.chapterNumber}';
                if (result.section != null) {
                  subtitle += ', Section ${result.section!.sectionNumber}';
                }
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(document.title),
                  subtitle: Text(subtitle.isNotEmpty ? subtitle : 'Document'),
                  trailing: Text('${result.score.toStringAsFixed(1)}%'),
                  onTap: () {
                    if (result.section != null && result.chapter != null) {
                      // Navigate directly to the section if available
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SectionContentView(
                            chapterNumber: result.chapter!.chapterNumber,
                            sectionTitle: result.section!.sectionTitle,
                            content: result.section!.content,
                            settings: context.read<ReadingSettings>(),
                            sectionId: '${result.chapter!.id}_${result.section!.sectionNumber}',
                            isFavorited: context.read<ReadingSettings>().isSectionFavorite(
                              '${result.chapter!.id}_${result.section!.sectionNumber}'
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Fall back to document view
                      Navigator.pushNamed(
                        context,
                        DocumentDetailView.routeName,
                        arguments: document,
                      );
                    }
                  },
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
