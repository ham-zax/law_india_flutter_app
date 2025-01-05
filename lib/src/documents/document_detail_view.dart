import 'package:flutter/material.dart';
import '../data/models/document_model.dart';

class DocumentDetailView extends StatelessWidget {
  final Document document;
  
  const DocumentDetailView({super.key, required this.document});

  static const routeName = '/document-detail';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.title),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: document.sections.length,
        itemBuilder: (context, index) {
          final section = document.sections[index];
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
                  '${section.chapterNumber} - ${section.sectionTitle}',
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