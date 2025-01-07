import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'document_detail_view.dart';
import '../search/document_search_delegate.dart';
import '../settings/reading_settings.dart';
import '../data/models/document_model.dart';
import '../bloc/document/document_bloc.dart';

const double kSpacing4 = 4.0;
const double kSpacing8 = 8.0;
const double kSpacing12 = 12.0;
const double kSpacing16 = 16.0;

class DocumentListView extends StatefulWidget {
  const DocumentListView({super.key});
  static const routeName = '/documents';

  @override
  State<DocumentListView> createState() => _DocumentListViewState();
}

class _DocumentListViewState extends State<DocumentListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String cleanTitle(String title) {
    final regex = RegExp(r'^\d+[\.\s-]*\s*');
    return title.replaceFirst(regex, '');
  }

  List<Widget> _buildTitleParts(BuildContext context, String title,
      {bool isBold = false}) {
    final cleanedTitle = cleanTitle(title);
    final titleParts = cleanedTitle.split(' - ');

    // Capitalize only first letter of each part, rest lowercase
    final mainTitle = titleParts[0].trim();
    final formattedMainTitle = mainTitle.isEmpty
        ? ''
        : mainTitle[0].toUpperCase() + mainTitle.substring(1);

    final subtitles = titleParts.length > 1
        ? titleParts.sublist(1).map((part) {
            final trimmedPart = part.trim().toLowerCase();
            return trimmedPart.isEmpty
                ? ''
                : trimmedPart[0].toUpperCase() + trimmedPart.substring(1);
          }).toList()
        : [];

    return [
      Text(
        formattedMainTitle,
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

  Widget _buildFavoritesTab(BuildContext context) {
    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, state) {
        if (state is DocumentLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DocumentLoaded) {
          final settings = Provider.of<ReadingSettings>(context);
          final favoriteSections = state.documents
              .expand((doc) => doc.chapters)
              .expand((chapter) => chapter.sections
                  .where((section) => settings.isSectionFavorite(
                      '${chapter.id}_${section.sectionNumber}'))
                  .map((section) => (chapter: chapter, section: section)))
              .toList();

          if (favoriteSections.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorite sections yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the heart icon on any section to save it here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(kSpacingMedium),
            itemCount: favoriteSections.length,
            itemBuilder: (context, index) {
              final favorite = favoriteSections[index];
              final sectionId =
                  '${favorite.chapter.id}_${favorite.section.sectionNumber}';

              return Card(
                margin: const EdgeInsets.only(bottom: kSpacing8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
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
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                          child: Text(
                            favorite.section.sectionNumber,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                favorite.section.sectionTitle,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Chapter ${favorite.chapter.chapterNumber}',
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
                        IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () {
                            settings.toggleSectionFavorite(sectionId);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }

        return const Center(child: Text('No favorites found'));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        padding: const EdgeInsets.symmetric(horizontal: kSpacing8),
        title: Text(
          'Bharatiya Nyaya Sanhita',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
        surfaceTintColor: Colors.transparent,
        backgroundColor: Theme.of(context).colorScheme.surface,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'ALL CHAPTERS'),
            Tab(text: 'FAVORITES'),
          ],
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
      body: TabBarView(
        controller: _tabController,
        children: [
          BlocBuilder<DocumentBloc, DocumentState>(
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: kSpacingMedium,
                          vertical: kSpacingLarge,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.recentSections.isNotEmpty) ...[
                              Text(
                                'Continue Reading',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      letterSpacing: -0.5,
                                    ),
                              ),
                              const SizedBox(height: kSpacingSmall),
                              SizedBox(
                                height: 64,
                                child: Column(
                                  children: [
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      controller: _scrollController,
                                      child: Row(
                                        children: [
                                          for (var recentItem
                                              in state.recentSections)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8),
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  final sectionId =
                                                      '${recentItem.chapter.id}_${recentItem.section.sectionNumber}';
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SectionContentView(
                                                        chapterNumber:
                                                            recentItem.chapter
                                                                .chapterNumber,
                                                        sectionTitle: recentItem
                                                            .section
                                                            .sectionTitle,
                                                        content: recentItem
                                                            .section.content,
                                                        settings: context.read<
                                                            ReadingSettings>(),
                                                        sectionId: sectionId,
                                                        isFavorited: context
                                                            .read<
                                                                ReadingSettings>()
                                                            .isSectionFavorite(
                                                                sectionId),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  side: BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primaryContainer,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Ch ${recentItem.chapter.chapterNumber} sec ${recentItem.section.sectionNumber}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: kSpacingSmall),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: kSpacingSmall),
                                      child: ScrollBar(
                                        scrollController: _scrollController,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: kSpacingMedium),
                            ],
                            const SizedBox(height: kSpacingSmall),
                            Text(
                              'All Chapters',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kSpacing16,
                        vertical: kSpacing8,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final chapter =
                                state.documents.first.chapters[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: kSpacingMedium,
                                      vertical: kSpacingSmall,
                                    ),
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
                                                .titleMedium
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimaryContainer,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: kSpacingSmall),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ..._buildTitleParts(
                                                  context, chapter.chapterTitle,
                                                  isBold: true),
                                              const SizedBox(
                                                  height: kSpacingXSmall),
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
          // Favorites tab
          _buildFavoritesTab(context),
        ],
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
          padding: const EdgeInsets.symmetric(
            horizontal: kSpacing12,
            vertical: kSpacing8,
          ),
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
              const SizedBox(height: Spacing.md),
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
                            color: theme.colorScheme.surfaceContainerHighest,
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

class ScrollBar extends StatefulWidget {
  final ScrollController scrollController;

  const ScrollBar({
    super.key,
    required this.scrollController,
  });

  @override
  State<ScrollBar> createState() => _ScrollBarState();
}

class _ScrollBarState extends State<ScrollBar> {
  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_updateScrollPosition);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollPosition();
    });
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateScrollPosition);
    super.dispose();
  }

  void _updateScrollPosition() {
    if (!mounted) return;

    setState(() {
      if (widget.scrollController.hasClients &&
          widget.scrollController.position.maxScrollExtent > 0) {
        _scrollPosition = widget.scrollController.position.pixels /
            widget.scrollController.position.maxScrollExtent;
        // print('Scroll Progress: $_scrollPosition'); // Debug scroll progressr
      } else {
        _scrollPosition = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!widget.scrollController.hasClients ||
            widget.scrollController.position.maxScrollExtent <= 0) {
          return const SizedBox.shrink();
        }

        const horizontalMargins = 32.0;
        final availableWidth = constraints.maxWidth - horizontalMargins;
        final contentWidth =
            widget.scrollController.position.viewportDimension +
                widget.scrollController.position.maxScrollExtent;

        // Calculate proportional scrollbar width
        final visiblePortion = availableWidth / contentWidth;
        final scrollBarWidth =
            (availableWidth * visiblePortion).clamp(35.0, availableWidth * 0.2);

        // Calculate scroll position with boundary protection
        final maxScrollPosition = availableWidth - scrollBarWidth;
        final scrollPosition = (_scrollPosition * maxScrollPosition)
            .clamp(0.0, maxScrollPosition); // Add clamp here

        return Container(
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: kSpacing8),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Positioned(
                left: scrollPosition,
                child: Container(
                  width: scrollBarWidth,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
