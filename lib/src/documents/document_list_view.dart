import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'document_detail_view.dart';

import '../bloc/document/document_bloc.dart';

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
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        DocumentDetailView.routeName,
                                        arguments: doc,
                                      );
                                    },
                                    child: _buildDocumentCard(
                                      title: doc.title,
                                      subtitle: '${doc.category} • ${doc.sections.length} Sections',
                                      showChevron: true,
                                    ),
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
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: state.documents.length,
                            itemBuilder: (context, index) {
                              final doc = state.documents[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      DocumentDetailView.routeName,
                                      arguments: doc,
                                    );
                                  },
                                  child: _buildDocumentCard(
                                    title: doc.title,
                                    subtitle: '${doc.category} • ${doc.sections.length} Sections',
                                    showChevron: true,
                                  ),
                                ),
                              );
                            },
                          );
                        },
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


  Widget _buildDocumentCard({
    required String title,
    String? lastAccessed,
    String? subtitle,
    bool showChevron = false,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey.shade300
              : Colors.grey.shade700,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.article, size: 24, color: Colors.blue),
              ),
              const SizedBox(width: 16),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
              if (showChevron)
                Icon(Icons.chevron_right, size: 24, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }
}
