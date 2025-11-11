import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/live_stream_model.dart';
import '../../services/database_service.dart';
import '../../providers/auth_provider_riverpod.dart';
import '../../core/theme/app_theme.dart';

// Note: You need to add your Agora App ID
const String agoraAppId = 'YOUR_AGORA_APP_ID';

class LiveStreamViewerScreen extends ConsumerStatefulWidget {
  final String streamId;

  const LiveStreamViewerScreen({
    super.key,
    required this.streamId,
  });

  @override
  ConsumerState<LiveStreamViewerScreen> createState() => _LiveStreamViewerScreenState();
}

class _LiveStreamViewerScreenState extends ConsumerState<LiveStreamViewerScreen> {
  final DatabaseService _databaseService = DatabaseService();
  RtcEngine? _engine;
  LiveStreamModel? _liveStream;
  bool _isJoined = false;
  int _remoteUid = 0;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLiveStream();
  }

  @override
  void dispose() {
    _leaveChannel();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadLiveStream() async {
    final liveStream = await _databaseService.getLiveStreamById(widget.streamId);
    if (liveStream != null && mounted) {
      setState(() {
        _liveStream = liveStream;
      });
      if (liveStream.isLive && liveStream.agoraChannelName != null) {
        await _initAgora();
        await _joinChannel(liveStream.agoraChannelName!);
      }
    }
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
            _isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          setState(() {
            _remoteUid = 0;
          });
        },
      ),
    );

    // Set client role to audience
    await _engine!.setClientRole(role: ClientRoleType.clientRoleAudience);
    await _engine!.enableVideo();
  }

  Future<void> _joinChannel(String channelName) async {
    if (_engine == null) return;

    await _engine!.joinChannel(
      token: _liveStream?.agoraToken ?? '',
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> _leaveChannel() async {
    await _engine?.leaveChannel();
    await _engine?.release();
  }

  Future<void> _sendLike() async {
    if (_liveStream != null) {
      await _databaseService.likeLiveStream(_liveStream!.streamId);
      // Show animation
      _showLikeAnimation();
    }
  }

  void _showLikeAnimation() {
    // TODO: Implement flying heart animation
  }

  @override
  Widget build(BuildContext context) {
    if (_liveStream == null) {
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
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
        ),
      ),
      body: Stack(
        children: [
          // Video View
          if (_isJoined && _remoteUid != 0)
            AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine!,
                canvas: VideoCanvas(uid: _remoteUid),
                connection: RtcConnection(channelId: _liveStream!.agoraChannelName),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.modernGradient,
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam, size: 64, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Connecting...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Top Info Bar
          Positioned(
            top: 100,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Host Info
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: _liveStream!.userPhotoUrl.isNotEmpty
                              ? NetworkImage(_liveStream!.userPhotoUrl)
                              : null,
                          child: _liveStream!.userPhotoUrl.isEmpty
                              ? const Icon(Icons.person, size: 16)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _liveStream!.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            // Follow logic
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                          ),
                          child: const Text('Follow'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Viewer Count
                Container(
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
                        _liveStream!.viewerCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                  children: [
                    // Comment Input
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        onSubmitted: (value) {
                          // Send comment logic
                          _messageController.clear();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Like Button
                    IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 32,
                      ),
                      onPressed: _sendLike,
                    ),

                    // Share Button
                    IconButton(
                      icon: const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        // Share logic
                      },
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
