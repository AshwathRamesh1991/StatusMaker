import 'package:flutter/material.dart';
import '../models/content_model.dart';
import '../models/user_model.dart';
import '../widgets/content_render_widget.dart';

class PreviewScreen extends StatelessWidget {
  final ContentItem item;
  final UserModel user;

  const PreviewScreen({super.key, required this.item, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Preview Status'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: ContentRenderWidget(item: item, user: user),
    );
  }
}
