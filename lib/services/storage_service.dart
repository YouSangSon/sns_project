import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Upload profile image
  Future<String?> uploadProfileImage(String filePath) async {
    try {
      final file = File(filePath);
      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage
          .ref()
          .child(AppConstants.profileImagesPath)
          .child(fileName);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  // Upload post image
  Future<String?> uploadPostImage(String filePath) async {
    try {
      final file = File(filePath);
      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage
          .ref()
          .child(AppConstants.postImagesPath)
          .child(fileName);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading post image: $e');
      return null;
    }
  }

  // Upload story media
  Future<String?> uploadStoryMedia(String filePath, String mediaType) async {
    try {
      final file = File(filePath);
      final extension = mediaType == 'video' ? 'mp4' : 'jpg';
      final fileName = '${_uuid.v4()}.$extension';
      final ref = _storage
          .ref()
          .child(AppConstants.storyImagesPath)
          .child(fileName);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading story media: $e');
      return null;
    }
  }

  // Upload message media
  Future<String?> uploadMessageMedia(String filePath, String mediaType) async {
    try {
      final file = File(filePath);
      final extension = mediaType == 'video' ? 'mp4' : 'jpg';
      final fileName = '${_uuid.v4()}.$extension';
      final ref = _storage
          .ref()
          .child(AppConstants.messageMediaPath)
          .child(fileName);

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading message media: $e');
      return null;
    }
  }

  // Delete file from storage
  Future<bool> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }
}
