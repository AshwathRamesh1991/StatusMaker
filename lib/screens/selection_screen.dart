import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/data_service.dart';
import 'content_screen.dart';

class SelectionScreen extends StatefulWidget {
  final UserModel user;
  const SelectionScreen({super.key, required this.user});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  String? _selectedLanguage;
  String? _selectedCategory;

  void _navigateToContent({bool isFavorites = false}) {
    if (!isFavorites &&
        (_selectedLanguage == null || _selectedCategory == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both a language and a category'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentScreen(
          user: widget.user,
          language: _selectedLanguage,
          category: _selectedCategory,
          showFavorites: isFavorites,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Design Your Stream'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Column(
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
                      if (widget.user.imagePath != null)
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: FileImage(
                            File(widget.user.imagePath!),
                          ),
                        )
                      else
                        const CircleAvatar(child: Icon(Icons.person)),
                      const SizedBox(width: 12),
                      Text(
                        'Hi, ${widget.user.name}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Language Section
                  Text(
                    'Select Language',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: DataService.languages.map((lang) {
                      final isSelected = _selectedLanguage == lang;
                      return ChoiceChip(
                        label: Text(lang),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedLanguage = selected ? lang : null;
                          });
                        },
                        selectedColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                        backgroundColor: Colors.white,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // Category Section
                  Text(
                    'Select Mood',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: DataService.categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? cat : null;
                          });
                        },
                        selectedColor: Theme.of(context).colorScheme.secondary,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                        backgroundColor: Colors.white,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 40),

                  // Favorites Button
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () => _navigateToContent(isFavorites: true),
                      icon: const Icon(Icons.favorite, color: Colors.redAccent),
                      label: const Text(
                        'Go to Favorites',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Generate Button
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
                onPressed: () => _navigateToContent(isFavorites: false),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.auto_awesome),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
