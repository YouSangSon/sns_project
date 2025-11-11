import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/auth_provider_riverpod.dart';
import '../../services/database_service.dart';
import '../../core/theme/app_theme.dart';
import 'package:uuid/uuid.dart';

const String agoraAppId = 'YOUR_AGORA_APP_ID';

class CreateLiveStreamScreen extends ConsumerStatefulWidget {
  const CreateLiveStreamScreen({super.key});

  @override
  ConsumerState<CreateLiveStreamScreen> createState() => _CreateLiveStreamScreenState();
}

class _CreateLiveStreamScreenState extends ConsumerState<CreateLiveStreamScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();

  RtcEngine? _engine;
  bool _isLive = false;
  bool _isCameraEnabled = true;
  bool _isMicEnabled = true;
  String? _streamId;
  String? _channelName;
  int _viewerCount = 0;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  @override
  void dispose() {
    _endStream();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _initAgora() async {
    // Request permissions
    await [Permission.microphone, Permission.camera].request();

    // Create Agora engine
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(
      appId: agoraAppId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    // Set up event handlers
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _isLive = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _viewerCount++;
          });
          if (_streamId != null) {
            _databaseService.updateLiveStreamViewers(_streamId!, _viewerCount);
          }
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          setState(() {
            _viewerCount--;
          });
          if (_streamId != null) {
            _databaseService.updateLiveStreamViewers(_streamId!, _viewerCount);
          }
        },
      ),
    );

    // Set client role to broadcaster
    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine!.enableVideo();
    await _engine!.startPreview();

    setState(() {});
  }

  Future<void> _startStream() async {
    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser == null) return;

    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title for your live stream'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    try {
      // Generate channel name
      _channelName = _uuid.v4();

      // Create live stream in database
      _streamId = await _databaseService.createLiveStream(
        userId: currentUser.uid,
        username: currentUser.username,
        userPhotoUrl: currentUser.photoUrl,
        title: _titleController.text,
        description: _descriptionController.text,
      );

      // Join Agora channel
      await _engine!.joinChannel(
        token: '', // In production, generate token from your server
        channelId: _channelName!,
        uid: 0,
        options: const ChannelMediaOptions(),
      );

      // Update stream status in database
      await _databaseService.startLiveStream(
        _streamId!,
        _channelName!,
        '', // Token should be generated from server
      );

      setState(() {
        _isLive = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting stream: $e'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
      }
    }
  }

  Future<void> _endStream() async {
    if (_streamId != null) {
      await _databaseService.endLiveStream(_streamId!);
    }

    await _engine?.leaveChannel();
    await _engine?.release();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _toggleCamera() async {
    setState(() {
      _isCameraEnabled = !_isCameraEnabled;
    });
    await _engine?.enableLocalVideo(_isCameraEnabled);
  }

  Future<void> _toggleMic() async {
    setState(() {
      _isMicEnabled = !_isMicEnabled;
    });
    await _engine?.enableLocalAudio(_isMicEnabled);
  }

  Future<void> _switchCamera() async {
    await _engine?.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    if (_engine == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () async {
            if (_isLive) {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('End Live Stream?'),
                  content: const Text(
                    'Are you sure you want to end your live stream?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('End Stream'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await _endStream();
              }
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: _isLive
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            : const Text(
                'Go Live',
                style: TextStyle(color: Colors.white),
              ),
      ),
      body: Stack(
        children: [
          // Camera Preview
          AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: _engine!,
              canvas: const VideoCanvas(uid: 0),
            ),
          ),

          // Setup Screen (before going live)
          if (!_isLive)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // Title Input
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter a catchy title...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description Input
                      TextField(
                        controller: _descriptionController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Add a description (optional)...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Go Live Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppTheme.modernGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _startStream,
                            borderRadius: BorderRadius.circular(16),
                            child: const Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.videocam, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Go Live',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),

          // Live Controls
          if (_isLive)
            Positioned(
              top: 100,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.remove_red_eye,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _viewerCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Toggle Camera
                    _ControlButton(
                      icon: _isCameraEnabled ? Icons.videocam : Icons.videocam_off,
                      onTap: _toggleCamera,
                      isEnabled: _isCameraEnabled,
                    ),

                    // Toggle Mic
                    _ControlButton(
                      icon: _isMicEnabled ? Icons.mic : Icons.mic_off,
                      onTap: _toggleMic,
                      isEnabled: _isMicEnabled,
                    ),

                    // Switch Camera
                    _ControlButton(
                      icon: Icons.flip_camera_ios,
                      onTap: _switchCamera,
                    ),

                    // End Stream (if live)
                    if (_isLive)
                      _ControlButton(
                        icon: Icons.call_end,
                        onTap: _endStream,
                        backgroundColor: Colors.red,
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

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isEnabled;
  final Color? backgroundColor;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    this.isEnabled = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? (isEnabled ? Colors.white.withOpacity(0.2) : Colors.red.withOpacity(0.3)),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        iconSize: 28,
        onPressed: onTap,
      ),
    );
  }
}
