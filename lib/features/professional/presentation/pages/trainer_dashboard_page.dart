import 'package:flutter/material.dart';
import './manage_portfolio_page.dart';
import './setup_professional_page.dart';

class TrainerDashboardPage extends StatelessWidget {
  final String userName;
  const TrainerDashboardPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    const scaffoldBg = Color(0xFFF8F9FA);
    
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'FitMotion Pro',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black54),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Icon(Icons.person, color: primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Selamat Datang,', style: TextStyle(color: Colors.black54, fontSize: 13)),
                        Text(
                          userName, 
                          style: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  _buildStatCard('Total Klien', '0', Icons.groups_outlined, primaryColor),
                  const SizedBox(width: 16),
                  _buildStatCard('Rating Pelatih', '5.0', Icons.star_outline, primaryColor),
                ],
              ),
              const SizedBox(height: 32),

              const Text('QUICK ACTIONS', style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1, 
                children: [
                  _buildActionCard(
                    Icons.badge_outlined, 
                    'Profil Publik', 
                    'Atur Bio, Nama & Harga',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupProfessionalPage(roleType: 'trainer'))),
                  ),
                  _buildActionCard(Icons.people_alt_outlined, 'Daftar Klien', 'Pantau Progres Member'),
                  _buildActionCard(Icons.chat_bubble_outline, 'Chat Konsultasi', 'Pesan Baru Klien'),
                  _buildActionCard(Icons.access_time, 'Jam Operasional', 'Atur Ketersediaan Anda'),
                ],
              ),

              const SizedBox(height: 32),

              const Text('JADWAL HARI INI', style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.event_available_outlined, color: Colors.grey.shade300, size: 40),
                    const SizedBox(height: 12),
                    const Text(
                      'Tidak ada sesi latihan hari ini.',
                      style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 12),
            Text(
              value, 
              style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              label, 
              style: const TextStyle(color: Colors.black38, fontSize: 11),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black87, size: 22),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title, 
                style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                subtitle, 
                style: const TextStyle(color: Colors.black38, fontSize: 9),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
