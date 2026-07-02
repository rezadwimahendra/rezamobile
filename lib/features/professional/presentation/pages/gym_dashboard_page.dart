import 'package:flutter/material.dart';
import './manage_portfolio_page.dart';
import './setup_professional_page.dart';

class GymDashboardPage extends StatelessWidget {
  final String userName;
  const GymDashboardPage({super.key, required this.userName});

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
          'Gym Management',
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
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.apartment, color: primaryColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Selamat Datang Mitra,', style: TextStyle(color: Colors.black54, fontSize: 13)),
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

              const Text('OPERASIONAL HARI INI', style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatusCard('Kunjungan', '0', Icons.login, Colors.green),
                  const SizedBox(width: 12),
                  _buildStatusCard('Member Baru', '0', Icons.person_add, Colors.blue),
                  const SizedBox(width: 12),
                  _buildStatusCard('Sesi Aktif', '0', Icons.fitness_center, Colors.orange),
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
                    Icons.store_outlined, 
                    'Profil Publik', 
                    'Atur Lokasi, Harga & Bio',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupProfessionalPage(roleType: 'gym'))),
                  ),
                  _buildActionCard(Icons.qr_code_scanner, 'Check-in Member', 'Konfirmasi Kedatangan'),
                  _buildActionCard(Icons.card_membership, 'Paket Member', 'Atur Harga & Benefit'),
                  _buildActionCard(Icons.people_outline, 'Manajemen Staff', 'Kelola Trainer & Tim'),
                ],
              ),

              const SizedBox(height: 40),
              
              const Text('RINGKASAN MINGGUAN', style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    Icon(Icons.bar_chart_rounded, color: primaryColor.withOpacity(0.2), size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Data statistik kunjungan member\nakan muncul di sini minggu depan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black45, fontSize: 13, height: 1.5),
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

  Widget _buildStatusCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(
              value, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              label, 
              style: const TextStyle(color: Colors.black38, fontSize: 10),
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
