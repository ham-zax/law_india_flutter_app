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

  final DocumentDetailArguments arguments;

  const DocumentDetailView({
    super.key,
    required this.arguments,
  });

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
      if (widget.scrollToSectionId != null) {
        _scrollToSection(widget.scrollToSectionId!);
      }
      _handleScrollPositionChange();
    });
  }

  void _handleScrollPositionChange() {
    _positionsListener.itemPositions.addListener(() {
      final positions = _positionsListener.itemPositions.value;
      if (positions.isNotEmpty) {
        // Store the first visible item index for position restoration
        final firstIndex = positions.first.index;
        // Could save this to your state management solution
      }
    });
  }

  // Add getters to fix undefined properties
  Document? get document => widget.arguments.document;
  DocumentChapter? get chapter => widget.arguments.chapter;
  String? get scrollToSectionId => widget.arguments.scrollToSectionId;

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
  Widget build(BuildContext context) {
    final readingSettings = Provider.of<ReadingSettings>(context);
    
    // Ensure we have either document or chapter
    if (arguments.document == null && arguments.chapter == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('No document or chapter selected')),
      );
    }
    
    // Build reading controls overlay
    Widget buildReadingControls() {
      return Positioned(
        bottom: 16,
        right: 16,
        child: FloatingActionButton(
          child: Icon(Icons.settings),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Reading Settings', style: Theme.of(context).textTheme.titleLarge),
                      Divider(),
                      ListTile(
                        title: Text('Font Size'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.text_decrease),
                              onPressed: () {
                                readingSettings.updateFontSize(
                                  readingSettings.fontSize - 1.0
                                );
                              },
                            ),
                            Text('${readingSettings.fontSize.toInt()}'),
                            IconButton(
                              icon: Icon(Icons.text_increase),
                              onPressed: () {
                                readingSettings.updateFontSize(
                                  readingSettings.fontSize + 1.0
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        title: Text('Line Height'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.height),
                              onPressed: () {
                                readingSettings.updateLineHeight(
                                  readingSettings.lineHeight - 0.1
                                );
                              },
                            ),
                            Text('${readingSettings.lineHeight.toStringAsFixed(1)}'),
                            IconButton(
                              icon: Icon(Icons.height),
                              onPressed: () {
                                readingSettings.updateLineHeight(
                                  readingSettings.lineHeight + 0.1
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        title: Text('Margins'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.format_indent_decrease),
                              onPressed: () {
                                readingSettings.updateMargins(
                                  readingSettings.margins - 4.0
                                );
                              },
                            ),
                            Text('${readingSettings.margins.toInt()}'),
                            IconButton(
                              icon: Icon(Icons.format_indent_increase),
                              onPressed: () {
                                readingSettings.updateMargins(
                                  readingSettings.margins + 4.0
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    }
    // Notify bloc that this chapter was viewed
    if (arguments.chapter != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<DocumentBloc>().add(ChapterViewed(arguments.chapter!));
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(arguments.document?.title ?? 
            'Chapter ${arguments.chapter?.chapterNumber ?? ''} - ${arguments.chapter?.chapterTitle ?? ''}'),
        actions: [
          IconButton(
            icon: Icon(Icons.format_size),
            onPressed: () => _showQuickSettings(context, readingSettings),
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
            if (arguments.document != null) {
              final chapter = arguments.document!.chapters[index];
              return _buildChapterCard(
                context: context,
                title: 'Chapter ${chapter.chapterNumber} - ${chapter.chapterTitle}',
                subtitle: null,
                isSelected: false,
                onTap: () => _navigateToChapter(context, index),
              );
            } else if (arguments.chapter != null) {
              final section = arguments.chapter!.sections[index];
              final sectionId = '${arguments.chapter!.id}_${section.sectionNumber}';
              return _buildSectionCard(
                context: context,
                chapterNumber: arguments.chapter!.chapterNumber,
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
        buildReadingControls(),
      ],
    );
  }

  int _getItemCount() {
    if (arguments.document != null) {
      return arguments.document!.chapters.length;
    } else if (arguments.chapter != null) {
      return arguments.chapter!.sections.length;
    }
    return 0;
  }

  void _scrollToSection(String sectionId) {
    if (arguments.chapter != null) {
      final index = arguments.chapter!.sections.indexWhere(
        (section) => '${arguments.chapter!.id}_${section.sectionNumber}' == sectionId
      );
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
        scrollToSectionId: null, // Reset scroll position for new chapter
      ),
    ).then((_) {
      // Restore scroll position if needed
      _scrollController.jumpTo(index: 0);
    });
  }

  void _showQuickSettings(BuildContext context, ReadingSettings settings) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Reading Settings', style: Theme.of(context).textTheme.titleLarge),
              Divider(),
              ListTile(
                title: Text('Font Size'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.text_decrease),
                      onPressed: () {
                        settings.updateFontSize(settings.fontSize - 1);
                      },
                    ),
                    Text('${settings.fontSize.toInt()}'),
                    IconButton(
                      icon: Icon(Icons.text_increase),
                      onPressed: () {
                        settings.updateFontSize(settings.fontSize + 1);
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text('Line Height'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.height),
                      onPressed: () {
                        settings.updateLineHeight(settings.lineHeight - 0.1);
                      },
                    ),
                    Text('${settings.lineHeight.toStringAsFixed(1)}'),
                    IconButton(
                      icon: Icon(Icons.height),
                      onPressed: () {
                        settings.updateLineHeight(settings.lineHeight + 0.1);
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text('Margins'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.format_indent_decrease),
                      onPressed: () {
                        settings.updateMargins(settings.margins - 4);
                      },
                    ),
                    Text('${settings.margins.toInt()}'),
                    IconButton(
                      icon: Icon(Icons.format_indent_increase),
                      onPressed: () {
                        settings.updateMargins(settings.margins + 4);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToPreviousChapter(BuildContext context) {
    final doc = arguments.document;
    if (doc == null) return;
    
    final currentChapter = arguments.chapter;
    if (currentChapter == null) {
      // If we're at the document level, do nothing
      return;
    }
    
    final currentIndex = doc.chapters.indexWhere(
      (c) => c.chapterNumber == currentChapter.chapterNumber
    );
    
    if (currentIndex > 0) {
      final prevChapter = doc.chapters[currentIndex - 1];
      Navigator.pushReplacementNamed(
        context,
        DocumentDetailView.routeName,
        arguments: prevChapter,
      );
    } else {
      // Show feedback when at first chapter
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You\'re at the first chapter'),
          duration: Duration(milliseconds: 300),
        ),
      );
    }
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

  void _navigateToNextChapter(BuildContext context) {
    final doc = document;
    if (doc == null) return;
    
    final currentChapter = chapter;
    if (currentChapter == null) {
      // If we're at the document level, do nothing
      return;
    }
    
    final currentIndex = doc.chapters.indexWhere(
      (c) => c.chapterNumber == currentChapter.chapterNumber
    );
    
    if (currentIndex < doc.chapters.length - 1) {
      final nextChapter = doc.chapters[currentIndex + 1];
      Navigator.pushReplacementNamed(
        context,
        DocumentDetailView.routeName,
        arguments: nextChapter,
      );
    } else {
      // Show feedback when at last chapter
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You\'ve reached the last chapter'),
          duration: Duration(milliseconds: 300),
        ),
      );
    }
  }
}
