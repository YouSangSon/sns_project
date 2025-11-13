import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bookmark_model.dart';
import '../models/post_model.dart';
import '../models/investment/investment_post.dart';

/// Bookmark Service - Handles saving/bookmarking content
class BookmarkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _bookmarksCollection = 'bookmarks';

  /// Add bookmark
  Future<void> addBookmark(BookmarkModel bookmark) async {
    try {
      // Check if already bookmarked
      final existing = await _firestore
          .collection(_bookmarksCollection)
          .where('userId', isEqualTo: bookmark.userId)
          .where('contentId', isEqualTo: bookmark.contentId)
          .where('type', isEqualTo: bookmark.type.name)
          .get();

      if (existing.docs.isNotEmpty) {
        // Already bookmarked, do nothing
        return;
      }

      final docRef = _firestore.collection(_bookmarksCollection).doc();
      final bookmarkWithId = bookmark.copyWith(bookmarkId: docRef.id);

      await docRef.set(bookmarkWithId.toMap());

      // Increment bookmark count on the content
      await _incrementBookmarkCount(bookmark.contentId, bookmark.type, 1);
    } catch (e) {
      print('Error adding bookmark: $e');
      rethrow;
    }
  }

  /// Remove bookmark
  Future<void> removeBookmark(String userId, String contentId, BookmarkType type) async {
    try {
      final query = await _firestore
          .collection(_bookmarksCollection)
          .where('userId', isEqualTo: userId)
          .where('contentId', isEqualTo: contentId)
          .where('type', isEqualTo: type.name)
          .get();

      for (var doc in query.docs) {
        await doc.reference.delete();
      }

      // Decrement bookmark count on the content
      await _incrementBookmarkCount(contentId, type, -1);
    } catch (e) {
      print('Error removing bookmark: $e');
      rethrow;
    }
  }

  /// Check if content is bookmarked
  Future<bool> isBookmarked(String userId, String contentId, BookmarkType type) async {
    try {
      final query = await _firestore
          .collection(_bookmarksCollection)
          .where('userId', isEqualTo: userId)
          .where('contentId', isEqualTo: contentId)
          .where('type', isEqualTo: type.name)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking bookmark: $e');
      return false;
    }
  }

  /// Get user's bookmarks
  Stream<List<BookmarkModel>> getUserBookmarks(String userId, {BookmarkType? type}) {
    var query = _firestore
        .collection(_bookmarksCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    if (type != null) {
      query = query.where('type', isEqualTo: type.name) as Query<Map<String, dynamic>>;
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => BookmarkModel.fromDocument(doc)).toList());
  }

  /// Get bookmark count for content
  Future<int> getBookmarkCount(String contentId, BookmarkType type) async {
    try {
      final query = await _firestore
          .collection(_bookmarksCollection)
          .where('contentId', isEqualTo: contentId)
          .where('type', isEqualTo: type.name)
          .get();

      return query.docs.length;
    } catch (e) {
      print('Error getting bookmark count: $e');
      return 0;
    }
  }

  /// Increment/decrement bookmark count on content
  Future<void> _incrementBookmarkCount(
    String contentId,
    BookmarkType type,
    int delta,
  ) async {
    try {
      String collection;
      switch (type) {
        case BookmarkType.post:
          collection = 'posts';
          break;
        case BookmarkType.investmentPost:
          collection = 'investment_posts';
          break;
        case BookmarkType.reel:
          collection = 'reels';
          break;
      }

      await _firestore.collection(collection).doc(contentId).update({
        'bookmarks': FieldValue.increment(delta),
      });
    } catch (e) {
      print('Error incrementing bookmark count: $e');
      // Don't rethrow - bookmark count update is not critical
    }
  }

  /// Delete all bookmarks for a content (when content is deleted)
  Future<void> deleteBookmarksForContent(String contentId, BookmarkType type) async {
    try {
      final query = await _firestore
          .collection(_bookmarksCollection)
          .where('contentId', isEqualTo: contentId)
          .where('type', isEqualTo: type.name)
          .get();

      for (var doc in query.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting bookmarks for content: $e');
      rethrow;
    }
  }

  /// Get bookmarked content details
  Future<Map<String, dynamic>?> getBookmarkedContent(
    String contentId,
    BookmarkType type,
  ) async {
    try {
      String collection;
      switch (type) {
        case BookmarkType.post:
          collection = 'posts';
          break;
        case BookmarkType.investmentPost:
          collection = 'investment_posts';
          break;
        case BookmarkType.reel:
          collection = 'reels';
          break;
      }

      final doc = await _firestore.collection(collection).doc(contentId).get();

      if (!doc.exists) {
        return null;
      }

      return doc.data();
    } catch (e) {
      print('Error getting bookmarked content: $e');
      return null;
    }
  }
}
