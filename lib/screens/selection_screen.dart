import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/content_model.dart';
import '../services/data_service.dart';
import 'content_screen.dart';
import 'create_status_screen.dart';
import 'profile_screen.dart';

class SelectionScreen extends StatefulWidget {
  final UserModel user;
  const SelectionScreen({super.key, required this.user});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  int _selectedIndex = 0;
  late UserModel _currentUser;

  // Multi-select state
  final List<String> _selectedLanguages = [];
  final List<String> _selectedCategories = [];
  final List<String> _selectedFormats = [];

  final List<String> _formats = ['Video', 'Image', 'GIF'];

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  void _updateUser(UserModel newUser) {
    setState(() {
      _currentUser = newUser;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleSelection(List<String> list, String item) {
    setState(() {
      if (list.contains(item)) {
        list.remove(item);
      } else {
        list.add(item);
      }
    });
  }

  void _navigateToContent() {
    // If no filters selected, maybe warn user or allow "All" (Empty lists = All in QueryService)
    if (_selectedLanguages.isEmpty &&
        _selectedCategories.isEmpty &&
        _selectedFormats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one filter')),
      );
      return;
    }

    // Map String formats to ContentType
    List<ContentType> types = [];
    if (_selectedFormats.contains('Video')) types.add(ContentType.video);
    if (_selectedFormats.contains('Image')) types.add(ContentType.image);
    if (_selectedFormats.contains('GIF')) types.add(ContentType.gif);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentScreen(
          user: _currentUser,
          languages: _selectedLanguages,
          categories: _selectedCategories,
          types: types,
          showFavorites: false,
        ),
      ),
    );
  }

  Widget _buildSelectionBody() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Row(
                  children: [
                    Text(
                      'Hi, ${_currentUser.name}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // 1. Language Row
                Text(
                  'Languages',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: DataService.languages.map((lang) {
                      final isSelected = _selectedLanguages.contains(lang);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(lang),
                          selected: isSelected,
                          onSelected: (_) =>
                              _toggleSelection(_selectedLanguages, lang),
                          backgroundColor: Colors.white10,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.white24,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Mood Row
                Text(
                  'Moods',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: DataService.categories.map((cat) {
                      final isSelected = _selectedCategories.contains(cat);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) =>
                              _toggleSelection(_selectedCategories, cat),
                          backgroundColor: Colors.white10,
                          selectedColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.white24,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Format Row
                Text(
                  'Formats',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _formats.map((fmt) {
                      final isSelected = _selectedFormats.contains(fmt);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(fmt),
                          selected: isSelected,
                          onSelected: (_) =>
                              _toggleSelection(_selectedFormats, fmt),
                          backgroundColor: Colors.white10,
                          selectedColor:
                              Colors.teal, // Distinct color for formats
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.white24,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Generate Button (Pinned to bottom of body)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF16213E),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _navigateToContent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Generate Magic',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.auto_awesome),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine body based on selected index
    Widget body;
    switch (_selectedIndex) {
      case 0:
        body = _buildSelectionBody();
        break;
      case 1:
        // Favorites
        // Reuse ContentScreen but maybe wrapped to hide back button?
        // Actually ContentScreen is a Scaffold. If we put Scaffold inside Scaffold body, it's okay but not ideal.
        // For now, let's just use it. We might need to update ContentScreen to hide AppBar if showFavorites is true
        // OR wrapper.
        body = ContentScreen(user: _currentUser, showFavorites: true);
        break;
      case 2:
        body = CreateStatusScreen(user: _currentUser);
        break;
      case 3:
        body = ProfileScreen(user: _currentUser, onUpdate: _updateUser);
        break;
      default:
        body = _buildSelectionBody();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Application background
      // Only show AppBar on Home tab (0) if needed, or customize per tab
      appBar: _selectedIndex == 0
          ? AppBar(
              title: const Text('Design Your Stream'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.white,
              automaticallyImplyLeading:
                  false, // Don't show back button to Login
            )
          : null,
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType
            .fixed, // Use fixed for 4 items to show labels
        backgroundColor: const Color(0xFF0F3460),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.white60,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 32), // Emphasized
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: _currentUser.imagePath != null
                ? CircleAvatar(
                    radius: 12,
                    backgroundImage: FileImage(File(_currentUser.imagePath!)),
                  )
                : const Icon(Icons.person),
            label: 'You',
          ),
        ],
      ),
    );
  }
}
