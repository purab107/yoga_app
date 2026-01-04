import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'results_screen.dart';
import '../config/api_config.dart';

/// Processing screen with loading indicator
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

  @override
  void initState() {
    super.initState();
    _processAndNavigate();
  }

  /// Process video with backend API and navigate to results
  Future<void> _processAndNavigate() async {
    try {
      setState(() {
        _statusMessage = 'Uploading video...';
      });

      // Prepare multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.analyzeEndpoint),
      );

      // Add video file from bytes
      request.files.add(
        http.MultipartFile.fromBytes(
          'video',
          widget.videoBytes,
          filename: widget.videoName,
          contentType: MediaType('video', 'mp4'),
        ),
      );

      // Add expected pose
      request.fields['expected_pose'] = widget.asanaName;

      setState(() {
        _statusMessage = 'Processing video...';
      });

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsScreen(
                asanaName: widget.asanaName,
                analysisData: data,
                videoBytes: widget.videoBytes,
                videoName: widget.videoName,
              ),
            ),
          );
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e\n\nMake sure backend is accessible at:\n${ApiConfig.baseUrl}'),
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
