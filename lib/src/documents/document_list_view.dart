import 'package:flutter/material.dart';

class DocumentListView extends StatelessWidget {
  const DocumentListView({super.key});

  static const routeName = '/documents';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent Documents Section (Top 20%)
                const Text(
                  'Recent Documents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: List.generate(3, (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildDocumentCard(
                      title: 'Document ${index + 1}',
                      lastAccessed: 'Last accessed 2 days ago',
                    ),
                  )),
                ),
                const SizedBox(height: 16),

                // Categories Section (Middle 20%)
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
                    itemCount: 5,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final categories = [
                        'Constitutional',
                        'Criminal',
                        'Civil',
                        'Corporate',
                        'Tax'
                      ];
                      return ChoiceChip(
                        label: Text(categories[index]),
                        selected: index == 0,
                        onSelected: (selected) {},
                        labelStyle: TextStyle(
                          color: index == 0 ? Colors.white : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // All Documents Section (Bottom 60%)
                const Text(
                  'All Documents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: List.generate(10, (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildDocumentCard(
                      title: 'Document ${index + 1}',
                      subtitle: 'Corporate Law • 5 Sections',
                      showChevron: true,
                    ),
                  )),
                ),
              ],
            ),
          ),
        ),
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
