import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/document_model.dart';
import '../documents/document_detail_view.dart';
import '../navigation/document_detail_arguments.dart';
import '../settings/reading_settings.dart';

class FavoriteButton extends StatelessWidget {
  final bool isFavorited;
  final Function(bool)? onChanged;
  final String sectionId;
  final DocumentChapter? navigateToChapter;
  final String? sectionContent;
  final String? sectionTitle;
  final bool enableNavigation;

  const FavoriteButton({
    super.key,
    this.isFavorited = false,
    this.onChanged,
    required this.sectionId,
    this.navigateToChapter,
    this.sectionContent,
    this.sectionTitle,
    this.enableNavigation = false,
  });

  void _handlePress(BuildContext context) {
    if (enableNavigation && navigateToChapter != null) {
      if (sectionContent != null && sectionTitle != null) {
        // Navigate directly to section content
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SectionContentView(
              chapterNumber: navigateToChapter!.chapterNumber,
              sectionTitle: sectionTitle!,
              content: sectionContent!,
              settings: Provider.of<ReadingSettings>(context),
              sectionId: sectionId,
              isFavorited: isFavorited,
            ),
          ),
        );
      } else {
        // Navigate to chapter with section scroll
        Navigator.pushReplacementNamed(
          context,
          DocumentDetailView.routeName,
          arguments: DocumentDetailArguments(
            chapter: navigateToChapter,
            scrollToSectionId: sectionId,
          ),
        );
      }
    } else {
      _toggleFavorite(context);
    }
  }

  void _toggleFavorite(BuildContext context) {
    final settings = Provider.of<ReadingSettings>(context, listen: false);
    final newValue = !isFavorited;
    settings.toggleSectionFavorite(sectionId);
    onChanged?.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      icon: Stack(
        children: [
          Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited ? Colors.red : null,
          ),
          if (enableNavigation)
            Positioned(
              right: 0,
              bottom: 0,
              child: Icon(
                Icons.arrow_forward,
                size: 12,
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
      onPressed: () => _handlePress(context),
      tooltip: enableNavigation ? 'Go to section' : 'Toggle favorite',
    );
  }
}
