import 'dart:io';
import 'package:flutter/material.dart';
import '../models/content_model.dart';
import '../models/user_model.dart';
import '../services/data_service.dart';
import 'content_screen.dart'; // To navigate to content on tap

class SearchScreen extends StatefulWidget {
  final UserModel user;
  const SearchScreen({super.key, required this.user});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ContentItem> _searchResults = [];
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // precise initial load
    _searchResults = List.from(DataService.allContent);
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchResults = DataService.searchContent(query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search quotes, moods, tags...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white70,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Grid
            Expanded(
              child: _searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.white24,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No results found',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // Miniature images
                            childAspectRatio:
                                0.6, // Tall aspect ratio (like reels/status)
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final item = _searchResults[index];
                        return GestureDetector(
                          onTap: () {
                            // On tap, navigate to Content Screen showing just this item (or filtered list)
                            // For simplicity, we just open this single item in a "preview" mode effectively
                            // But ContentScreen logic is complex (list based).
                            // Let's create a simplified view or pass a list containing just this.

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ContentScreen(
                                  user: widget.user,
                                  // Pass these to filter specifically to something close to this item ??
                                  // Actually ContentScreen generates random content based on params.
                                  // It doesn't support passing exact items yet without refactor.
                                  // HACK: for now, we just pass the category/language of the item
                                  // so it generates SIMILAR content.
                                  languages: [item.language],
                                  categories: [item.category],
                                  types: [item.type],
                                  showFavorites: false,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.black45,
                              image: DecorationImage(
                                image: item.backgroundPath.startsWith('assets')
                                    ? AssetImage(item.backgroundPath)
                                          as ImageProvider
                                    : FileImage(File(item.backgroundPath)),
                                fit: BoxFit.cover,
                                opacity: 0.8,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black54],
                                ),
                              ),
                              padding: const EdgeInsets.all(8),
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                item.text,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
