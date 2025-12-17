import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:video_player/video_player.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import '../models/content_model.dart';
import '../models/user_model.dart';
import '../services/favorites_service.dart';

class ContentRenderWidget extends StatefulWidget {
  final ContentItem item;
  final UserModel user;

  const ContentRenderWidget({
    super.key,
    required this.item,
    required this.user,
  });

  @override
  State<ContentRenderWidget> createState() => _ContentRenderWidgetState();
}

class _ContentRenderWidgetState extends State<ContentRenderWidget> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;
  bool _hideVideoForCapture = false;

  @override
  void initState() {
    super.initState();
    if (widget.item.type == ContentType.video) {
      // Safer check: Assets in this project always start with 'assets'
      // Local files (from picker) will be absolute paths like /data/...
      if (widget.item.backgroundPath.startsWith('assets')) {
        _videoController = VideoPlayerController.asset(
          widget.item.backgroundPath,
        );
      } else {
        _videoController = VideoPlayerController.file(
          File(widget.item.backgroundPath),
        );
      }

      _videoController!.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _videoController!.setLooping(true);
          _videoController!.play();
        }
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    context.read<FavoritesService>().toggleFavorite(widget.item);
    setState(() {
      // Force rebuild to show updated icon if we were using local state
    });
  }

  Future<void> _shareContent() async {
    if (_isSharing) return;
    setState(() {
      _isSharing = true;
    });

    try {
      final directory = await getTemporaryDirectory();
      if (!mounted) return;
      debugPrint(
        "Sharing Content. User: ${widget.user.name}, Image: ${widget.user.imagePath}",
      );

      if (widget.item.type == ContentType.video) {
        // 1. Capture Overlay Only
        String? overlayPath;
        try {
          setState(() {
            _hideVideoForCapture = true;
          });

          await Future.delayed(const Duration(milliseconds: 200));
          if (!mounted) return;

          overlayPath = await _screenshotController.captureAndSave(
            directory.path,
            fileName: 'overlay_${DateTime.now().millisecondsSinceEpoch}.png',
            pixelRatio: 1.0,
          );
        } finally {
          if (mounted) {
            setState(() {
              _hideVideoForCapture = false;
            });
          }
        }

        if (!mounted) return;
        if (overlayPath == null) throw Exception("Failed to capture overlay");

        // 2. Prepare Video Source
        String videoPath;
        if (widget.item.backgroundPath.startsWith('assets')) {
          // It's an asset, copy to temp
          final byteData = await rootBundle.load(widget.item.backgroundPath);
          if (!mounted) return;
          videoPath = '${directory.path}/original_video.mp4';
          final videoFile = File(videoPath);
          await videoFile.writeAsBytes(
            byteData.buffer.asUint8List(
              byteData.offsetInBytes,
              byteData.lengthInBytes,
            ),
          );
        } else {
          // It's a local file, usage directly
          videoPath = widget.item.backgroundPath;
        }

        // 3. Run FFmpeg ... (rest implies videoPath is valid)
        final outputPath =
            '${directory.path}/shared_video_${DateTime.now().millisecondsSinceEpoch}.mp4';

        if (!mounted ||
            _videoController == null ||
            !_videoController!.value.isInitialized) {
          return;
        }
        final videoWidth = _videoController!.value.size.width.toInt();
        final videoHeight = _videoController!.value.size.height.toInt();

        // Ensure even dimensions for some encoders, though scale usually handles it
        // ... (FFmpeg command remains similar)

        final command =
            '-i "$videoPath" -i "$overlayPath" -filter_complex "[1:v]scale=$videoWidth:$videoHeight[ovrl];[0:v][ovrl]overlay=0:0" -c:v libx264 -preset ultrafast "$outputPath"';

        debugPrint("Running FFmpeg: $command");

        await FFmpegKit.execute(command).then((session) async {
          if (!mounted) return;
          final returnCode = await session.getReturnCode();

          if (ReturnCode.isSuccess(returnCode)) {
            if (!mounted) return;
            await Share.shareXFiles([
              XFile(outputPath),
            ], text: '${widget.item.text}\n\nSent via StatusMaker');
          } else {
            throw Exception("FFmpeg processing failed");
          }
        });
      } else {
        // ... Image sharing (unchanged)
        final imagePath = await _screenshotController.captureAndSave(
          directory.path,
          fileName: 'status_share_${DateTime.now().millisecondsSinceEpoch}.png',
          pixelRatio: 1.0,
        );
        if (!mounted) return;

        if (imagePath != null) {
          await Share.shareXFiles([
            XFile(imagePath),
          ], text: 'Check out this quote!\n\nSent via StatusMaker');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sharing: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Screenshot(
          controller: _screenshotController,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background
              widget.item.type == ContentType.video
                  ? (_isInitialized && _videoController != null
                        ? (_hideVideoForCapture
                              ? Container(color: Colors.transparent)
                              : FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: _videoController!.value.size.width,
                                    height: _videoController!.value.size.height,
                                    child: VideoPlayer(_videoController!),
                                  ),
                                ))
                        : const Center(child: CircularProgressIndicator()))
                  : widget.item.backgroundPath.startsWith('assets')
                  ? Image.asset(widget.item.backgroundPath, fit: BoxFit.cover)
                  : Image.file(
                      File(widget.item.backgroundPath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),

              // ... rest of build stack

              // Overlay - Gradient for legibility
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black12,
                      Colors.transparent,
                      Colors.black45,
                    ],
                  ),
                ),
              ),

              // Quote Text
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    widget.item.text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.caveat(
                      // Handwritten style for quotes
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        const Shadow(
                          blurRadius: 10,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // User Info Overlay (Bottom Left)
              Positioned(
                bottom: 160, // Adjusted to avoid potential bottom clipping
                left: 20,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      if (widget.user.imagePath != null)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: FileImage(
                              File(widget.user.imagePath!),
                            ),
                          ),
                        )
                      else
                        const CircleAvatar(
                          radius: 60,
                          child: Icon(Icons.person),
                        ),
                      const SizedBox(width: 10),
                      Text(
                        widget.user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                          shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Hidden branding for screenshot if needed, or just relying on what's visible
            ],
          ),
        ),

        // UI Controls (Not captured in screenshot)
        Positioned(
          bottom: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Favorite Button
                  Consumer<FavoritesService>(
                    builder: (context, favorites, _) {
                      final isFav = favorites.isFavorite(widget.item.id);
                      return IconButton(
                        onPressed: _toggleFavorite,
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.white,
                          size: 32,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Share Button
                  IconButton(
                    onPressed: _shareContent,
                    icon: _isSharing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 32,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
