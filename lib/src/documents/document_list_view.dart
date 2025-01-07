import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../search/document_search_delegate.dart';
import '../settings/reading_settings.dart';
import '../data/models/document_model.dart';
import '../bloc/document/document_bloc.dart';
import 'document_detail_view.dart';

const double kSpacing4 = 4.0; // For minimal spacing
const double kSpacing8 = 8.0; // For standard spacing
const double kSpacing12 = 12.0; // For content padding
const double kSpacing16 = 16.0; // For section padding

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
            padding: const EdgeInsets.symmetric(
              horizontal: kSpacing12,
              vertical: kSpacing8,
            ),
            itemCount: favoriteSections.length,
            itemBuilder: (context, index) {
              final favorite = favoriteSections[index];
              final sectionId =
                  '${favorite.chapter.id}_${favorite.section.sectionNumber}';

              return Card(
                margin: const EdgeInsets.only(bottom: kSpacing4),
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
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          top: 16,
                          bottom: 16,
                          right: 48, // Increased to accommodate heart icon
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
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
                            const SizedBox(width: kSpacing12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    favorite.section.sectionTitle.replaceFirst(
                                      RegExp(r'^\d+\.\s*'),
                                      '',
                                    ),
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: kSpacing8),
                                  Column(
                                    children: [
                                      const SizedBox(height: kSpacing8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Transform.translate(
                                            offset: const Offset(24, 0),
                                            child: Text(
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
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () {
                            settings.toggleSectionFavorite(sectionId);
                          },
                        ),
                      ),
                    ],
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
        titleSpacing: kSpacing8,
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
                          horizontal: kSpacing12,
                          vertical: kSpacing8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.recentSections.isNotEmpty) ...[
                              Text(
                                'Continue Reading',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      letterSpacing: -0.5,
                                    ),
                              ),
                              const SizedBox(height: kSpacing8),
                              SizedBox(
                                height: 64,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start, // Add this
                                  children: [
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      controller: _scrollController,
                                      child: Row(
                                        mainAxisSize:
                                            MainAxisSize.min, // Add this
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                    const SizedBox(height: kSpacing8),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(top: kSpacing8),
                                      child: ScrollBar(
                                        scrollController: _scrollController,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kSpacing12,
                        vertical: kSpacing8,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final chapter =
                                state.documents.first.chapters[index];
                            return Card(
                              margin: EdgeInsets.symmetric(
                                vertical: 2,
                              ),
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
                                    horizontal: kSpacing12,
                                    vertical: kSpacing8,
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
                                      const SizedBox(width: kSpacing8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ..._buildTitleParts(
                                                context, chapter.chapterTitle,
                                                isBold: true),
                                            const SizedBox(height: kSpacing4),
                                            Row(
                                              children: [
                                                Expanded(
                                                    child:
                                                        Container()), // This pushes the text to the right
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
                                          ],
                                        ),
                                      ),
                                    ],
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
      if (widget.scrollController.hasClients) {
        _scrollPosition = widget.scrollController.position.pixels /
            widget.scrollController.position.maxScrollExtent;
      } else {
        _scrollPosition = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalMargins = 32.0;
        final availableWidth = constraints.maxWidth - horizontalMargins;

        // Default track widget that's always visible
        Widget track = Container(
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: kSpacing8),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );

        // Return just the track if no scroll controller or clients
        if (!widget.scrollController.hasClients) {
          return track;
        }

        final contentWidth =
            widget.scrollController.position.viewportDimension +
                widget.scrollController.position.maxScrollExtent;

        final shouldShowThumb =
            contentWidth > widget.scrollController.position.viewportDimension;

        // Return just the track if content fits viewport
        if (!shouldShowThumb) {
          return track;
        }

        // Calculate thumb position and size
        final visiblePortion = availableWidth / contentWidth;
        final scrollBarWidth =
            (availableWidth * visiblePortion).clamp(35.0, availableWidth * 0.2);
        final maxScrollPosition = availableWidth - scrollBarWidth;
        final scrollPosition =
            (_scrollPosition * maxScrollPosition).clamp(0.0, maxScrollPosition);

        // Return track with thumb
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
