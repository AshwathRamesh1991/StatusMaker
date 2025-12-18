import '../models/content_model.dart';

import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

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

  // 'assets/images/bg1.png', // Removed static list in favor of dynamic loading
  // 'assets/images/bg2.png',
  // 'assets/images/bg3.png',

  static final List<String> videoPaths = [
    'assets/videos/festival_diwali.mp4',
    // Add more video paths here as they become available
  ];

  static List<ContentItem> _allContent = [];

  static List<ContentItem> get allContent => _allContent;

  static Future<void> loadData() async {
    try {
      print("[DataService] Loading data initiating...");

      // Initialize with our robust manual map effectively guaranteed to exist
      List<String> allImageAssets = [
        // Motivation
        'assets/images/motivation/motivation_0_131111.png',
        'assets/images/motivation/motivation_1_133252.png',
        'assets/images/motivation/motivation_2_133319.png',
        'assets/images/motivation/motivation_3_133349.png',
        'assets/images/motivation/motivation_4_133418.png',
        // Love
        'assets/images/love/love_0_132859.png',
        'assets/images/love/love_1_132926.png',
        'assets/images/love/love_2_132956.png',
        'assets/images/love/love_3_133027.png',
        'assets/images/love/love_4_133057.png',
        // Funny
        'assets/images/funny/funny_0_123311.png',
        'assets/images/funny/funny_1_133928.png',
        'assets/images/funny/funny_2_133955.png',
        'assets/images/funny/funny_3_134023.png',
        'assets/images/funny/funny_4_134051.png',
        // Friendship
        'assets/images/friendship/friendship_0_134216.png',
        'assets/images/friendship/friendship_1_134248.png',
        'assets/images/friendship/friendship_2_134320.png',
        'assets/images/friendship/friendship_3_134351.png',
        'assets/images/friendship/friendship_4_134419.png',
        'assets/images/friendship/friendship_6_134515.png',
        // Good Morning
        'assets/images/good_morning/good_morning_0_132127.png',
        'assets/images/good_morning/good_morning_1_132203.png',
        'assets/images/good_morning/good_morning_2_132239.png',
        'assets/images/good_morning/good_morning_3_132315.png',
        'assets/images/good_morning/good_morning_4_132351.png',
        // Good Night
        'assets/images/good_night/good_night_0_132535.png',
        'assets/images/good_night/good_night_1_132608.png',
        'assets/images/good_night/good_night_2_132636.png',
        'assets/images/good_night/good_night_3_132706.png',
        'assets/images/good_night/good_night_4_132734.png',
        // Poetry
        'assets/images/poetry/poetry_0_123241.png',
        'assets/images/poetry/poetry_1_133613.png',
        'assets/images/poetry/poetry_2_133641.png',
        'assets/images/poetry/poetry_3_133709.png',
        'assets/images/poetry/poetry_4_133737.png',
        // Misc / Fallbacks
        'assets/images/misc/good_morning_0_132127.png',
        'assets/images/bg1.png',
        'assets/images/bg2.png',
        'assets/images/bg3.png',
      ];

      try {
        // Load AssetManifest to get all available assets
        final manifestContent = await rootBundle.loadString(
          'AssetManifest.json',
        );
        final Map<String, dynamic> manifestMap = json.decode(manifestContent);
        print(
          "[DataService] AssetManifest loaded. Total keys: ${manifestMap.length}",
        );

        // Filter for image assets in our directories
        final manifestAssets = manifestMap.keys
            .where((String key) => key.startsWith('assets/images/'))
            .toList();

        print(
          "[DataService] Image assets found in manifest: ${manifestAssets.length}",
        );

        // Merge without duplicates
        for (var asset in manifestAssets) {
          if (!allImageAssets.contains(asset)) {
            allImageAssets.add(asset);
          }
        }
      } catch (e) {
        print(
          "[DataService] WARNING: Failed to load AssetManifest.json (likely missing or different format): $e",
        );
        // We already have the hardcoded list, so no action needed.
      }

      final String response = await rootBundle.loadString(
        'assets/data/quotes.json',
      );
      final List<dynamic> data = json.decode(response);
      print("[DataService] Quotes JSON loaded. Items: ${data.length}");
      final Random random = Random();

      // Map to track available images for each category to ensure non-repeating cycle
      Map<String, List<String>> categoryImagePools = {};
      // Track last used image to prevent cycle-boundary repetition
      Map<String, String> lastUsedImagePerCategory = {};

      _allContent = data
          .asMap()
          .map((index, item) {
            String category = item['category'] ?? 'General';

            // Normalize category for matching
            String normalizedCategory = category
                .toLowerCase()
                .trim()
                .replaceAll(' ', '_');
            if (normalizedCategory == 'motivational')
              normalizedCategory = 'motivation';

            // 1. Try Video First
            List<String> categoryVideos = videoPaths.where((path) {
              return path.toLowerCase().contains(normalizedCategory);
            }).toList();

            bool useVideo =
                categoryVideos.isNotEmpty && random.nextDouble() < 0.3;
            String bgPath;
            ContentType type;

            if (useVideo) {
              type = ContentType.video;
              bgPath = categoryVideos[random.nextInt(categoryVideos.length)];
            } else {
              type = ContentType.image;

              // 2. Image Selection with "Deck of Cards" logic
              // Check if we have a pool for this category
              if (!categoryImagePools.containsKey(category) ||
                  categoryImagePools[category]!.isEmpty) {
                // Refill the pool
                List<String> freshImages = getCategoryImages(
                  category,
                  allImageAssets,
                );
                print(
                  "[DataService] Refilling pool for '$category'. Found ${freshImages.length} images.",
                );
                if (category == 'Love') {
                  print("[DataService] Love images: $freshImages");
                }

                // Shuffle so the order is random each refill
                freshImages.shuffle(random);

                // CRITICAL: Prevent back-to-back repetition across refills
                // If the next image to be popped (last) is same as the one we just used...
                if (lastUsedImagePerCategory.containsKey(category) &&
                    freshImages.isNotEmpty &&
                    freshImages.last == lastUsedImagePerCategory[category]) {
                  // Swap with the first element (if we have more than 1 image)
                  if (freshImages.length > 1) {
                    print(
                      "[DataService] Avoiding back-to-back repeat for $category",
                    );
                    String temp = freshImages.last;
                    freshImages[freshImages.length - 1] = freshImages.first;
                    freshImages[0] = temp;
                  }
                }

                categoryImagePools[category] = freshImages;
              }

              // Pop one image from the pool
              bgPath = categoryImagePools[category]!.removeLast();
              // Track it as "last used" for the next cycle check
              lastUsedImagePerCategory[category] = bgPath;
            }

            return MapEntry(
              index,
              ContentItem(
                id: 'quote_$index', // Deterministic ID
                type: type,
                text: item['text'],
                backgroundPath: bgPath,
                language: item['language'],
                category: item['category'],
                tags: _generateTags(
                  item['category'],
                  item['language'],
                  bgPath,
                  item['text'],
                ),
              ),
            );
          })
          .values
          .toList();
      print(
        "[DataService] _allContent populated. Count: ${_allContent.length}",
      );
    } catch (e, stack) {
      print("[DataService] Error loading quotes: $e");
      print(stack);
      // Fallback empty or previously loaded
      _allContent = [];
    }
  }

  // Returns all available images for a category (with fallback)
  static List<String> getCategoryImages(
    String category,
    List<String> allAssets,
  ) {
    // 1. Map category to folder name
    String normalizedCategory = category.toLowerCase().trim().replaceAll(
      ' ',
      '_',
    );
    if (normalizedCategory == 'motivational') normalizedCategory = 'motivation';

    // 2. Filter assets for this category
    List<String> categoryAssets = allAssets.where((path) {
      return path.contains('/$normalizedCategory/');
    }).toList();

    // 3. Fallback to misc if no assets found for category
    if (categoryAssets.isEmpty) {
      categoryAssets = allAssets.where((path) {
        return path.contains('/misc/');
      }).toList();
    }

    // 4. Absolute fallback if misc is empty
    if (categoryAssets.isEmpty) {
      categoryAssets = allAssets; // Use everything
    }

    if (categoryAssets.isEmpty) {
      // Hard fallback if absolutely nothing found
      return ['assets/images/bg1.png'];
    }

    return categoryAssets;
  }

  static List<String> _generateTags(
    String category,
    String language,
    String path,
    String text,
  ) {
    Set<String> tags = {};
    // 1. Core Tags
    tags.add(category.toLowerCase());
    tags.add(language.toLowerCase());

    // 2. Path Tags (e.g. 'love' from 'assets/images/love/...')
    // Split path by separators and take meaningful segments
    final segments = path.split(RegExp(r'[/\\]'));
    for (var segment in segments) {
      if (!segment.startsWith('assets') &&
          !segment.contains('.') &&
          segment.length > 2) {
        tags.add(segment.toLowerCase());
      }
    }

    // 3. Simple Text Keywords (very basic tokenization)
    final words = text.toLowerCase().split(' ');
    for (var word in words) {
      if (word.length > 3) {
        // remove punctuation
        word = word.replaceAll(RegExp(r'[^\w\s]+'), '');
        if (word.isNotEmpty) tags.add(word);
      }
    }

    return tags.toList();
  }

  static List<ContentItem> searchContent(String query) {
    if (query.isEmpty) return _allContent;

    // Split query into distinct lower-case words (tokens)
    final queryWords = query.toLowerCase().trim().split(RegExp(r'\s+'));

    return _allContent.where((item) {
      // item matches only if ALL query words are found in its properties
      // (AND logic for multi-word search)
      return queryWords.every((word) {
        bool inText = item.text.toLowerCase().contains(word);
        bool inCategory = item.category.toLowerCase().contains(word);
        bool inLanguage = item.language.toLowerCase().contains(word);
        bool inTags = item.tags.any((tag) => tag.contains(word));

        return inText || inCategory || inLanguage || inTags;
      });
    }).toList();
  }
}
