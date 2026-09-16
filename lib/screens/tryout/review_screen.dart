import 'package:flutter/material.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembahasan Soal')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Soal No. ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: index == 2 ? Colors.red.shade100 : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          index == 2 ? 'Jawaban Salah' : 'Jawaban Benar',
                          style: TextStyle(
                            color: index == 2 ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Berapakah hasil dari 2^${index + 1} + ${index * 5}?'),
                  const SizedBox(height: 12),
                  Text('Jawaban Anda: A', style: TextStyle(color: index == 2 ? Colors.red : Colors.green)),
                  const Text('Kunci Jawaban: A', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  const Text('Pembahasan:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Gunakan perpangkatan dasar 2^n kemudian jumlahkan dengan suku berikutnya secara langsung.'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
