import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/document/document_bloc.dart';

class DocumentListView extends StatelessWidget {
  const DocumentListView({super.key});

  static const routeName = '/documents';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
      ),
      body: BlocBuilder<DocumentBloc, DocumentState>(
        builder: (context, state) {
          if (state is DocumentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DocumentError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is DocumentLoaded) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recent Documents Section
                      const Text(
                        'Recent Documents',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: state.recentDocuments
                            .map((doc) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildDocumentCard(
                                    title: doc.title,
                                    lastAccessed: 'Last accessed ${_formatDate(doc.lastAccessed)}',
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),

                      // Categories Section
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.categories.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = state.categories[index];
                            return ChoiceChip(
                              label: Text(category),
                              selected: category == state.selectedCategory,
                              onSelected: (selected) {
                                context.read<DocumentBloc>().add(
                                      ChangeCategory(category),
                                    );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // All Documents Section
                      const Text(
                        'All Documents',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: state.documents
                            .map((doc) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildDocumentCard(
                                    title: doc.title,
                                    subtitle: '${doc.category} • ${doc.sections.length} Sections',
                                    showChevron: true,
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const Center(child: Text('No documents found'));
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    }
    return 'Just now';
  }

  Widget _buildDocumentCard({
    required String title,
    String? lastAccessed,
    String? subtitle,
    bool showChevron = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.article, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (lastAccessed != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        lastAccessed,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (showChevron) const Icon(Icons.chevron_right, size: 24),
          ],
        ),
      ),
    );
  }
}
