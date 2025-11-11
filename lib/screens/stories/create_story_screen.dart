import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../providers/story_provider.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _selectedMediaPath;
  String _mediaType = 'image';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pickMedia();
  }

  Future<void> _pickMedia() async {
    try {
      final XFile? media = await _picker.pickImage(source: ImageSource.camera);

      if (media != null) {
        setState(() {
          _selectedMediaPath = media.path;
          _mediaType = 'image';
        });
      } else {
        // User canceled, go back
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking media: $e')),
        );
        context.pop();
      }
    }
  }

  Future<void> _createStory() async {
    if (_selectedMediaPath == null) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    final storyProvider = context.read<StoryProvider>();

    if (authProvider.user != null && authProvider.userModel != null) {
      final success = await storyProvider.createStory(
        userId: authProvider.user!.uid,
        username: authProvider.userModel!.username,
        userPhotoUrl: authProvider.userModel!.photoUrl,
        mediaPath: _selectedMediaPath!,
        mediaType: _mediaType,
      );

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story shared')),
        );
        context.go('/home');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(storyProvider.errorMessage ?? 'Failed to create story'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('New Story', style: TextStyle(color: Colors.white)),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _createStory,
              child: const Text(
                'Share',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: _selectedMediaPath == null
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Stack(
              children: [
                // Media preview
                Center(
                  child: Image.file(
                    File(_selectedMediaPath!),
                    fit: BoxFit.contain,
                  ),
                ),

                // Drawing tools (optional - can be expanded)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.text_fields,
                            color: Colors.white, size: 30),
                        onPressed: () {
                          // Add text functionality
                        },
                      ),
                      const SizedBox(height: 16),
                      IconButton(
                        icon: const Icon(Icons.brush,
                            color: Colors.white, size: 30),
                        onPressed: () {
                          // Drawing functionality
                        },
                      ),
                      const SizedBox(height: 16),
                      IconButton(
                        icon: const Icon(Icons.tag,
                            color: Colors.white, size: 30),
                        onPressed: () {
                          // Tag people functionality
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
