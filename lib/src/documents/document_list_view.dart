import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/favorite_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'document_detail_view.dart';
import '../settings/settings_view.dart';
import '../search/document_search_delegate.dart';
import '../settings/reading_settings.dart';
import '../data/models/document_model.dart';

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
                      // Categories Section
                      Text(
                        'Categories',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.5,
                        children: state.categories.map((category) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              if (category == 'BNS') {
                                Navigator.pushNamed(
                                  context,
                                  DocumentDetailView.routeName,
                                  arguments: state.documents.first,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Coming soon!'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            child: _buildCategoryCard(
                              context: context,
                              title: category,
                              isActive: category == 'BNS',
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Recent Documents Section
                      Text(
                        'Recent Documents',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: state.recentChapters
                            .map((chapter) => Padding(
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
                                      chapter: chapter,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),

                      // Favorites Section
                      Text(
                        'Favorites',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Consumer<ReadingSettings>(
                        builder: (context, settings, child) {
                          final favoriteChapters = state.documents
                              .expand((doc) => doc.chapters)
                              .where((chapter) => settings.isFavorite(chapter.id))
                              .toList();
                          
                          if (favoriteChapters.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'No favorites yet',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            );
                          }

                          return Column(
                            children: favoriteChapters
                                .map((chapter) => Padding(
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
                                          chapter: chapter,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          }

          return const Center(child: Text('No documents found'));
        },
        ),
      ),
    );
  }


  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    bool isActive = true,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isActive 
          ? Theme.of(context).colorScheme.surfaceVariant
          : Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive 
                    ? Colors.blue.shade50 
                    : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.article, 
                size: 24, 
                color: isActive ? Colors.blue : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isActive 
                      ? Theme.of(context).colorScheme.onSurface 
                      : Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!isActive)
              const Icon(Icons.lock, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required BuildContext context,
    required String title,
    String? subtitle,
    required DocumentChapter chapter,
  }) {
    return Card(
      elevation: 0, // Remove elevation for cleaner look
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).colorScheme.surfaceVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Consumer<ReadingSettings>(
                    builder: (context, settings, child) {
                      return FavoriteButton(
                        isFavorited: settings.isFavorite(chapter.id),
                        favoriteCount: 0,
                        itemId: chapter.id,
                      );
                    },
                  ),
                ],
              ),
              if (subtitle != null) 
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
