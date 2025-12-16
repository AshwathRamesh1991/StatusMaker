import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorites_ids';
  final SharedPreferences _prefs;

  FavoritesService(this._prefs);

  static Future<FavoritesService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return FavoritesService(prefs);
  }

  List<String> getFavorites() {
    return _prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<void> toggleFavorite(String contentId) async {
    List<String> current = getFavorites();
    if (current.contains(contentId)) {
      current.remove(contentId);
    } else {
      current.add(contentId);
    }
    await _prefs.setStringList(_favoritesKey, current);
  }

  bool isFavorite(String contentId) {
    return getFavorites().contains(contentId);
  }
}
