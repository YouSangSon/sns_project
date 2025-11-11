import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  String? _newImagePath;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    if (authProvider.userModel != null) {
      _displayNameController.text = authProvider.userModel!.displayName;
      _bioController.text = authProvider.userModel!.bio;
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _newImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    String? photoUrl;

    // Upload new profile picture if selected
    if (_newImagePath != null) {
      final storageService = StorageService();
      photoUrl = await storageService.uploadProfileImage(_newImagePath!);
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      displayName: _displayNameController.text.trim(),
      bio: _bioController.text.trim(),
      photoUrl: photoUrl,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Failed to update profile',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentPhotoUrl = authProvider.userModel?.photoUrl ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
              onPressed: _saveProfile,
              child: const Text(
                'Done',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile picture
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _newImagePath != null
                        ? FileImage(File(_newImagePath!))
                        : (currentPhotoUrl.isNotEmpty
                            ? NetworkImage(currentPhotoUrl)
                            : null) as ImageProvider?,
                    child: (_newImagePath == null && currentPhotoUrl.isEmpty)
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Display name
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Bio
            TextField(
              controller: _bioController,
              maxLines: 4,
              maxLength: 150,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell us about yourself',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            // Username (read-only)
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: authProvider.userModel?.username ?? '',
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),

            // Email (read-only)
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: authProvider.userModel?.email ?? '',
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
