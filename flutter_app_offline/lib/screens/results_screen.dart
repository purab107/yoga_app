import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:video_player/video_player.dart';
import 'video_upload_screen.dart';
import 'home_screen.dart';

/// Results screen displaying analysis feedback
class ResultsScreen extends StatefulWidget {
  final String asanaName;
  final Map<String, dynamic>? analysisData;
  final Uint8List videoBytes;
  final String videoName;

  const ResultsScreen({
    super.key,
    required this.asanaName,
    this.analysisData,
    required this.videoBytes,
    required this.videoName,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _showAllFrames = false;
  VideoPlayerController? _videoController;
  String _currentFeedback = '';
  Color _currentFeedbackColor = Colors.green;
  int _currentFrameIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    // For web, we need to create a blob URL from bytes
    // video_player doesn't support memory playback on web directly
    // So we'll show a placeholder for now and actual implementation would need blob URLs
    // For demonstration, we'll skip video initialization on web
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = widget.analysisData?['accuracy_percentage'] ?? 0.0;
    final frameResults = (widget.analysisData?['frame_results'] as List?) ?? [];
    final correctFrames = widget.analysisData?['correct_frames'] ?? 0;
    final totalFrames = widget.analysisData?['total_frames_analyzed'] ?? 0;
    final avgConfidence = widget.analysisData?['average_confidence'] ?? 0.0;
    final feedback = widget.analysisData?['overall_feedback'] ?? 'No feedback available';

    // Determine status color based on accuracy
    Color statusColor = Colors.red;
    IconData statusIcon = Icons.error_outline;
    String statusText = 'Needs Improvement';

    if (accuracy >= 90) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
      statusText = 'Excellent';
    } else if (accuracy >= 70) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning_amber_rounded;
      statusText = 'Good';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Asana name
            Text(
              widget.asanaName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Statistics cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Accuracy',
                    '${accuracy.toStringAsFixed(1)}%',
                    Icons.track_changes,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Correct',
                    '$correctFrames/$totalFrames',
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Confidence',
                    '${(avgConfidence * 100).toStringAsFixed(1)}%',
                    Icons.psychology,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Frames',
                    '$totalFrames',
                    Icons.video_library,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Result status
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(statusIcon, color: statusColor, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Feedback section
            const Text(
              'Overall Feedback:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                feedback,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
            const SizedBox(height: 32),

            // Video Analysis Section
            _buildVideoAnalysisSection(frameResults),
            const SizedBox(height: 32),

            // Frame analysis section
            if (frameResults.isNotEmpty) ...[
              const Text(
                'Frame Analysis:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ...(_showAllFrames ? frameResults : frameResults.take(5)).map((frame) => _buildFrameCard(frame)),
              if (frameResults.length > 5)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _showAllFrames = !_showAllFrames;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.deepPurple, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _showAllFrames ? Icons.expand_less : Icons.expand_more,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _showAllFrames 
                              ? 'Show less' 
                              : '+ ${frameResults.length - 5} more frames',
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],

            // Action buttons
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoUploadScreen(asanaName: widget.asanaName),
                  ),
                );
              },
              child: const Text(
                'Retake Video',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.deepPurple, width: 2),
                foregroundColor: Colors.deepPurple,
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build video analysis section with real-time feedback
  Widget _buildVideoAnalysisSection(List<dynamic> frameResults) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.play_circle_filled, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  'Video Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Video display area with animated frame-by-frame feedback
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Simulated video frame display
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Display current frame image - no animation, just direct display
                      if (frameResults.isNotEmpty && _currentFrameIndex < frameResults.length)
                        ClipRRect(
                          key: ValueKey<int>(_currentFrameIndex),
                          borderRadius: BorderRadius.circular(12),
                          child: _buildFrameImage(frameResults[_currentFrameIndex]),
                        ),
                      
                      // Overlay with pose feedback - no animation
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: _currentFeedbackColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            _currentFeedback.isEmpty ? 'Ready to analyze' : _currentFeedback,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      
                      // Play controls overlay
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Frame ${_currentFrameIndex + 1}/${frameResults.length}',
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                                    onPressed: _currentFrameIndex > 0 ? _previousFrame : null,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                                    onPressed: _playFrameSequence,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.skip_next, color: Colors.white),
                                    onPressed: _currentFrameIndex < frameResults.length - 1 ? _nextFrame : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Frame progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: frameResults.isNotEmpty ? (_currentFrameIndex + 1) / frameResults.length : 0,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrameImage(dynamic frame) {
    final frameImage = frame['image'];
    if (frameImage == null || frameImage.toString().isEmpty) {
      return Container(
        width: double.infinity,
        height: 300,
        color: Colors.grey[800],
        child: const Center(
          child: Icon(Icons.videocam_off, size: 60, color: Colors.white54),
        ),
      );
    }
    
    try {
      return Image.memory(
        base64Decode(frameImage.split(',').last),
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        gaplessPlayback: true, // Prevents flashing between frame changes
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return frame != null ? child : Container(color: Colors.grey[900]);
        },
      );
    } catch (e) {
      return Container(
        width: double.infinity,
        height: 300,
        color: Colors.grey[800],
        child: const Center(
          child: Icon(Icons.broken_image, size: 60, color: Colors.white54),
        ),
      );
    }
  }

