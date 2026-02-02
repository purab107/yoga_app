import 'package:flutter/material.dart';
import 'video_upload_screen.dart';

/// Screen to select a yoga asana for analysis
class AsanaSelectionScreen extends StatelessWidget {
  const AsanaSelectionScreen({super.key});

  // Hardcoded list of asanas
  static const List<Map<String, dynamic>> asanas = [
    {'name': 'Anantasana', 'icon': Icons.self_improvement},
    {'name': 'Ardhakati Chakrasana', 'icon': Icons.accessibility},
    {'name': 'Bhujangasana', 'icon': Icons.accessibility_new},
    {'name': 'Kati Chakrasana', 'icon': Icons.self_improvement},
    {'name': 'Marjariasana', 'icon': Icons.pets},
    {'name': 'Parvatasana', 'icon': Icons.filter_hdr},
    {'name': 'Sarvangasana', 'icon': Icons.accessible},
    {'name': 'Tadasana', 'icon': Icons.man},
    {'name': 'Vajrasana', 'icon': Icons.airline_seat_recline_normal},
    {'name': 'Viparita Karani', 'icon': Icons.transfer_within_a_station},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Asana'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: asanas.length,
          itemBuilder: (context, index) {
            return _buildAsanaCard(
              context,
              asanas[index]['name'] as String,
              asanas[index]['icon'] as IconData,
            );
          },
        ),
      ),
    );
  }

  /// Build an asana selection card
  Widget _buildAsanaCard(BuildContext context, String name, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoUploadScreen(asanaName: name),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
