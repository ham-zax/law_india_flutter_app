import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'document_detail_view.dart';
import '../search/document_search_delegate.dart';
import '../settings/reading_settings.dart';
import '../data/models/document_model.dart';
import '../bloc/document/document_bloc.dart';

class DocumentListView extends StatelessWidget {
  const DocumentListView({super.key});

  static const routeName = '/documents';

String cleanTitle(String title) {
    final regex = RegExp(r'^\d+[\.\s-]*\s*');
    return title.replaceFirst(regex, '');
  }

  List<Widget> _buildTitleParts(BuildContext context, String title, {bool isBold = false}) {
    final cleanedTitle = cleanTitle(title);
    final titleParts = cleanedTitle.split(' - ');
    final mainTitle = titleParts[0].trim();
    final subtitles = titleParts.length > 1 ? titleParts.sublist(1) : [];
    
    return [
      Text(
        mainTitle,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: isBold ? FontWeight.w500 : FontWeight.normal,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      if (subtitles.isNotEmpty) ...[
        const SizedBox(height: 4),
        ...subtitles.map((subtitle) => Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        )),
      ],
    ];
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back arrow
        title: Text(
          'Bharatiya Nyaya Sanhita',
          style: Theme.of(context).textTheme.titleLarge, // Smaller title
        ),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
                Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.8),
              ],
            ),
          ),
        ),
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
        onWillPop: () async => false,
        child: BlocBuilder<DocumentBloc, DocumentState>(
          builder: (context, state) {
            if (state is DocumentLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DocumentError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is DocumentLoaded) {
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Continue Reading',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 220,
                            child: Stack(
                              children: [
                                PageView.builder(
                                  controller: PageController(viewportFraction: 0.85),
                                  itemCount: state.recentChapters.length,
                                  itemBuilder: (context, index) {
                                    final chapter = state.recentChapters[index];
                                    return AnimatedBuilder(
                                      animation: PageController(),
                                      builder: (context, child) {
                                        final pageOffset = index - (PageController().page ?? 0);
                                        final scale = 1 - (0.1 * pageOffset.abs());
                                        final margin = pageOffset.abs() * 20;
                                        
                                        return Transform.scale(
                                          scale: scale,
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 16 ,
                                            ),
                                            child: Card(
                                              elevation: 4,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(16),
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    DocumentDetailView.routeName,
                                                    arguments: chapter,
                                                  );
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(20),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          CircleAvatar(
                                                            backgroundColor:
                                                                Theme.of(context)
                                                                    .colorScheme
                                                                    .primaryContainer,
                                                            child: Text(
                                                                chapter.chapterNumber),
                                                          ),
                                                          const SizedBox(width: 16),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  'Chapter ${chapter.chapterNumber}',
                                                                  style: Theme.of(context)
                                                                      .textTheme
                                                                      .titleMedium,
                                                                ),
                                                                const SizedBox(height: 8),
                                                                ..._buildTitleParts(context, chapter.chapterTitle),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const Spacer(),
                                                      LinearProgressIndicator(
                                                        value: 0.5, // TODO: Replace with actual progress
                                                        backgroundColor: Theme.of(context)
                                                            .colorScheme
                                                            .surfaceVariant,
                                                        valueColor: AlwaysStoppedAnimation<Color>(
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        '${chapter.sections.length} Sections',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                              color: Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                                if (state.recentChapters.length > 1)
                                  Positioned(
                                    bottom: 8,
                                    left: 0,
                                    right: 0,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List<Widget>.generate(
                                        state.recentChapters.length,
                                        (index) => Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'All Chapters',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final chapter = state.documents.first.chapters[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant,
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    DocumentDetailView.routeName,
                                    arguments: chapter,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        child: Text(
                                          chapter.chapterNumber,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ..._buildTitleParts(context, chapter.chapterTitle, isBold: true),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${chapter.sections.length} Sections',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: state.documents.first.chapters.length,
                      ),
                    ),
                  ),
                ],
              );
            }
            return const Center(child: Text('No documents found'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.favorite),
        label: const Text('Favorites'),
        onPressed: () {
          final currentState = context.read<DocumentBloc>().state;
          if (currentState is DocumentLoaded) {
            _showFavoriteSections(context, currentState.documents);
          }
        },
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
                    icon: const Icon(Icons.close),
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
                        margin: const EdgeInsets.only(bottom: 12),
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
                                      icon: const Icon(Icons.favorite,
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
}
