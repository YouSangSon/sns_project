import 'dart:io';
import 'package:path/path.dart' as path;
import 'api_service.dart';

/// REST API Storage Service
/// Replaces Firebase Storage with REST API file upload
/// Supports AWS S3, Cloudinary, or custom storage backend
class StorageServiceRest {
  final ApiService _api = ApiService();

  /// Upload file to server
  /// Returns the URL of the uploaded file
  Future<String> uploadFile({
    required File file,
    required StorageFolder folder,
    String? customFileName,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      final fileName = customFileName ?? _generateFileName(file);
      final filePath = file.path;

      final url = await _api.uploadFile(
        '/upload',
        filePath: filePath,
        fieldName: 'file',
        data: {
          'folder': folder.name,
          'fileName': fileName,
        },
        onProgress: onProgress,
      );

      return url;
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  /// Upload image with automatic optimization
  Future<String> uploadImage({
    required File imageFile,
    required StorageFolder folder,
    ImageQuality quality = ImageQuality.high,
    int? maxWidth,
    int? maxHeight,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      final fileName = _generateFileName(imageFile);

      final url = await _api.uploadFile(
        '/upload/image',
        filePath: imageFile.path,
        fieldName: 'image',
        data: {
          'folder': folder.name,
          'fileName': fileName,
          'quality': quality.name,
          if (maxWidth != null) 'maxWidth': maxWidth,
          if (maxHeight != null) 'maxHeight': maxHeight,
        },
        onProgress: onProgress,
      );

      return url;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  /// Upload video
  Future<String> uploadVideo({
    required File videoFile,
    required StorageFolder folder,
    VideoQuality quality = VideoQuality.high,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      final fileName = _generateFileName(videoFile);

      final url = await _api.uploadFile(
        '/upload/video',
        filePath: videoFile.path,
        fieldName: 'video',
        data: {
          'folder': folder.name,
          'fileName': fileName,
          'quality': quality.name,
        },
        onProgress: onProgress,
      );

      return url;
    } catch (e) {
      print('Error uploading video: $e');
      rethrow;
    }
  }

  /// Upload multiple files at once
  Future<List<String>> uploadMultipleFiles({
    required List<File> files,
    required StorageFolder folder,
    Function(int fileIndex, int sent, int total)? onProgress,
  }) async {
    final urls = <String>[];

    for (int i = 0; i < files.length; i++) {
      final file = files[i];

      final url = await uploadFile(
        file: file,
        folder: folder,
        onProgress: (sent, total) {
          onProgress?.call(i, sent, total);
        },
      );

      urls.add(url);
    }

    return urls;
  }

  /// Upload multiple images
  Future<List<String>> uploadMultipleImages({
    required List<File> imageFiles,
    required StorageFolder folder,
    ImageQuality quality = ImageQuality.high,
    Function(int fileIndex, int sent, int total)? onProgress,
  }) async {
    final urls = <String>[];

    for (int i = 0; i < imageFiles.length; i++) {
      final imageFile = imageFiles[i];

      final url = await uploadImage(
        imageFile: imageFile,
        folder: folder,
        quality: quality,
        onProgress: (sent, total) {
          onProgress?.call(i, sent, total);
        },
      );

      urls.add(url);
    }

    return urls;
  }

  /// Delete file from server
  Future<void> deleteFile({
    required String fileUrl,
  }) async {
    try {
      // Extract file ID or path from URL
      final fileId = _extractFileIdFromUrl(fileUrl);

      await _api.delete('/upload/$fileId');

      print('File deleted: $fileUrl');
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }

  /// Delete multiple files
  Future<void> deleteMultipleFiles({
    required List<String> fileUrls,
  }) async {
    try {
      final fileIds = fileUrls.map((url) => _extractFileIdFromUrl(url)).toList();

      await _api.post('/upload/delete-multiple', data: {
        'fileIds': fileIds,
      });

      print('Deleted ${fileUrls.length} files');
    } catch (e) {
      print('Error deleting multiple files: $e');
      rethrow;
    }
  }

  /// Get file metadata
  Future<FileMetadata?> getFileMetadata({
    required String fileUrl,
  }) async {
    try {
      final fileId = _extractFileIdFromUrl(fileUrl);

      final response = await _api.get('/upload/$fileId/metadata');

      return FileMetadata.fromMap(response.data);
    } catch (e) {
      print('Error getting file metadata: $e');
      return null;
    }
  }

  /// Generate thumbnail for image
  Future<String> generateThumbnail({
    required String imageUrl,
    int width = 200,
    int height = 200,
  }) async {
    try {
      final response = await _api.post('/upload/thumbnail', data: {
        'imageUrl': imageUrl,
        'width': width,
        'height': height,
      });

      return response.data['thumbnailUrl'] as String;
    } catch (e) {
      print('Error generating thumbnail: $e');
      rethrow;
    }
  }

  /// Get signed URL for private file (temporary access)
  Future<String> getSignedUrl({
    required String fileUrl,
    Duration expiresIn = const Duration(hours: 1),
  }) async {
    try {
      final fileId = _extractFileIdFromUrl(fileUrl);

      final response = await _api.post('/upload/$fileId/signed-url', data: {
        'expiresIn': expiresIn.inSeconds,
      });

      return response.data['signedUrl'] as String;
    } catch (e) {
      print('Error getting signed URL: $e');
      rethrow;
    }
  }

  /// Download file
  Future<File> downloadFile({
    required String fileUrl,
    required String savePath,
    Function(int received, int total)? onProgress,
  }) async {
    try {
      await _api.downloadFile(
        fileUrl,
        savePath: savePath,
        onProgress: onProgress,
      );

      return File(savePath);
    } catch (e) {
      print('Error downloading file: $e');
      rethrow;
    }
  }

  // ========== PRIVATE HELPER METHODS ==========

  /// Generate unique file name
  String _generateFileName(File file) {
    final extension = path.extension(file.path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;

    return '${timestamp}_$random$extension';
  }

  /// Extract file ID from URL
  /// Example: https://cdn.example.com/uploads/12345.jpg -> 12345.jpg
  String _extractFileIdFromUrl(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;

    if (segments.isEmpty) {
      return url;
    }

    return segments.last;
  }
}

/// Storage folder enum
enum StorageFolder {
  profileImages,
  postImages,
  postVideos,
  reelVideos,
  storyImages,
  storyVideos,
  messageImages,
  messageVideos,
  portfolioImages,
  documents,
  thumbnails,
  temp,
}

/// Image quality enum
enum ImageQuality {
  low, // Compressed, smaller file size
  medium, // Balanced
  high, // Original quality
  original, // No compression
}

/// Video quality enum
enum VideoQuality {
  low, // 480p
  medium, // 720p
  high, // 1080p
  original, // Original resolution
}

/// File metadata
class FileMetadata {
  final String fileId;
  final String url;
  final String fileName;
  final String mimeType;
  final int fileSize;
  final int? width;
  final int? height;
  final DateTime uploadedAt;

  FileMetadata({
    required this.fileId,
    required this.url,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    this.width,
    this.height,
    required this.uploadedAt,
  });

  factory FileMetadata.fromMap(Map<String, dynamic> map) {
    return FileMetadata(
      fileId: map['fileId'] as String,
      url: map['url'] as String,
      fileName: map['fileName'] as String,
      mimeType: map['mimeType'] as String,
      fileSize: map['fileSize'] as int,
      width: map['width'] as int?,
      height: map['height'] as int?,
      uploadedAt: DateTime.parse(map['uploadedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fileId': fileId,
      'url': url,
      'fileName': fileName,
      'mimeType': mimeType,
      'fileSize': fileSize,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}

/// Example usage:
///
/// final storageService = StorageServiceRest();
///
/// // Upload profile image
/// final imageUrl = await storageService.uploadImage(
///   imageFile: imageFile,
///   folder: StorageFolder.profileImages,
///   quality: ImageQuality.high,
///   onProgress: (sent, total) {
///     print('Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
///   },
/// );
///
/// // Upload post images
/// final imageUrls = await storageService.uploadMultipleImages(
///   imageFiles: [image1, image2, image3],
///   folder: StorageFolder.postImages,
///   onProgress: (index, sent, total) {
///     print('Uploading image $index: ${(sent / total * 100).toStringAsFixed(0)}%');
///   },
/// );
///
/// // Upload video
/// final videoUrl = await storageService.uploadVideo(
///   videoFile: videoFile,
///   folder: StorageFolder.postVideos,
///   quality: VideoQuality.high,
/// );
///
/// // Delete file
/// await storageService.deleteFile(fileUrl: imageUrl);
///
/// // Get file metadata
/// final metadata = await storageService.getFileMetadata(fileUrl: imageUrl);
/// print('File size: ${metadata?.fileSizeFormatted}');
