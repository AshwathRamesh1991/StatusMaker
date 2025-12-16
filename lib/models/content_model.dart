import 'dart:convert';

enum ContentType { image, video, gif }

class ContentItem {
  final String id;
  final ContentType type;
  final String text;
  final String backgroundPath; // Path to image or video
  final String language;
  final String category;
  final List<String> tags;
  bool isFavorite;

  ContentItem({
    required this.id,
    required this.type,
    required this.text,
    required this.backgroundPath,
    required this.language,
    required this.category,
    this.tags = const [],
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'text': text,
      'backgroundPath': backgroundPath,
      'language': language,
      'category': category,
      'tags': tags,
      'isFavorite': isFavorite,
    };
  }

  factory ContentItem.fromMap(Map<String, dynamic> map) {
    return ContentItem(
      id: map['id'],
      type: map['type'] == 'video'
          ? ContentType.video
          : map['type'] == 'gif'
          ? ContentType.gif
          : ContentType.image,
      text: map['text'],
      backgroundPath: map['backgroundPath'],
      language: map['language'],
      category: map['category'],
      tags: List<String>.from(map['tags']),
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ContentItem.fromJson(String source) =>
      ContentItem.fromMap(json.decode(source));
}
