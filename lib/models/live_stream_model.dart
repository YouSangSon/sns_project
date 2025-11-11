import 'package:cloud_firestore/cloud_firestore.dart';

enum LiveStreamStatus {
  scheduled,
  live,
  ended,
}

class LiveStreamModel {
  final String streamId;
  final String userId;
  final String username;
  final String userPhotoUrl;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String? agoraChannelName;
  final String? agoraToken;
  final LiveStreamStatus status;
  final int viewerCount;
  final int peakViewerCount;
  final int likes;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  LiveStreamModel({
    required this.streamId,
    required this.userId,
    required this.username,
    required this.userPhotoUrl,
    required this.title,
    this.description = '',
    this.thumbnailUrl = '',
    this.agoraChannelName,
    this.agoraToken,
    this.status = LiveStreamStatus.scheduled,
    this.viewerCount = 0,
    this.peakViewerCount = 0,
    this.likes = 0,
    this.scheduledAt,
    this.startedAt,
    this.endedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LiveStreamModel.fromMap(Map<String, dynamic> map) {
    return LiveStreamModel(
      streamId: map['streamId'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userPhotoUrl: map['userPhotoUrl'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      agoraChannelName: map['agoraChannelName'],
      agoraToken: map['agoraToken'],
      status: LiveStreamStatus.values.firstWhere(
        (e) => e.toString() == 'LiveStreamStatus.${map['status']}',
        orElse: () => LiveStreamStatus.scheduled,
      ),
      viewerCount: map['viewerCount'] ?? 0,
      peakViewerCount: map['peakViewerCount'] ?? 0,
      likes: map['likes'] ?? 0,
      scheduledAt: (map['scheduledAt'] as Timestamp?)?.toDate(),
      startedAt: (map['startedAt'] as Timestamp?)?.toDate(),
      endedAt: (map['endedAt'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory LiveStreamModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LiveStreamModel.fromMap(data);
  }

  Map<String, dynamic> toMap() {
    return {
      'streamId': streamId,
      'userId': userId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'agoraChannelName': agoraChannelName,
      'agoraToken': agoraToken,
      'status': status.toString().split('.').last,
      'viewerCount': viewerCount,
      'peakViewerCount': peakViewerCount,
      'likes': likes,
      'scheduledAt': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  LiveStreamModel copyWith({
    String? streamId,
    String? userId,
    String? username,
    String? userPhotoUrl,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? agoraChannelName,
    String? agoraToken,
    LiveStreamStatus? status,
    int? viewerCount,
    int? peakViewerCount,
    int? likes,
    DateTime? scheduledAt,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LiveStreamModel(
      streamId: streamId ?? this.streamId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      agoraChannelName: agoraChannelName ?? this.agoraChannelName,
      agoraToken: agoraToken ?? this.agoraToken,
      status: status ?? this.status,
      viewerCount: viewerCount ?? this.viewerCount,
      peakViewerCount: peakViewerCount ?? this.peakViewerCount,
      likes: likes ?? this.likes,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isLive => status == LiveStreamStatus.live;
  bool get isScheduled => status == LiveStreamStatus.scheduled;
  bool get isEnded => status == LiveStreamStatus.ended;
}
