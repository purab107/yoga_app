import 'package:flutter/material.dart';
import 'asana_selection_screen.dart';

/// Home screen with main navigation options
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yoga App'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Primary action button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AsanaSelectionScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Analyze Yoga Asana',
                  style: TextStyle(fontSize: 18),
                ),
              ),

              const SizedBox(height: 60),

              // Other exercises section
              const Text(
                'Other Exercises',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 24),

              // Locked exercise cards
              _buildLockedCard(context, 'Strength Training', Icons.fitness_center),
              const SizedBox(height: 16),
              _buildLockedCard(context, 'Mobility', Icons.accessibility_new),
              const SizedBox(height: 16),
              _buildLockedCard(context, 'Physiotherapy', Icons.healing),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a locked exercise card
  Widget _buildLockedCard(BuildContext context, String title, IconData icon) {
    return Opacity(
      opacity: 0.5,
      child: Card(
        elevation: 2,
        child: ListTile(
          leading: Icon(icon, size: 32, color: Colors.grey),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          trailing: const Icon(Icons.lock, color: Colors.grey),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Coming Soon'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
      ),
    );
  }
}
