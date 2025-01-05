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
      body: Column(
        children: [
          // Recent Documents Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Documents',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return _buildDocumentCard(
                        title: 'Document ${index + 1}',
                        lastAccessed: 'Last accessed 2 days ago',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Categories Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      return FilterChip(
                        label: Text(categories[index]),
                        selected: index == 0,
                        onSelected: (selected) {},
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // All Documents Section
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: 10,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildDocumentCard(
                  title: 'Document ${index + 1}',
                  subtitle: 'Corporate Law • 5 Sections',
                  showChevron: true,
                );
              },
            ),
          ),
        ],
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
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.article, size: 32),
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
                    Text(
                      lastAccessed,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            if (showChevron) const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
