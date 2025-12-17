import 'package:shared_preferences/shared_preferences.dart';
import '../models/content_model.dart';

class FavoritesService {
  static const String _favoritesKey =
      'favorites_snapshots'; // Changed key to avoid conflict
  final SharedPreferences _prefs;

  FavoritesService(this._prefs);

  static Future<FavoritesService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return FavoritesService(prefs);
  }

  /// Returns the list of fully reconstituted ContentItems
  List<ContentItem> getFavorites() {
    final List<String> jsonList = _prefs.getStringList(_favoritesKey) ?? [];
    return jsonList.map((jsonStr) => ContentItem.fromJson(jsonStr)).toList();
  }

  /// Toggles favorite status by saving/removing the FULL object snapshot
  Future<void> toggleFavorite(ContentItem item) async {
    final List<String> currentJsonList =
        _prefs.getStringList(_favoritesKey) ?? [];

    // Check if item with this ID exists
    final index = currentJsonList.indexWhere((jsonStr) {
      final existing = ContentItem.fromJson(jsonStr);
      return existing.id == item.id;
    });

    if (index != -1) {
      // Exists -> Remove it
      currentJsonList.removeAt(index);
    } else {
      // Doesn't exist -> Add snapshot
      // Ensure isFavorite is true in the snapshot
      final snapshotItem = ContentItem(
        id: item.id,
        type: item.type,
        text: item.text,
        backgroundPath: item.backgroundPath,
        language: item.language,
        category: item.category,
        tags: item.tags,
        isFavorite: true,
      );
      currentJsonList.add(snapshotItem.toJson());
    }
    await _prefs.setStringList(_favoritesKey, currentJsonList);
  }

  bool isFavorite(String contentId) {
    // We strictly check if ANY stored snapshot has this ID
    final List<String> jsonList = _prefs.getStringList(_favoritesKey) ?? [];
    return jsonList.any((jsonStr) {
      final item = ContentItem.fromJson(jsonStr);
      return item.id == contentId;
    });
  }
}
