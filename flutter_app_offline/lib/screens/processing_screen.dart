import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'results_screen.dart';
import '../services/tflite_model_service.dart';
import '../services/video_frame_extractor.dart';

/// Processing screen with loading indicator - Now with offline TFLite processing
class ProcessingScreen extends StatefulWidget {
  final String asanaName;
  final Uint8List videoBytes;
  final String videoName;

  const ProcessingScreen({
    super.key,
    required this.asanaName,
    required this.videoBytes,
    required this.videoName,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  String _statusMessage = 'Analyzing your posture...';
  final TFLiteModelService _modelService = TFLiteModelService();
  final VideoFrameExtractor _frameExtractor = VideoFrameExtractor();

  @override
  void initState() {
    super.initState();
    _processAndNavigate();
  }

  @override
  void dispose() {
    _modelService.dispose();
    super.dispose();
  }

  /// Process video with on-device TFLite model and navigate to results
  Future<void> _processAndNavigate() async {
    try {
      // Step 1: Load TFLite model
      setState(() {
        _statusMessage = 'Loading AI model...';
      });
      await _modelService.loadModel();

      // Step 2: Extract frames from video
      setState(() {
        _statusMessage = 'Extracting video frames...';
      });
      final frames = await _frameExtractor.extractFrames(
        widget.videoBytes,
        widget.videoName,
        sampleRate: 10, // Extract every 10th frame
      );

      // Step 3: Analyze frames with TFLite model
      setState(() {
        _statusMessage = 'Analyzing poses (${frames.length} frames)...';
      });
      final analysisData = await _modelService.analyzeFrames(
        frames,
        widget.asanaName,
      );

      // Step 4: Navigate to results
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              asanaName: widget.asanaName,
              analysisData: analysisData,
              videoBytes: widget.videoBytes,
              videoName: widget.videoName,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing video: $e\n\nPlease try again with a different video.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              strokeWidth: 3,
            ),
            const SizedBox(height: 32),
            Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
