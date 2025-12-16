import '../models/content_model.dart';

import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/user_model.dart';

class DataService {
  static final List<String> languages = [
    'Hindi',
    'Tamil',
    'Malayalam',
    'Kannada',
    'Marathi',
    'English', // Added English as it's in the JSON
  ];

  static final List<String> categories = [
    'Motivational',
    'Festival Wishes',
    'Love',
    'Devotional',
    'Funny',
  ];

  static final List<String> imagePaths = [
    'assets/images/bg1.png',
    'assets/images/bg2.png',
    'assets/images/bg3.png',
  ];

  static final List<String> videoPaths = [
    'assets/videos/festival_diwali.mp4',
    // Add more video paths here as they become available
  ];

  static List<ContentItem> _allContent = [];

  static List<ContentItem> get allContent => _allContent;

  static Future<void> loadData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/quotes.json',
      );
      final List<dynamic> data = json.decode(response);
      final Random random = Random();

      _allContent = data
          .asMap()
          .map((index, item) {
            // Randomly assign Video or Image (30% chance of video if available, else image)
            bool useVideo = videoPaths.isNotEmpty && random.nextDouble() < 0.3;
            String bgPath;
            ContentType type;

            if (useVideo) {
              type = ContentType.video;
              bgPath = videoPaths[random.nextInt(videoPaths.length)];
            } else {
              type = ContentType.image;
              bgPath = imagePaths[random.nextInt(imagePaths.length)];
            }

            return MapEntry(
              index,
              ContentItem(
                id:
                    DateTime.now().millisecondsSinceEpoch.toString() +
                    index.toString(), // Unique ID
                type: type,
                text: item['text'],
                backgroundPath: bgPath,
                language: item['language'],
                category: item['category'],
              ),
            );
          })
          .values
          .toList();
    } catch (e) {
      print("Error loading quotes: $e");
      // Fallback empty or previously loaded
      _allContent = [];
    }
  }
}
