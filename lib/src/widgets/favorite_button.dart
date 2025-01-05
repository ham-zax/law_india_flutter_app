import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/document_model.dart';
import '../settings/reading_settings.dart';
import '../documents/document_detail_view.dart';
import '../navigation/navigation_types.dart';

class FavoriteButton extends StatefulWidget {
  final bool isFavorited;
  final Function(bool)? onChanged;
  final String sectionId;
  // Add optional navigation context
  final DocumentChapter? navigateToChapter;
  final bool enableNavigation;

  const FavoriteButton({
    super.key,
    this.isFavorited = false,
    this.onChanged,
    required this.sectionId,
    this.navigateToChapter,
    this.enableNavigation = false,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool _isFavorited;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.isFavorited;
  }

  void _handlePress() {
    if (widget.enableNavigation && widget.navigateToChapter != null) {
      // Handle navigation
      Navigator.pushNamed(
        context,
        DocumentDetailView.routeName,
        arguments: DocumentDetailArguments(
          chapter: widget.navigateToChapter,
          scrollToSectionId: widget.sectionId,
        ),
      );
    } else {
      // Handle toggle
      _toggleFavorite();
    }
  }

  void _toggleFavorite() {
    final settings = Provider.of<ReadingSettings>(context, listen: false);
    setState(() {
      _isFavorited = !_isFavorited;
    });
    settings.toggleSectionFavorite(widget.sectionId);
    widget.onChanged?.call(_isFavorited);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isFavorited ? Icons.favorite : Icons.favorite_border,
        color: _isFavorited ? Colors.red : null,
      ),
      onPressed: _handlePress,
    );
  }
}
