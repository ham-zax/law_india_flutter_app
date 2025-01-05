import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../data/models/document_model.dart';
import '../bloc/document/document_bloc.dart';
import '../settings/reading_settings.dart';

class DocumentDetailView extends StatelessWidget {
  final Document? document;
  final DocumentChapter? chapter;
  
  const DocumentDetailView({
    super.key,
    this.document,
    this.chapter,
  }) : assert(document != null || chapter != null);

  static const routeName = '/document-detail';

  @override
  Widget build(BuildContext context) {
    final readingSettings = Provider.of<ReadingSettings>(context);
    
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
    if (chapter != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<DocumentBloc>().add(ChapterViewed(chapter!));
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(document != null 
            ? document!.title 
            : 'Chapter ${chapter!.chapterNumber} - ${chapter!.chapterTitle}'),
        actions: [
          IconButton(
            icon: Icon(Icons.format_size),
            onPressed: () => _showQuickSettings(context, readingSettings),
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            _navigateToPreviousChapter(context);
          } else if (details.primaryVelocity! < 0) {
            _navigateToNextChapter(context);
          }
        },
        onHorizontalDragUpdate: (details) {
          // Add visual feedback during swipe
          if (details.primaryDelta! > 0) {
            // Swiping right
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Previous chapter'),
                duration: Duration(milliseconds: 100),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
              ),
            );
          } else if (details.primaryDelta! < 0) {
            // Swiping left
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Next chapter'),
                duration: Duration(milliseconds: 100),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
              ),
            );
          }
        },
        child: _buildContent(context, readingSettings),
      ),
    );
  }

  Widget _buildQuickSettingsPanel(BuildContext context, ReadingSettings settings) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.text_decrease),
            onPressed: () => settings.updateFontSize(settings.fontSize - 1),
          ),
          Text('${settings.fontSize.toInt()}'),
          IconButton(
            icon: Icon(Icons.text_increase),
            onPressed: () => settings.updateFontSize(settings.fontSize + 1),
          ),
          VerticalDivider(),
          IconButton(
            icon: Icon(Icons.height),
            onPressed: () => settings.updateLineHeight(settings.lineHeight - 0.1),
          ),
          Text('${settings.lineHeight.toStringAsFixed(1)}'),
          IconButton(
            icon: Icon(Icons.height),
            onPressed: () => settings.updateLineHeight(settings.lineHeight + 0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ReadingSettings settings) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(settings.margins),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: chapter != null 
                        ? (int.parse(chapter!.chapterNumber) / document!.chapters.length)
                        : 0.0,
                    ),
                    SizedBox(height: 16),
                    if (document != null)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: document!.chapters.length,
                        itemBuilder: (context, index) {
                          final chapter = document!.chapters[index];
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
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.article, size: 24),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          'Chapter ${chapter.chapterNumber} - ${chapter.chapterTitle}',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right, size: 24),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: chapter!.sections.length,
                        itemBuilder: (context, index) {
                          final section = chapter!.sections[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  '${chapter!.chapterNumber} - ${section.sectionTitle}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: settings.fontSize,
                                    fontFamily: settings.fontFamily,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(settings.margins),
                                    child: SelectableText(
                                      section.content,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontSize: settings.fontSize,
                                        height: settings.lineHeight,
                                        fontFamily: settings.fontFamily,
                                      ),
                                      selectionControls: MaterialTextSelectionControls(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: _buildQuickSettingsPanel(context, settings),
          ),
        ),
      ],
    );
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
