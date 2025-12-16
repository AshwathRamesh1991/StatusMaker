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

  List<ContentItem> getContent(
    List<String> languages,
    List<String> categories, [
    List<ContentType>? types,
  ]) {
    // Filter by language and category
    List<ContentItem> filtered = _allContent.where((item) {
      final langMatch =
          languages.isEmpty ||
          languages.contains(item.language) ||
          (languages.contains('English') && item.language == 'English');
      final catMatch = categories.isEmpty || categories.contains(item.category);
      final typeMatch =
          types == null || types.isEmpty || types.contains(item.type);
      return langMatch && catMatch && typeMatch;
    }).toList();

    // Remove seen items
    List<ContentItem> unseen = filtered
        .where((item) => !_seenContentIds.contains(item.id))
        .toList();

    if (unseen.isEmpty) {
      return [];
    }

    return _shuffle(unseen);
  }

  ContentItem? getNextItem(
    List<String> languages,
    List<String> categories, {
    List<ContentType>? types,
  }) {
    // Filter by language and category
    List<ContentItem> filtered = _allContent.where((item) {
      final langMatch =
          languages.isEmpty ||
          languages.contains(item.language) ||
          (languages.contains('English') && item.language == 'English');
      final catMatch = categories.isEmpty || categories.contains(item.category);
      final typeMatch =
          types == null || types.isEmpty || types.contains(item.type);
      return langMatch && catMatch && typeMatch;
    }).toList();

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
