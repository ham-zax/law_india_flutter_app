import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings/reading_settings.dart';

class FavoriteButton extends StatefulWidget {
  final bool isFavorited;
  final Function(bool)? onChanged;

  final String sectionId;

  const FavoriteButton({
    super.key,
    this.isFavorited = false,
    this.onChanged,
    required this.sectionId,
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
      onPressed: _toggleFavorite,
    );
  }
}
