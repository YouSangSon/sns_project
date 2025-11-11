import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_compress/video_compress.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider_riverpod.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';
import '../../core/theme/app_theme.dart';

class CreateReelScreen extends ConsumerStatefulWidget {
  const CreateReelScreen({super.key});

  @override
  ConsumerState<CreateReelScreen> createState() => _CreateReelScreenState();
}

class _CreateReelScreenState extends ConsumerState<CreateReelScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isRecording = false;
  bool _isFrontCamera = false;
  XFile? _videoFile;
  VideoPlayerController? _videoPlayerController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras![_isFrontCamera ? 1 : 0],
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _toggleCamera() async {
    _isFrontCamera = !_isFrontCamera;
    await _cameraController?.dispose();
    await _initializeCamera();
  }

  Future<void> _startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isRecording) {
      final videoFile = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _videoFile = videoFile;
      });
      await _previewVideo();
    } else {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _pickVideoFromGallery() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _videoFile = video;
      });
      await _previewVideo();
    }
  }

  Future<void> _previewVideo() async {
    if (_videoFile == null) return;

    _videoPlayerController = VideoPlayerController.file(File(_videoFile!.path));
    await _videoPlayerController!.initialize();
    await _videoPlayerController!.setLooping(true);
    await _videoPlayerController!.play();

    if (mounted) {
      setState(() {});
    }
  }

  void _discardVideo() {
    setState(() {
      _videoFile = null;
      _videoPlayerController?.dispose();
      _videoPlayerController = null;
    });
  }

  Future<void> _nextStep() async {
    if (_videoFile == null) return;

    // Navigate to caption screen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReelCaptionScreen(videoFile: _videoFile!),
      ),
    );

    // After returning, discard the video
    _discardVideo();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoFile != null && _videoPlayerController != null) {
      return _buildVideoPreview();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : _buildCameraView(),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera Preview
        CameraPreview(_cameraController!),

        // Top Bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Create Reel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      // Settings
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom Controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery Button
                  IconButton(
                    icon: const Icon(
                      Icons.photo_library,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: _pickVideoFromGallery,
                  ),

                  // Record Button
                  GestureDetector(
                    onTap: _startRecording,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: _isRecording ? 30 : 60,
                          height: _isRecording ? 30 : 60,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: _isRecording ? BoxShape.rectangle : BoxShape.circle,
                            borderRadius: _isRecording ? BorderRadius.circular(8) : null,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Flip Camera Button
                  IconButton(
                    icon: const Icon(
                      Icons.flip_camera_ios,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: _toggleCamera,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Recording Indicator
        if (_isRecording)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fiber_manual_record, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Recording...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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

  Widget _buildVideoPreview() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video Preview
          Center(
            child: AspectRatio(
              aspectRatio: _videoPlayerController!.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController!),
            ),
          ),

          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: _discardVideo,
                    ),
                    const Text(
                      'Preview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: _nextStep,
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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

class ReelCaptionScreen extends ConsumerStatefulWidget {
  final XFile videoFile;

  const ReelCaptionScreen({super.key, required this.videoFile});

  @override
  ConsumerState<ReelCaptionScreen> createState() => _ReelCaptionScreenState();
}

class _ReelCaptionScreenState extends ConsumerState<ReelCaptionScreen> {
  final TextEditingController _captionController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  bool _isUploading = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _uploadReel() async {
    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Compress video
      final compressedVideo = await VideoCompress.compressVideo(
        widget.videoFile.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
      );

      if (compressedVideo == null) throw Exception('Video compression failed');

      // Upload video
      final videoUrl = await _storageService.uploadVideo(
        File(compressedVideo.path),
        'reels',
      );

      // Generate thumbnail
      final thumbnailFile = await VideoCompress.getFileThumbnail(
        widget.videoFile.path,
        quality: 50,
      );

      // Upload thumbnail
      final thumbnailUrl = await _storageService.uploadImage(
        thumbnailFile,
        'reel_thumbnails',
      );

      // Get video duration
      final videoPlayerController = VideoPlayerController.file(
        File(widget.videoFile.path),
      );
      await videoPlayerController.initialize();
      final duration = videoPlayerController.value.duration.inSeconds.toDouble();
      await videoPlayerController.dispose();

      // Create reel in database
      await _databaseService.createReel(
        userId: currentUser.uid,
        username: currentUser.username,
        userPhotoUrl: currentUser.photoUrl,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        caption: _captionController.text,
        duration: duration,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reel uploaded successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading reel: $e'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Reel'),
        actions: [
          if (_isUploading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            TextButton(
              onPressed: _uploadReel,
              child: const Text(
                'Share',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Caption Input
            TextField(
              controller: _captionController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Write a caption...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Add Music Section
            ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text('Add Music'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Add music logic
              },
            ),
            const Divider(),

            // Cover Image Section
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Choose Cover'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Choose cover logic
              },
            ),
            const Divider(),

            // Privacy Settings
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Privacy'),
              subtitle: const Text('Public'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Privacy settings
              },
            ),
            const Divider(),

            // Advanced Settings
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Advanced Settings'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Advanced settings
              },
            ),
          ],
        ),
      ),
    );
  }
}
