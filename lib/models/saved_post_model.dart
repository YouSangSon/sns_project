import 'package:cloud_firestore/cloud_firestore.dart';

class SavedPostModel {
  final String saveId;
  final String userId;
  final String postId;
  final DateTime savedAt;

  SavedPostModel({
    required this.saveId,
    required this.userId,
    required this.postId,
    required this.savedAt,
  });

  // Convert Firestore document to SavedPostModel
  factory SavedPostModel.fromMap(Map<String, dynamic> map) {
    return SavedPostModel(
      saveId: map['saveId'] ?? '',
      userId: map['userId'] ?? '',
      postId: map['postId'] ?? '',
      savedAt: (map['savedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert Firestore DocumentSnapshot to SavedPostModel
  factory SavedPostModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavedPostModel.fromMap(data);
  }

  // Convert SavedPostModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'saveId': saveId,
      'userId': userId,
      'postId': postId,
      'savedAt': Timestamp.fromDate(savedAt),
    };
  }
}
