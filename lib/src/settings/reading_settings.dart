import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingSettings extends ChangeNotifier {
  // Persistence keys
  static const String _fontSizeKey = 'fontSize';
  static const String _lineHeightKey = 'lineHeight';
  static const String _marginsKey = 'margins';
  static const String _favoritesKey = 'favorites';

  // Bounds constants
  static const double minFontSize = 12.0;
  static const double maxFontSize = 32.0;
  static const double minLineHeight = 1.0;
  static const double maxLineHeight = 2.5;
  static const double minMargins = 8.0;
  static const double maxMargins = 32.0;

  // Default values
  double _fontSize = 16.0;
  double _lineHeight = 1.6;
  String _fontFamily = 'Roboto';
  ThemeMode _themeMode = ThemeMode.system;
  double _margins = 16.0;
  final Set<String> _favoriteSections = {};

  // Getters
  double get fontSize => _fontSize;
  double get lineHeight => _lineHeight;
  String get fontFamily => _fontFamily;
  ThemeMode get themeMode => _themeMode;
  double get margins => _margins;
  Set<String> get favoriteSections => _favoriteSections;

  ReadingSettings() {
    _loadSettings();
  }

  // Load saved settings
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _fontSize = prefs.getDouble(_fontSizeKey) ?? 16.0;
    _lineHeight = prefs.getDouble(_lineHeightKey) ?? 1.6;
    _margins = prefs.getDouble(_marginsKey) ?? 16.0;

    final favorites = prefs.getStringList(_favoritesKey);
    if (favorites != null) {
      _favoriteSections.addAll(favorites);
    }
    notifyListeners();
  }

  // Save settings
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble(_fontSizeKey, _fontSize);
    await prefs.setDouble(_lineHeightKey, _lineHeight);
    await prefs.setDouble(_marginsKey, _margins);
    await prefs.setStringList(_favoritesKey, _favoriteSections.toList());
  }

  void toggleSectionFavorite(String sectionId) {
    if (_favoriteSections.contains(sectionId)) {
      _favoriteSections.remove(sectionId);
    } else {
      _favoriteSections.add(sectionId);
    }
    _saveSettings();
    notifyListeners();
  }

  bool isSectionFavorite(String sectionId) {
    return _favoriteSections.contains(sectionId);
  }

  void updateFontSize(double size) {
    if (size >= minFontSize && size <= maxFontSize) {
      _fontSize = size;
      _saveSettings();
      notifyListeners();
    }
  }

  void updateLineHeight(double height) {
    if (height >= minLineHeight && height <= maxLineHeight) {
      _lineHeight = height;
      _saveSettings();
      notifyListeners();
    }
  }

  void updateFontFamily(String family) {
    _fontFamily = family;
    _saveSettings();
    notifyListeners();
  }

  void updateThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveSettings();
    notifyListeners();
  }

  void updateMargins(double margins) {
    if (margins >= minMargins && margins <= maxMargins) {
      _margins = margins;
      _saveSettings();
      notifyListeners();
    }
  }
}
