import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/professional_bloc.dart';
import '../../bloc/professional_state.dart';
import '../../pages/setup_professional_page.dart';
import 'gym_facilities_tab.dart';

class GymDashboardTab extends StatelessWidget {
  final Color primaryColor;

  const GymDashboardTab({super.key, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfessionalBloc, ProfessionalState>(
      builder: (context, state) {
        if (state.status == ProfessionalStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ringkasan Bisnis Hari Ini',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              
              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Anggota Gym Aktif',
                      value: '145',
                      icon: Icons.card_membership,
                      color: primaryColor.withOpacity(0.3),
                      iconColor: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Kunjungan Hari Ini',
                      value: '342',
                      icon: Icons.directions_run,
                      color: Colors.teal.shade100,
                      iconColor: Colors.teal.shade800,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              const Text(
                'Kelola Operasional',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGridMenu(context, Icons.fitness_center, 'Fasilitas\nGym', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('Fasilitas Gym')),
                      body: SafeArea(child: GymFacilitiesTab(primaryColor: primaryColor)),
                    )));
                  }),
                  _buildGridMenu(context, Icons.people_outline, 'Manajemen\nMember', onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Segera Datang: Manajemen Member')));
                  }),
                   _buildGridMenu(context, Icons.storefront, 'Profil\nPublik', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupProfessionalPage(roleType: 'gym')));
                  }),
                ],
              ),
              
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Member Check-in Terbaru',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('Lihat Semua', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              _buildCheckInItem(time: 'Baru saja', name: 'Andi Wijaya', status: 'Masuk'),
              _buildCheckInItem(time: '15 menit lalu', name: 'Rina Wati', status: 'Selesai'),
              _buildCheckInItem(time: '45 menit lalu', name: 'Budi Santoso', status: 'Masuk'),
              
              const SizedBox(height: 32),
              
              const Text(
                'Status Fasilitas & Alat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              
              _buildFacilityStatus('Treadmill no. 3 perlu perbaikan', Icons.warning_amber_rounded, Colors.orange),
              _buildFacilityStatus('Semua loker dalam keadaan baik', Icons.check_circle_outline, Colors.green),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: iconColor),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: iconColor.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInItem({required String time, required String name, required String status}) {
    final isMasuk = status == 'Masuk';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(
            isMasuk ? Icons.login : Icons.logout,
            color: isMasuk ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isMasuk ? Colors.green.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isMasuk ? Colors.green.shade700 : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 11
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityStatus(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.black87, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildGridMenu(BuildContext context, IconData icon, String label, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black87, height: 1.2),
          )
        ],
      ),
    );
  }
}