  void _previousFrame() {
    if (_currentFrameIndex > 0) {
      final newIndex = _currentFrameIndex - 1;
      final frameResults = (widget.analysisData?['frame_results'] as List?) ?? [];
      if (newIndex < frameResults.length) {
        final frame = frameResults[newIndex];
        final isCorrect = frame['is_correct'] ?? false;
        final pose = frame['pose_detected'] ?? 'Unknown';
        final confidence = ((frame['confidence'] ?? 0.0) * 100).toStringAsFixed(1);
        
        setState(() {
          _currentFrameIndex = newIndex;
          _currentFeedback = isCorrect 
              ? '✓ Correct Form - $pose ($confidence%)' 
              : '✗ Adjust Pose - $pose ($confidence%)';
          _currentFeedbackColor = isCorrect ? Colors.green : Colors.red;
        });
      }
    }
  }

  void _nextFrame() {
    final frameResults = (widget.analysisData?['frame_results'] as List?) ?? [];
    if (_currentFrameIndex < frameResults.length - 1) {
      final newIndex = _currentFrameIndex + 1;
      final frame = frameResults[newIndex];
      final isCorrect = frame['is_correct'] ?? false;
      final pose = frame['pose_detected'] ?? 'Unknown';
      final confidence = ((frame['confidence'] ?? 0.0) * 100).toStringAsFixed(1);
      
      setState(() {
        _currentFrameIndex = newIndex;
        _currentFeedback = isCorrect 
            ? '✓ Correct Form - $pose ($confidence%)' 
            : '✗ Adjust Pose - $pose ($confidence%)';
        _currentFeedbackColor = isCorrect ? Colors.green : Colors.red;
      });
    }
  }

  Future<void> _playFrameSequence() async {
    final frameResults = (widget.analysisData?['frame_results'] as List?) ?? [];
    for (int i = 0; i < frameResults.length; i++) {
      if (!mounted) break;
      
      final frame = frameResults[i];
      final isCorrect = frame['is_correct'] ?? false;
      final pose = frame['pose_detected'] ?? 'Unknown';
      final confidence = ((frame['confidence'] ?? 0.0) * 100).toStringAsFixed(1);
      
      setState(() {
        _currentFrameIndex = i;
        _currentFeedback = isCorrect 
            ? '✓ Correct Form - $pose ($confidence%)' 
            : '✗ Adjust Pose - $pose ($confidence%)';
        _currentFeedbackColor = isCorrect ? Colors.green : Colors.red;
      });
      await Future.delayed(const Duration(milliseconds: 800)); // Slower playback for smooth viewing
    }
  }

  /// Build a stat card
  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a frame analysis card
  Widget _buildFrameCard(Map<String, dynamic> frame) {
    final isCorrect = frame['is_correct'] ?? false;
    final confidence = (frame['confidence'] ?? 0.0) * 100;
    final pose = frame['pose_detected'] ?? 'Unknown';
    final frameNum = (frame['frame_number'] ?? 0) + 1;
    final frameFeedback = frame['feedback'] ?? '';
    final frameImage = frame['image']; // Base64 encoded image with data:image prefix
    
    // Debug: Print if image exists
    print('Frame $frameNum has image: ${frameImage != null && frameImage.toString().isNotEmpty}');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Frame image
          if (frameImage != null && frameImage.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.memory(
                base64Decode(frameImage.split(',').last), // Remove data:image prefix
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          
          // Frame details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frame $frameNum',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$pose • ${confidence.toStringAsFixed(1)}% confidence',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                      if (frameFeedback.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          frameFeedback,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
