import 'package:flutter/material.dart';
import 'subscription_page.dart';

class BusinessSelectionPage extends StatelessWidget {
  const BusinessSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pusat Bisnis Mitra', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Jalur Bisnis Anda',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Tentukan bagaimana Anda ingin mulai menghasilkan uang dan membantu komunitas kesehatan di FitMotion.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 32),
            
            // OPSI TRAINER
            _buildBusinessCard(
              context,
              icon: Icons.sports,
              color: Colors.orange,
              title: 'Pelatih Profesional',
              description: 'Buka jasa personal trainer, buat rencana latihan kustom, dan bimbing klien secara langsung.',
              role: 'trainer',
            ),
            
            const SizedBox(height: 20),
            
            // OPSI GYM
            _buildBusinessCard(
              context,
              icon: Icons.fitness_center,
              color: Colors.blue.shade700,
              title: 'Mitra Pusat Gym',
              description: 'Daftarkan fasilitas kebugaran Anda, kelola member, dan promosikan alat-alat gym terbaik Anda.',
              role: 'gym',
            ),
            
            const SizedBox(height: 40),
            
            // FOOTER INFO
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Setiap jalur memiliki fitur dashboard manajemen yang berbeda sesuai kebutuhan Anda.',
                      style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessCard(BuildContext context, {required IconData icon, required Color color, required String title, required String description, required String role}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubscriptionPage(roleType: role))),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
