import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: settings.margins,
        vertical: 16,
      ),
      child: SelectableText.rich(
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
        textScaler: MediaQuery.of(context).textScaler,
        selectionControls: MaterialTextSelectionControls(),
      ),
    );
  }
}

class SectionContentView extends StatelessWidget {
  final String chapterNumber;
  final String sectionTitle;
  final String content;
  final ReadingSettings settings;
  final String sectionId;
  final bool isFavorited;

  const SectionContentView({
    super.key,
    required this.chapterNumber,
    required this.sectionTitle,
    required this.content,
    required this.settings,
    required this.sectionId,
    required this.isFavorited,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(sectionTitle),
        actions: [
          Consumer<ReadingSettings>(
            builder: (context, settings, child) {
              return FavoriteButton(
                sectionId: sectionId,
                isFavorited: settings.isSectionFavorite(sectionId),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.share_outlined),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: EnhancedReadingView(
              content: content,
              settings: settings,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  // Change to ElevatedButton
                  onPressed: () => _navigateToPreviousSection(context),
                  icon: Icon(Icons.arrow_back, size: 20),
                  label: Text('Previous'),
                ),
                ElevatedButton.icon(
                  // Change to ElevatedButton
                  onPressed: () => _navigateToNextSection(context),
                  icon: Icon(Icons.arrow_forward, size: 20),
                  label: Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

void _navigateToNextSection(BuildContext context) {
    print("_navigateToNextSection called");
    final bloc = context.read<DocumentBloc>();
    final state = bloc.state;

    if (state is DocumentLoaded) {
      print("Current sectionId: $sectionId");

      // Extract chapter ID correctly
      final parts = sectionId.split('_');
      final chapterId = '${parts[0]}_${parts[1]}_${parts[2]}';
      print("Looking for chapter ID: $chapterId");

      final currentChapter = state.findChapterById(chapterId);
      print("Found chapter: ${currentChapter?.chapterNumber}");

      if (currentChapter != null) {
        final currentSectionIndex = currentChapter.sections.indexWhere(
          (s) => '${currentChapter.id}_${s.sectionNumber}' == sectionId,
        );
        print("Current section index: $currentSectionIndex");

        if (currentSectionIndex < currentChapter.sections.length - 1) {
          // Navigate to next section
          final nextSection = currentChapter.sections[currentSectionIndex + 1];
          final nextSectionId =
              '${currentChapter.id}_${nextSection.sectionNumber}';
          print("Next section ID: $nextSectionId");

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SectionContentView(
                chapterNumber: currentChapter.chapterNumber,
                sectionTitle: nextSection.sectionTitle,
                content: nextSection.content,
                settings: settings,
                sectionId: nextSectionId,
                isFavorited: settings.isSectionFavorite(nextSectionId),
              ),
            ),
          );
        } else {
          // Show completion message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You have completed all sections in this chapter'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        print("Chapter not found for ID: $chapterId");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Could not find the current chapter'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

// Similar simplification for previous section navigation
  void _navigateToPreviousSection(BuildContext context) {
    print("_navigateToPreviousSection called");
    final bloc = context.read<DocumentBloc>();
    final state = bloc.state;

    if (state is DocumentLoaded) {
      final parts = sectionId.split('_');
      final chapterId = '${parts[0]}_${parts[1]}_${parts[2]}';
      final currentChapter = state.findChapterById(chapterId);

      if (currentChapter != null) {
        final currentSectionIndex = currentChapter.sections.indexWhere(
          (s) => '${currentChapter.id}_${s.sectionNumber}' == sectionId,
        );

        if (currentSectionIndex > 0) {
          final previousSection =
              currentChapter.sections[currentSectionIndex - 1];
          final previousSectionId =
              '${currentChapter.id}_${previousSection.sectionNumber}';

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SectionContentView(
                chapterNumber: currentChapter.chapterNumber,
                sectionTitle: previousSection.sectionTitle,
                content: previousSection.content,
                settings: settings,
                sectionId: previousSectionId,
                isFavorited: settings.isSectionFavorite(previousSectionId),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You are at the first section of this chapter'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
}

class DocumentDetailView extends StatefulWidget {
  static const routeName = '/document-detail';
  final DocumentDetailArguments arguments;

  const DocumentDetailView({
    super.key,
    required this.arguments,
  });

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
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.arguments.chapter != null) {
        context
            .read<DocumentBloc>()
            .add(ChapterViewed(widget.arguments.chapter!));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildChapterCard({
    required BuildContext context,
    required DocumentChapter chapter,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Split title into main title and subtitles
    List<String> titleParts = chapter.chapterTitle.split(' - ');
    String mainTitle = titleParts[0].trim();
    List<String> subtitles = titleParts.length > 1 ? titleParts.sublist(1) : [];

    final Color surfaceColor = isSelected
        ? Color.fromRGBO(colorScheme.primary.red, colorScheme.primary.green,
            colorScheme.primary.blue, 0.08)
        : colorScheme.surface;

    return Card(
      elevation: 0,
      color: surfaceColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      surfaceTintColor: colorScheme.primaryContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  chapter.chapterNumber,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mainTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                        letterSpacing: 0.15,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitles.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      ...subtitles.map((subtitle) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isSelected
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          )),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '${chapter.sections.length} sections',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
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
    required String content,
    required ReadingSettings settings,
    required String sectionId,
    required bool isFavorited,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String cleanTitle(String title) {
      final regex = RegExp(r'^\d+[\.\s-]*\s*');
      return title.replaceFirst(regex, '');
    }

    return Card(
      key: key,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SectionContentView(
                chapterNumber: chapterNumber,
                sectionTitle: sectionTitle,
                content: content,
                settings: settings,
                sectionId: sectionId,
                isFavorited: isFavorited,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.secondaryContainer,
                child: Text(
                  sectionId.split('_').last,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  cleanTitle(sectionTitle),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    letterSpacing: 0.15,
                    height: 1.4,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            onPressed: () => _showSettingsBottomSheet(context),
          ),
        ],
      ),
      body: _buildContent(context, readingSettings),
    );
  }

  Widget _buildContent(BuildContext context, ReadingSettings settings) {
    return SafeArea(
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(settings.margins),
        itemCount: _getItemCount(),
        itemBuilder: (context, index) {
          if (widget.arguments.document != null) {
            final chapter = widget.arguments.document!.chapters[index];
            return _buildChapterCard(
              context: context,
              chapter: chapter,
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
              content: section.content,
              settings: settings,
              sectionId: sectionId,
              isFavorited: settings.isSectionFavorite(sectionId),
            );
          }
          return const SizedBox.shrink();
        },
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

  void _navigateToChapter(BuildContext context, int index) {
    final chapter = widget.arguments.document!.chapters[index];
    Navigator.pushReplacementNamed(
      context,
      DocumentDetailView.routeName,
      arguments: DocumentDetailArguments(
        chapter: chapter,
        scrollToSectionId: null,
      ),
    );
  }
}
