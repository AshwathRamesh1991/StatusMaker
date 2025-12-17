import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/content_model.dart';
import '../models/user_model.dart';
import '../services/query_service.dart';
import '../services/favorites_service.dart';
import '../widgets/content_render_widget.dart';

class ContentScreen extends StatefulWidget {
  final UserModel user;
  final List<String> languages;
  final List<String> categories;
  final List<ContentType>? types;
  final bool showFavorites;

  const ContentScreen({
    super.key,
    required this.user,
    this.languages = const [],
    this.categories = const [],
    this.types,
    this.showFavorites = false,
  });

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  // We keep a local list that grows as the user scrolls
  final List<ContentItem> _displayItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    // Simulate slight delay for effect
    await Future.delayed(const Duration(milliseconds: 500));

    if (widget.showFavorites) {
      // Favorites mode: Load all once (Finite)
      final favService = context.read<FavoritesService>();
      final items = favService.getFavorites();
      // final items = QueryService().getByIds(favIds); // No longer needed
      if (mounted) {
        setState(() {
          _displayItems.addAll(items);
          _isLoading = false;
        });
      }
    } else {
      // Infinite Mode: Load first few items
      // We don't need to load many, PageView builds lazily.
      // Just ensure we have at least one to show if available.
      _loadMoreItems(3);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _loadMoreItems(int count) {
    if (widget.showFavorites) return; // Favorites are static

    for (int i = 0; i < count; i++) {
      final item = QueryService().getNextItem(
        widget.languages,
        widget.categories,
        types: widget.types,
      );
      if (item != null) {
        _displayItems.add(item);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Immersive
      extendBodyBehindAppBar: true,
      appBar: widget.showFavorites
          ? null // No AppBar for Favorites (or custom one if needed, but definitely no back button)
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    widget.showFavorites
                        ? 'Loading Favorites...'
                        : 'Generating Magic...',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          : _displayItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.sentiment_dissatisfied,
                    color: Colors.white70,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.showFavorites
                        ? 'No favorites yet!'
                        : 'No content found for your selection.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          : PageView.builder(
              scrollDirection: Axis.vertical,
              // If favorites, finite count. If infinite mode, null (infinite).
              itemCount: widget.showFavorites ? _displayItems.length : null,
              itemBuilder: (context, index) {
                // Logic to ensure we have item at index
                if (!widget.showFavorites && index >= _displayItems.length) {
                  _loadMoreItems(1);
                  // If still empty after trying to load, we probably ran out of content permanently (shouldn't happen with cyclic logic)
                  // or filters are invalid.
                  if (index >= _displayItems.length) return null;
                }

                // Safety check
                if (index >= _displayItems.length) return null;

                return ContentRenderWidget(
                  item: _displayItems[index],
                  user: widget.user,
                );
              },
            ),
    );
  }
}
