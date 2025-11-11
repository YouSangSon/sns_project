import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

enum ImageFilter {
  none,
  grayscale,
  sepia,
  vintage,
  cold,
  warm,
  bright,
  dark,
  contrast,
  saturate,
  vignette,
}

enum VideoFilter {
  none,
  grayscale,
  sepia,
  blur,
  sharpen,
  brightness,
  contrast,
}

class MediaEditorService {
  static final MediaEditorService _instance = MediaEditorService._internal();
  factory MediaEditorService() => _instance;
  MediaEditorService._internal();

  final Uuid _uuid = const Uuid();

  // ============ IMAGE EDITING ============

  /// Apply filter to image
  Future<File> applyImageFilter(File imageFile, ImageFilter filter) async {
    try {
      // Read image
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Could not decode image');
      }

      // Apply filter
      switch (filter) {
        case ImageFilter.none:
          break;
        case ImageFilter.grayscale:
          image = img.grayscale(image);
          break;
        case ImageFilter.sepia:
          image = _applySepia(image);
          break;
        case ImageFilter.vintage:
          image = _applyVintage(image);
          break;
        case ImageFilter.cold:
          image = _applyCold(image);
          break;
        case ImageFilter.warm:
          image = _applyWarm(image);
          break;
        case ImageFilter.bright:
          image = img.adjustColor(image, brightness: 1.2);
          break;
        case ImageFilter.dark:
          image = img.adjustColor(image, brightness: 0.8);
          break;
        case ImageFilter.contrast:
          image = img.adjustColor(image, contrast: 1.3);
          break;
        case ImageFilter.saturate:
          image = img.adjustColor(image, saturation: 1.5);
          break;
        case ImageFilter.vignette:
          image = _applyVignette(image);
          break;
      }

      // Save filtered image
      final tempDir = await getTemporaryDirectory();
      final filteredFile = File('${tempDir.path}/filtered_${_uuid.v4()}.jpg');
      await filteredFile.writeAsBytes(img.encodeJpg(image, quality: 90));

      return filteredFile;
    } catch (e) {
      print('Error applying image filter: $e');
      rethrow;
    }
  }

  /// Crop image
  Future<File> cropImage(
    File imageFile, {
    required int x,
    required int y,
    required int width,
    required int height,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Could not decode image');
      }

      final croppedImage = img.copyCrop(image, x: x, y: y, width: width, height: height);

      final tempDir = await getTemporaryDirectory();
      final croppedFile = File('${tempDir.path}/cropped_${_uuid.v4()}.jpg');
      await croppedFile.writeAsBytes(img.encodeJpg(croppedImage, quality: 90));

      return croppedFile;
    } catch (e) {
      print('Error cropping image: $e');
      rethrow;
    }
  }

  /// Rotate image
  Future<File> rotateImage(File imageFile, int degrees) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Could not decode image');
      }

      final rotatedImage = img.copyRotate(image, angle: degrees);

      final tempDir = await getTemporaryDirectory();
      final rotatedFile = File('${tempDir.path}/rotated_${_uuid.v4()}.jpg');
      await rotatedFile.writeAsBytes(img.encodeJpg(rotatedImage, quality: 90));

      return rotatedFile;
    } catch (e) {
      print('Error rotating image: $e');
      rethrow;
    }
  }

  /// Resize image
  Future<File> resizeImage(
    File imageFile, {
    required int width,
    required int height,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Could not decode image');
      }

      final resizedImage = img.copyResize(
        image,
        width: width,
        height: height,
      );

      final tempDir = await getTemporaryDirectory();
      final resizedFile = File('${tempDir.path}/resized_${_uuid.v4()}.jpg');
      await resizedFile.writeAsBytes(img.encodeJpg(resizedImage, quality: 90));

      return resizedFile;
    } catch (e) {
      print('Error resizing image: $e');
      rethrow;
    }
  }

  /// Adjust brightness
  Future<File> adjustBrightness(File imageFile, double brightness) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Could not decode image');
      }

      final adjustedImage = img.adjustColor(image, brightness: brightness);

      final tempDir = await getTemporaryDirectory();
      final adjustedFile = File('${tempDir.path}/brightness_${_uuid.v4()}.jpg');
      await adjustedFile.writeAsBytes(img.encodeJpg(adjustedImage, quality: 90));

      return adjustedFile;
    } catch (e) {
      print('Error adjusting brightness: $e');
      rethrow;
    }
  }

  /// Adjust contrast
  Future<File> adjustContrast(File imageFile, double contrast) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Could not decode image');
      }

      final adjustedImage = img.adjustColor(image, contrast: contrast);

      final tempDir = await getTemporaryDirectory();
      final adjustedFile = File('${tempDir.path}/contrast_${_uuid.v4()}.jpg');
      await adjustedFile.writeAsBytes(img.encodeJpg(adjustedImage, quality: 90));

      return adjustedFile;
    } catch (e) {
      print('Error adjusting contrast: $e');
      rethrow;
    }
  }

  /// Adjust saturation
  Future<File> adjustSaturation(File imageFile, double saturation) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Could not decode image');
      }

      final adjustedImage = img.adjustColor(image, saturation: saturation);

      final tempDir = await getTemporaryDirectory();
      final adjustedFile = File('${tempDir.path}/saturation_${_uuid.v4()}.jpg');
      await adjustedFile.writeAsBytes(img.encodeJpg(adjustedImage, quality: 90));

      return adjustedFile;
    } catch (e) {
      print('Error adjusting saturation: $e');
      rethrow;
    }
  }

  // ============ VIDEO EDITING ============

  /// Apply filter to video using FFmpeg
  Future<File?> applyVideoFilter(File videoFile, VideoFilter filter) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/filtered_${_uuid.v4()}.mp4';

      String filterCommand = '';
      switch (filter) {
        case VideoFilter.none:
          return videoFile;
        case VideoFilter.grayscale:
          filterCommand = 'hue=s=0';
          break;
        case VideoFilter.sepia:
          filterCommand = 'colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131';
          break;
        case VideoFilter.blur:
          filterCommand = 'boxblur=2:1';
          break;
        case VideoFilter.sharpen:
          filterCommand = 'unsharp=5:5:1.5:5:5:0';
          break;
        case VideoFilter.brightness:
          filterCommand = 'eq=brightness=0.1';
          break;
        case VideoFilter.contrast:
          filterCommand = 'eq=contrast=1.5';
          break;
      }

      final command = '-i ${videoFile.path} -vf "$filterCommand" -c:a copy $outputPath';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return File(outputPath);
      } else {
        print('FFmpeg command failed');
        return null;
      }
    } catch (e) {
      print('Error applying video filter: $e');
      return null;
    }
  }

  /// Trim video
  Future<File?> trimVideo(
    File videoFile, {
    required Duration start,
    required Duration end,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/trimmed_${_uuid.v4()}.mp4';

      final startTime = _formatDuration(start);
      final duration = _formatDuration(end - start);

      final command = '-i ${videoFile.path} -ss $startTime -t $duration -c copy $outputPath';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return File(outputPath);
      } else {
        print('FFmpeg trim command failed');
        return null;
      }
    } catch (e) {
      print('Error trimming video: $e');
      return null;
    }
  }

  /// Merge videos
  Future<File?> mergeVideos(List<File> videoFiles) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final listFile = File('${tempDir.path}/list_${_uuid.v4()}.txt');
      final outputPath = '${tempDir.path}/merged_${_uuid.v4()}.mp4';

      // Create file list for FFmpeg
      final fileList = videoFiles.map((f) => "file '${f.path}'").join('\n');
      await listFile.writeAsString(fileList);

      final command = '-f concat -safe 0 -i ${listFile.path} -c copy $outputPath';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return File(outputPath);
      } else {
        print('FFmpeg merge command failed');
        return null;
      }
    } catch (e) {
      print('Error merging videos: $e');
      return null;
    }
  }

  /// Add audio to video
  Future<File?> addAudioToVideo(File videoFile, File audioFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/audio_${_uuid.v4()}.mp4';

      final command = '-i ${videoFile.path} -i ${audioFile.path} -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 $outputPath';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return File(outputPath);
      } else {
        print('FFmpeg add audio command failed');
        return null;
      }
    } catch (e) {
      print('Error adding audio to video: $e');
      return null;
    }
  }

  // ============ HELPER METHODS ============

  img.Image _applySepia(img.Image image) {
    return img.adjustColor(
      image,
      saturation: 0.5,
      hue: 0.05,
    );
  }

  img.Image _applyVintage(img.Image image) {
    var result = img.adjustColor(
      image,
      saturation: 0.7,
      contrast: 1.1,
    );
    return _applyVignette(result);
  }

  img.Image _applyCold(img.Image image) {
    // Increase blue channel
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = (pixel.b * 1.2).clamp(0, 255).toInt();
        image.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }
    return image;
  }

  img.Image _applyWarm(img.Image image) {
    // Increase red and yellow channels
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = (pixel.r * 1.2).clamp(0, 255).toInt();
        final g = (pixel.g * 1.1).clamp(0, 255).toInt();
        final b = pixel.b.toInt();
        image.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }
    return image;
  }

  img.Image _applyVignette(img.Image image) {
    final centerX = image.width / 2;
    final centerY = image.height / 2;
    final maxDist = (image.width > image.height ? image.width : image.height) / 2;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final dist = ((x - centerX) * (x - centerX) + (y - centerY) * (y - centerY)).abs().toDouble();
        final factor = 1.0 - (dist / (maxDist * maxDist * 2)).clamp(0.0, 0.6);

        final pixel = image.getPixel(x, y);
        final r = (pixel.r * factor).clamp(0, 255).toInt();
        final g = (pixel.g * factor).clamp(0, 255).toInt();
        final b = (pixel.b * factor).clamp(0, 255).toInt();
        image.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }
    return image;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
