import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'document_detail_view.dart';
import '../settings/settings_view.dart';
import '../search/document_search_delegate.dart';

import '../bloc/document/document_bloc.dart';

class DocumentListView extends StatelessWidget {
  const DocumentListView({super.key});

  static const routeName = '/documents';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        shadowColor: Theme.of(context).colorScheme.shadow,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: DocumentSearchDelegate(context.read<DocumentBloc>()),
              );
            },
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          // Prevent going back to the sample items view
          return false;
        },
        child: BlocBuilder<DocumentBloc, DocumentState>(
        builder: (context, state) {
          if (state is DocumentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DocumentError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is DocumentLoaded) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recent Documents Section
                      const Text(
                        'Recent Documents',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: state.recentDocuments
                            .map((doc) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        DocumentDetailView.routeName,
                                        arguments: doc,
                                      );
                                    },
                                    child: _buildDocumentCard(
                                      context: context,
                                      title: doc.title,
                                      subtitle: '${doc.category} • ${doc.chapters.length} Chapters',
                                      showChevron: true,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),

                      // Categories Section
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.categories.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = state.categories[index];
                            return ChoiceChip(
                              label: Text(category),
                              selected: category == state.selectedCategory,
                              onSelected: (selected) {
                                context.read<DocumentBloc>().add(
                                      ChangeCategory(category),
                                    );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Chapters Section
                      const Text(
                        'Chapters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.documents.first.chapters.length,
                        itemBuilder: (context, index) {
                          final chapter = state.documents.first.chapters[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  DocumentDetailView.routeName,
                                  arguments: chapter,
                                );
                              },
                              child: _buildDocumentCard(
                                context: context,
                                title: 'Chapter ${chapter.chapterNumber} - ${chapter.chapterTitle}',
                                subtitle: '${chapter.sections.length} Sections',
                                showChevron: true,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const Center(child: Text('No documents found'));
        },
      ),
    );
  }


  Widget _buildDocumentCard({
    required BuildContext context,
    required String title,
    String? lastAccessed,
    String? subtitle,
    bool showChevron = false,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      surfaceTintColor: Theme.of(context).colorScheme.surfaceVariant,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.article, size: 24, color: Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (lastAccessed != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          lastAccessed,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (showChevron)
                Icon(Icons.chevron_right, size: 24, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }
}
