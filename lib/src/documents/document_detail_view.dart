import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../data/models/document_model.dart';
import '../bloc/document/document_bloc.dart';
import '../settings/reading_settings.dart';
import '../widgets/favorite_button.dart';
import '../navigation/document_detail_arguments.dart';

class EnhancedReadingView extends StatelessWidget {
  final String content;
  final ReadingSettings settings;

  const EnhancedReadingView({
    super.key,
    required this.content,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: settings.margins,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SelectableText.rich(
            TextSpan(
              style: TextStyle(
                fontSize: settings.fontSize,
                height: settings.lineHeight,
                fontFamily: settings.fontFamily,
                color: theme.textTheme.bodyLarge?.color,
              ),
              children: [
                TextSpan(text: content),
              ],
            ),
            textAlign: TextAlign.justify,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            selectionControls: MaterialTextSelectionControls(),
            strutStyle: StrutStyle(
              fontSize: settings.fontSize,
              height: settings.lineHeight,
              leading: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentDetailView extends StatefulWidget {
  static const routeName = '/document-detail';
  final DocumentDetailArguments arguments;

  const DocumentDetailView({
    super.key,
    required this.arguments,
  });

  // Add back the static route method
  static Route<dynamic> route(RouteSettings settings) {
    final args = settings.arguments;
    DocumentDetailArguments arguments;

    if (args is DocumentDetailArguments) {
      arguments = args;
    } else if (args is Map<String, dynamic>) {
      arguments = DocumentDetailArguments.fromMap(args);
    } else if (args is Document) {
      arguments = DocumentDetailArguments(document: args);
    } else if (args is DocumentChapter) {
      arguments = DocumentDetailArguments(chapter: args);
    } else {
      throw ArgumentError('Invalid arguments for DocumentDetailView');
    }

    return MaterialPageRoute(
      settings: settings,
      builder: (context) => DocumentDetailView(arguments: arguments),
    );
  }

  @override
  State<DocumentDetailView> createState() => _DocumentDetailViewState();
}

class _DocumentDetailViewState extends State<DocumentDetailView> {
  late final ItemScrollController _scrollController;
  late final ItemPositionsListener _positionsListener;

  @override
  void initState() {
    super.initState();
    _scrollController = ItemScrollController();
    _positionsListener = ItemPositionsListener.create();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.arguments.scrollToSectionId != null) {
        _scrollToSection(widget.arguments.scrollToSectionId!);
      }
      _handleScrollPositionChange();

      if (widget.arguments.chapter != null) {
        context
            .read<DocumentBloc>()
            .add(ChapterViewed(widget.arguments.chapter!));
      }
    });
  }

  @override
  void dispose() {
    _positionsListener.itemPositions
        .removeListener(_handleScrollPositionChange);
    super.dispose();
  }

  void _handleScrollPositionChange() {
    _positionsListener.itemPositions.addListener(() {
      final positions = _positionsListener.itemPositions.value;
      if (positions.isNotEmpty) {
        final firstIndex = positions.first.index;
        // Save position if needed
      }
    });
  }
Widget _buildChapterCard({
    required BuildContext context,
    required String title,
    String? subtitle,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color surfaceColor = isSelected
        ? Color.alphaBlend(
            colorScheme.primary.withOpacity(0.08),
            colorScheme.surface,
          )
        : colorScheme.surface;

    return Card(
      elevation: 0,
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: Row(
            children: [
              const Icon(Icons.article, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                        letterSpacing: 0.15,
                        height: 1.4,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimaryContainer.withOpacity(0.8)
                              : colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    Key? key,
    required String chapterNumber,
    required String sectionTitle,
    required bool isExpanded,
    required String content,
    required ReadingSettings settings,
    required String sectionId,
    required bool isFavorited,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      key: key,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          title: Row(
            children: [
              const Icon(Icons.article, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '$chapterNumber - $sectionTitle',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    letterSpacing: 0.15,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FavoriteButton(
                        sectionId: sectionId,
                        isFavorited: isFavorited,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  EnhancedReadingView(
                    content: content,
                    settings: settings,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Getters for convenience
  Document? get document => widget.arguments.document;
  DocumentChapter? get chapter => widget.arguments.chapter;
  String? get scrollToSectionId => widget.arguments.scrollToSectionId;

  @override
  Widget build(BuildContext context) {
    final readingSettings = Provider.of<ReadingSettings>(context);

    if (widget.arguments.document == null && widget.arguments.chapter == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('No document or chapter selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.arguments.document?.title ??
            'Chapter ${widget.arguments.chapter?.chapterNumber ?? ''} - ${widget.arguments.chapter?.chapterTitle ?? ''}'),
        actions: [
          IconButton(
            icon: Icon(Icons.format_size),
            onPressed: () =>
                _showSettingsBottomSheet(context), // Updated method name
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! > 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Previous chapter'),
                  duration: Duration(milliseconds: 300),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
                ),
              );
              _navigateToPreviousChapter(context);
            } else if (details.primaryVelocity! < 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Next chapter'),
                  duration: Duration(milliseconds: 300),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
                ),
              );
              _navigateToNextChapter(context);
            }
          }
        },
        child: _buildContent(context, readingSettings),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ReadingSettings settings) {
    return Stack(
      children: [
        ScrollablePositionedList.builder(
          padding: EdgeInsets.all(settings.margins),
          itemCount: _getItemCount(),
          itemScrollController: _scrollController,
          itemPositionsListener: _positionsListener,
          itemBuilder: (context, index) {
            if (widget.arguments.document != null) {
              final chapter = widget.arguments.document!.chapters[index];
              return _buildChapterCard(
                context: context,
                title:
                    'Chapter ${chapter.chapterNumber} - ${chapter.chapterTitle}',
                subtitle: null,
                isSelected: false,
                onTap: () => _navigateToChapter(context, index),
              );
            } else if (widget.arguments.chapter != null) {
              final section = widget.arguments.chapter!.sections[index];
              final sectionId =
                  '${widget.arguments.chapter!.id}_${section.sectionNumber}';
              return _buildSectionCard(
                context: context,
                chapterNumber: widget.arguments.chapter!.chapterNumber,
                sectionTitle: section.sectionTitle,
                isExpanded: scrollToSectionId == sectionId,
                content: section.content,
                settings: settings,
                sectionId: sectionId,
                isFavorited: settings.isSectionFavorite(sectionId),
              );
            }
            return SizedBox.shrink();
          },
        ),
        _buildReadingControls(),
      ],
    );
  }

  Widget _buildReadingControls() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(
        child: Icon(Icons.settings),
        onPressed: () => _showSettingsBottomSheet(context),
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    final settings = Provider.of<ReadingSettings>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildSettingsSheet(settings),
    );
  }

  Widget _buildSettingsSheet(ReadingSettings settings) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Reading Settings',
              style: Theme.of(context).textTheme.titleLarge),
          Divider(),
          _buildSettingsTile(
            title: 'Font Size',
            value: settings.fontSize.toInt().toString(),
            onDecrease: () => settings.updateFontSize(settings.fontSize - 1),
            onIncrease: () => settings.updateFontSize(settings.fontSize + 1),
            decreaseIcon: Icons.text_decrease,
            increaseIcon: Icons.text_increase,
          ),
          _buildSettingsTile(
            title: 'Line Height',
            value: settings.lineHeight.toStringAsFixed(1),
            onDecrease: () =>
                settings.updateLineHeight(settings.lineHeight - 0.1),
            onIncrease: () =>
                settings.updateLineHeight(settings.lineHeight + 0.1),
            decreaseIcon: Icons.height,
            increaseIcon: Icons.height,
          ),
          _buildSettingsTile(
            title: 'Margins',
            value: settings.margins.toInt().toString(),
            onDecrease: () => settings.updateMargins(settings.margins - 4),
            onIncrease: () => settings.updateMargins(settings.margins + 4),
            decreaseIcon: Icons.format_indent_decrease,
            increaseIcon: Icons.format_indent_increase,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String value,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
    required IconData decreaseIcon,
    required IconData increaseIcon,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(decreaseIcon),
            onPressed: onDecrease,
          ),
          Text(value),
          IconButton(
            icon: Icon(increaseIcon),
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }

  int _getItemCount() {
    if (widget.arguments.document != null) {
      return widget.arguments.document!.chapters.length;
    } else if (widget.arguments.chapter != null) {
      return widget.arguments.chapter!.sections.length;
    }
    return 0;
  }

  void _scrollToSection(String sectionId) {
    if (widget.arguments.chapter != null) {
      final index = widget.arguments.chapter!.sections.indexWhere((section) =>
          '${widget.arguments.chapter!.id}_${section.sectionNumber}' ==
          sectionId);
      if (index != -1) {
        _scrollController.scrollTo(
          index: index,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _navigateToChapter(BuildContext context, int index) {
    final chapter = widget.arguments.document!.chapters[index];
    Navigator.pushReplacementNamed(
      context,
      DocumentDetailView.routeName,
      arguments: DocumentDetailArguments(
        chapter: chapter,
        scrollToSectionId: null,
      ),
    ).then((_) {
      _scrollController.jumpTo(index: 0);
    });
  }

  void _navigateToPreviousChapter(BuildContext context) {
    final doc = widget.arguments.document;
    if (doc == null) return;

    final currentChapter = widget.arguments.chapter;
    if (currentChapter == null) return;

    final currentIndex = doc.chapters
        .indexWhere((c) => c.chapterNumber == currentChapter.chapterNumber);

    if (currentIndex > 0) {
      final prevChapter = doc.chapters[currentIndex - 1];
      Navigator.pushReplacementNamed(
        context,
        DocumentDetailView.routeName,
        arguments: prevChapter,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You\'re at the first chapter'),
          duration: Duration(milliseconds: 300),
        ),
      );
    }
  }

  void _navigateToNextChapter(BuildContext context) {
    final doc = document;
    if (doc == null) return;

    final currentChapter = chapter;
    if (currentChapter == null) return;

    final currentIndex = doc.chapters
        .indexWhere((c) => c.chapterNumber == currentChapter.chapterNumber);

    if (currentIndex < doc.chapters.length - 1) {
      final nextChapter = doc.chapters[currentIndex + 1];
      Navigator.pushReplacementNamed(
        context,
        DocumentDetailView.routeName,
        arguments: nextChapter,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You\'ve reached the last chapter'),
          duration: Duration(milliseconds: 300),
        ),
      );
    }
  }

  // The rest of your widget building methods (_buildChapterCard, _buildSectionCard) remain unchanged
  // Just make sure to use widget.arguments where needed
}
