import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/content_model.dart';
import '../models/user_model.dart';
import 'preview_screen.dart';

class CreateStatusScreen extends StatefulWidget {
  final UserModel user;
  const CreateStatusScreen({super.key, required this.user});

  @override
  State<CreateStatusScreen> createState() => _CreateStatusScreenState();
}

class _CreateStatusScreenState extends State<CreateStatusScreen> {
  final _textController = TextEditingController();
  File? _mediaFile;
  ContentType _mediaType = ContentType.image;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        _mediaType = ContentType.image;
        if (pickedFile.path.toLowerCase().endsWith('.gif')) {
          _mediaType = ContentType.gif;
        }
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? pickedFile = await _picker.pickVideo(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        _mediaType = ContentType.video;
      });
    }
  }

  void _generateStatus() {
    if (_mediaFile == null || _textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select media and enter text')),
      );
      return;
    }

    final contentItem = ContentItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _mediaType,
      text: _textController.text.trim(),
      backgroundPath: _mediaFile!.path,
      language: 'Custom',
      category: 'Custom',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PreviewScreen(item: contentItem, user: widget.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'Create Custom Status',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Media Picker Area
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: const Color(0xFF16213E),
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.image, color: Colors.white),
                        title: const Text(
                          'Pick Image',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage();
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.videocam,
                          color: Colors.white,
                        ),
                        title: const Text(
                          'Pick Video',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _pickVideo();
                        },
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 1),
                  image: _mediaFile != null && _mediaType != ContentType.video
                      ? DecorationImage(
                          image: FileImage(_mediaFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _mediaFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 50,
                            color: Colors.white54,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Tap to add Photo or Video',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      )
                    : _mediaType == ContentType.video
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.play_circle_outline,
                            size: 60,
                            color: Colors.white,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Video Selected',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )
                    : null, // Image handled by DecorationImage
              ),
            ),
            const SizedBox(height: 24),

            // Text Input
            TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter your quote here...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
            const SizedBox(height: 40),

            // Generate Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _generateStatus,
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
                      'Preview & Share',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
