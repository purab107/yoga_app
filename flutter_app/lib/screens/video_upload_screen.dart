import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'processing_screen.dart';
import 'dart:typed_data';

/// Screen to upload video for selected asana
class VideoUploadScreen extends StatefulWidget {
  final String asanaName;

  const VideoUploadScreen({super.key, required this.asanaName});

  @override
  State<VideoUploadScreen> createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  String? _selectedVideoName;
  Uint8List? _selectedVideoBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Video'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display selected asana name
            Text(
              'Selected Asana:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.asanaName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),

            // Upload video button
            OutlinedButton.icon(
              onPressed: _selectVideo,
              icon: const Icon(Icons.video_library),
              label: const Text('Upload Video'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.deepPurple, width: 2),
                foregroundColor: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 24),

            // Show selected video name
            if (_selectedVideoName != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.video_file, color: Colors.deepPurple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedVideoName!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 40),

            // Analyze button (enabled only if video selected)
            ElevatedButton(
              onPressed: _selectedVideoName != null ? _analyzeVideo : null,
              child: const Text(
                'Analyze',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Real video selection using file picker
  Future<void> _selectVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _selectedVideoBytes = result.files.single.bytes;
          _selectedVideoName = result.files.single.name;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video selected'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Navigate to processing screen with video bytes
  void _analyzeVideo() {
    if (_selectedVideoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a video first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProcessingScreen(
          asanaName: widget.asanaName,
          videoBytes: _selectedVideoBytes!,
          videoName: _selectedVideoName ?? 'video.mp4',
        ),
      ),
    );
  }
}
