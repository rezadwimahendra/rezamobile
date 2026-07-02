import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifikasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3, // Dummy count
        itemBuilder: (context, index) {
          final titles = ['Latihan Hari Ini', 'Target Kalori Tercapai', 'Update dari Pelatih'];
          final subs = ['Ayo mulai sesi Full Body Workout kamu!', 'Selamat! Kamu sudah memenuhi target kalori harian.', 'Pelatih Budi mengirimkan feedback untukmu.'];
          final times = ['10 menit lalu', '2 jam lalu', 'Kemarin'];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titles[index], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 6),
                      Text(subs[index], style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(times[index], style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
              ],
            ),
          );
        },
      ),
    );
  }
}
