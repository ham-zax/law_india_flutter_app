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
      ),
      body: document != null
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
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
          : ListView.builder(
              padding: const EdgeInsets.all(16),
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
                    fontSize: readingSettings.fontSize,
                    fontFamily: readingSettings.fontFamily,
                  ),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(readingSettings.margins),
                    child: Text(
                      section.content,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: readingSettings.fontSize,
                        height: readingSettings.lineHeight,
                        fontFamily: readingSettings.fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(document != null 
                ? document!.title 
                : 'Chapter ${chapter!.chapterNumber} - ${chapter!.chapterTitle}'),
          ),
          body: document != null
              ? ListView.builder(
                  padding: const EdgeInsets.all(16),
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
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
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
                              fontSize: readingSettings.fontSize,
                              fontFamily: readingSettings.fontFamily,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(readingSettings.margins),
                              child: Text(
                                section.content,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontSize: readingSettings.fontSize,
                                  height: readingSettings.lineHeight,
                                  fontFamily: readingSettings.fontFamily,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        buildReadingControls(),
      ],
    );
  }
}
