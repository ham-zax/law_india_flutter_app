import 'package:flutter/material.dart';

class ReadingSettings extends ChangeNotifier {
  double _fontSize = 16.0;
  double _lineHeight = 1.6;
  String _fontFamily = 'Roboto';
  ThemeMode _themeMode = ThemeMode.system;
  double _margins = 16.0;
  final Set<String> _favorites = {};

  double get fontSize => _fontSize;
  double get lineHeight => _lineHeight;
  String get fontFamily => _fontFamily;
  ThemeMode get themeMode => _themeMode;
  double get margins => _margins;
  Set<String> get favorites => _favorites;

  void toggleFavorite(String id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    notifyListeners();
  }

  bool isFavorite(String id) {
    return _favorites.contains(id);
  }

  void updateFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }

  void updateLineHeight(double height) {
    _lineHeight = height;
    notifyListeners();
  }

  void updateFontFamily(String family) {
    _fontFamily = family;
    notifyListeners();
  }

  void updateThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void updateMargins(double margins) {
    _margins = margins;
    notifyListeners();
  }
}
