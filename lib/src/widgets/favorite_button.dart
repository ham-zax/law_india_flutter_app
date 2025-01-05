import 'package:flutter/material.dart';

class FavoriteButton extends StatefulWidget {
  final bool isFavorited;
  final int favoriteCount;
  final Function(bool)? onChanged;

  const FavoriteButton({
    super.key,
    this.isFavorited = false,
    this.favoriteCount = 0,
    this.onChanged,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool _isFavorited;
  late int _favoriteCount;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.isFavorited;
    _favoriteCount = widget.favoriteCount;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
      _favoriteCount += _isFavorited ? 1 : -1;
    });
    widget.onChanged?.call(_isFavorited);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            _isFavorited ? Icons.favorite : Icons.favorite_border,
            color: _isFavorited ? Colors.red : null,
          ),
          onPressed: _toggleFavorite,
        ),
        Text('$_favoriteCount'),
      ],
    );
  }
}
