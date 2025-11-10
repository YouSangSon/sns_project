import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../core/constants/app_constants.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionController = TextEditingController();
  final _locationController = TextEditingController();
  final List<String> _selectedImagePaths = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          _selectedImagePaths.clear();
          for (var image in images.take(AppConstants.maxPostImages)) {
            _selectedImagePaths.add(image.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }

  Future<void> _createPost() async {
    if (_selectedImagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    final postProvider = context.read<PostProvider>();

    if (authProvider.user != null && authProvider.userModel != null) {
      final success = await postProvider.createPost(
        userId: authProvider.user!.uid,
        username: authProvider.userModel!.username,
        userPhotoUrl: authProvider.userModel!.photoUrl,
        imagePaths: _selectedImagePaths,
        caption: _captionController.text.trim(),
        location: _locationController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully')),
        );
        context.go('/home');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(postProvider.errorMessage ?? 'Failed to create post'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _createPost,
              child: const Text(
                'Share',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image selection
            if (_selectedImagePaths.isEmpty)
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tap to select photos',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      itemCount: _selectedImagePaths.length,
                      itemBuilder: (context, index) {
                        return Image.file(
                          File(_selectedImagePaths[index]),
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          '${_selectedImagePaths.length} photo${_selectedImagePaths.length > 1 ? 's' : ''} selected',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.edit),
                          label: const Text('Change'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            const Divider(),

            // Caption
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _captionController,
                maxLines: 5,
                maxLength: AppConstants.maxCaptionLength,
                decoration: const InputDecoration(
                  hintText: 'Write a caption...',
                  border: InputBorder.none,
                ),
              ),
            ),

            const Divider(),

            // Location
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'Add location',
                  border: InputBorder.none,
                ),
              ),
            ),

            const Divider(),

            // Additional options
            ListTile(
              leading: const Icon(Icons.tag),
              title: const Text('Tag people'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Tag people functionality
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text('Add music'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Add music functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}
