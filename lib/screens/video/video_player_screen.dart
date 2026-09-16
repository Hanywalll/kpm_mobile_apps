import 'package:flutter/material.dart';

class VideoPlayerScreen extends StatelessWidget {
  const VideoPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Player')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 220,
            color: Colors.black,
            child: const Center(
              child: Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konsep Dasar Matematika UTBK',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text('Tutor: Dr. Budi • 15:30'),
                Divider(height: 24),
                Text(
                  'Deskripsi Video:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  'Video pembelajaran ini membahas trik cepat mengerjakan soal TPS Kuantitatif SNBT.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
