import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/document_model.dart';
import '../bloc/document/document_bloc.dart';

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
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
            margin: const EdgeInsets.only(bottom: 12),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      section.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
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
  }
}
