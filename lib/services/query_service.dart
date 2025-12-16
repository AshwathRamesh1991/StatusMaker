import 'dart:math';
import '../models/content_model.dart';
import 'data_service.dart';

class QueryService {
  // Singleton pattern
  static final QueryService _instance = QueryService._internal();
  factory QueryService() => _instance;
  QueryService._internal();

  final List<String> _seenContentIds = [];
  final Random _random = Random();

  List<ContentItem> _allContent = [];

  void initialize() {
    _allContent = DataService.allContent;
  }

  List<ContentItem> getContent(String language, String category) {
    // Filter by language and category
    List<ContentItem> filtered = _allContent
        .where(
          (item) =>
              (item.language == language ||
                  item.language ==
                      'English') && // Include English as fallback or mixed
              item.category == category,
        )
        .toList();

    // Remove seen items
    List<ContentItem> unseen = filtered
        .where((item) => !_seenContentIds.contains(item.id))
        .toList();

    if (unseen.isEmpty) {
      // If all seen, reset for this category or just return seen ones randomly
      // Specification says "It should not give the same suggestion before exhausting the rest"
      // So if exhausted, we can reset or just return empty to trigger "No more content"
      // Let's reset seen list for these specific items to allow re-viewing effectively in a loop,
      // or just return from all filtered (shuffled).
      return []; // Deprecated in favor of getNextItem for the reels UI
    }

    return _shuffle(unseen);
  }

  ContentItem? getNextItem(String language, String category) {
    // Filter by language and category
    List<ContentItem> filtered = _allContent
        .where((item) => item.language == language && item.category == category)
        .toList();

    if (filtered.isEmpty) return null;

    // Filter out seen items
    List<ContentItem> unseen = filtered
        .where((item) => !_seenContentIds.contains(item.id))
        .toList();

    // If all items seen, reset seen list for these items to allow looping
    if (unseen.isEmpty) {
      for (var item in filtered) {
        _seenContentIds.remove(item.id);
      }
      unseen = filtered;
    }

    // Pick a random unseen item
    final item = unseen[_random.nextInt(unseen.length)];
    _seenContentIds.add(item.id);
    return item;
  }

  ContentItem? getById(String id) {
    try {
      return _allContent.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  List<ContentItem> getByIds(List<String> ids) {
    return _allContent.where((item) => ids.contains(item.id)).toList();
  }

  List<ContentItem> _shuffle(List<ContentItem> items) {
    var list = List<ContentItem>.from(items);
    list.shuffle(_random);
    return list;
  }
}
