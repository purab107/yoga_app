import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:image/image.dart' as img;

/// Service for extracting frames from video files
class VideoFrameExtractor {
  /// Extract frames from video at specified intervals
  /// Returns list of images ready for model inference
  Future<List<img.Image>> extractFrames(
    Uint8List videoBytes,
    String videoName, {
    int sampleRate = 10, // Extract frame every N seconds
  }) async {
    List<img.Image> frames = [];

    try {
      // Save video to temporary file
      final tempDir = await getTemporaryDirectory();
      final videoPath = '${tempDir.path}/$videoName';
      final videoFile = File(videoPath);
      await videoFile.writeAsBytes(videoBytes);

      print('Extracting frames from video...');

      // Extract multiple frames at different timestamps
      // Assuming 30fps video, we'll extract frames every few seconds
      for (int i = 0; i < 30; i += sampleRate) {
        try {
          final uint8list = await VideoThumbnail.thumbnailData(
            video: videoPath,
            imageFormat: ImageFormat.PNG,
            timeMs: i * 1000, // Convert seconds to milliseconds
            quality: 100,
          );

          if (uint8list != null) {
            final image = img.decodeImage(uint8list);
            if (image != null) {
              frames.add(image);
            }
          }
        } catch (e) {
          // Stop if we've reached the end of the video
          print('Reached end of video or error at ${i}s: $e');
          break;
        }
      }

      // Cleanup
      await videoFile.delete();

      print('Extracted ${frames.length} frames for analysis');
    } catch (e) {
      print('Error extracting frames: $e');
      rethrow;
    }

    if (frames.isEmpty) {
      throw Exception('No frames extracted from video');
    }

    return frames;
  }
}
