import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../providers/auth_provider_riverpod.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';
import '../../models/post_model.dart';
import '../../widgets/user_tag_widget.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _captionController = TextEditingController();
  final _locationController = TextEditingController();
  final List<String> _selectedImagePaths = [];
  final List<String> _taggedUserIds = [];
  final ImagePicker _picker = ImagePicker();
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
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

    final currentUserAsync = ref.read(currentUserProvider);
    final currentUser = currentUserAsync.value;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to create a post')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload images
      final imageUrls = await _storageService.uploadPostImages(
        _selectedImagePaths,
        currentUser.uid,
      );

      if (imageUrls.isEmpty) {
        throw Exception('Failed to upload images');
      }

      // Create post
      final post = PostModel(
        postId: '',
        userId: currentUser.uid,
        username: currentUser.username,
        userPhotoUrl: currentUser.photoUrl,
        imageUrls: imageUrls,
        caption: _captionController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        taggedUserIds: _taggedUserIds,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.createPost(post);

      // If users are tagged, create notifications
      if (_taggedUserIds.isNotEmpty) {
        await _databaseService.tagUsersInPost(post.postId, _taggedUserIds);
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully')),
        );
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openTagPeople() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserTagSelector(
          selectedUserIds: _taggedUserIds,
          onUsersSelected: (userIds) {
            setState(() {
              _taggedUserIds.clear();
              _taggedUserIds.addAll(userIds);
            });
          },
        ),
      ),
    );
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
              title: Text(
                _taggedUserIds.isEmpty
                    ? 'Tag people'
                    : 'Tag people (${_taggedUserIds.length})',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openTagPeople,
            ),

            if (_taggedUserIds.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _taggedUserIds.map((userId) {
                    return FutureBuilder(
                      future: _databaseService.getUserById(userId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        final user = snapshot.data!;
                        return Chip(
                          avatar: const Icon(Icons.person, size: 16),
                          label: Text(
                            user.username,
                            style: const TextStyle(fontSize: 12),
                          ),
                          visualDensity: VisualDensity.compact,
                          onDeleted: () {
                            setState(() {
                              _taggedUserIds.remove(userId);
                            });
                          },
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
            ],

            const Divider(),

            ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text('Add music'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Add music functionality - future feature
              },
            ),
          ],
        ),
      ),
    );
  }
}
