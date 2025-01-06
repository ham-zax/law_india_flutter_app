import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'document_detail_view.dart';
import '../settings/settings_view.dart';
import '../search/document_search_delegate.dart';
import '../settings/reading_settings.dart';
import '../data/models/document_model.dart';
import '../widgets/favorite_button.dart';

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
                                      child: Card(
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          side: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceVariant,
                                            width: 1,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 16,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Chapter ${chapter.chapterNumber} - ${chapter.chapterTitle}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      letterSpacing: 0.1,
                                                      height: 1.4,
                                                    ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4),
                                                child: Text(
                                                  '${chapter.sections.length} Sections',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                        height: 1.4,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 16),

                        // Favorite Button
                        Center(
                          child: FloatingActionButton.extended(
                            icon: Icon(Icons.favorite),
                            label: Text('Favorites'),
                            onPressed: () {
                              _showFavoriteSections(context, state.documents);
                            },
                          ),
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
    final theme = Theme.of(context);
    final Color primaryColor =
        isActive ? theme.colorScheme.primary : Colors.grey;

    return Card(
      elevation: isActive ? 1 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isActive
                  ? theme.colorScheme.surfaceVariant
                  : theme.colorScheme.surface,
              isActive
                  ? theme.colorScheme.surfaceVariant.withOpacity(0.7)
                  : theme.colorScheme.surface,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isActive
                      ? primaryColor.withOpacity(0.1)
                      : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                ),
                child: Icon(
                  Icons.article_outlined,
                  size: 20,
                  color: isActive
                      ? primaryColor
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isActive
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isActive)
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 12,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.7),
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                'Coming soon',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withOpacity(0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFavoriteSections(BuildContext context, List<Document> documents) {
    final settings = Provider.of<ReadingSettings>(context, listen: false);
    final favoriteSections = documents
        .expand((doc) => doc.chapters)
        .expand((chapter) => chapter.sections
            .where((section) => settings
                .isSectionFavorite('${chapter.id}_${section.sectionNumber}'))
            .map((section) => (chapter: chapter, section: section)))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Favorite Sections',
                    style: theme.textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${favoriteSections.length} saved sections',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (favoriteSections.isEmpty)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No favorite sections yet',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the heart icon on any section to save it here',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: favoriteSections.length,
                    itemBuilder: (context, index) {
                      final favorite = favoriteSections[index];
                      final sectionId =
                          '${favorite.chapter.id}_${favorite.section.sectionNumber}';

                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: theme.colorScheme.surfaceVariant,
                            width: 1,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SectionContentView(
                                  chapterNumber: favorite.chapter.chapterNumber,
                                  sectionTitle: favorite.section.sectionTitle,
                                  content: favorite.section.content,
                                  settings: settings,
                                  sectionId: sectionId,
                                  isFavorited: true,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          theme.colorScheme.secondaryContainer,
                                      child: Text(
                                        favorite.section.sectionNumber,
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          color: theme
                                              .colorScheme.onSecondaryContainer,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            favorite.section.sectionTitle,
                                            style: theme.textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Chapter ${favorite.chapter.chapterNumber}',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.favorite,
                                          color: Colors.red),
                                      onPressed: () {
                                        settings
                                            .toggleSectionFavorite(sectionId);
                                        Navigator.pop(context);
                                        _showFavoriteSections(
                                            context, documents);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
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
                        sectionId: chapter.id,
                        isFavorited: settings.isSectionFavorite(chapter.id),
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
