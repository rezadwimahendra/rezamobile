import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/professional_bloc.dart';
import '../../bloc/professional_state.dart';
import '../../pages/setup_professional_page.dart';
import 'trainer_clients_tab.dart';
import 'trainer_programs_tab.dart';

class TrainerDashboardTab extends StatelessWidget {
  final Color primaryColor;

  const TrainerDashboardTab({super.key, required this.primaryColor});

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
                'Ringkasan Hari Ini',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              
              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Klien Aktif',
                      value: '12',
                      icon: Icons.people_alt,
                      color: Colors.blue.shade100,
                      iconColor: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Sesi Hari Ini',
                      value: '3',
                      icon: Icons.calendar_today,
                      color: Colors.orange.shade100,
                      iconColor: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              const Text(
                'Kelola Pelatihan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGridMenu(context, Icons.people, 'Klien\nSaya', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('Klien Saya')),
                      body: SafeArea(child: TrainerClientsTab(primaryColor: primaryColor)),
                    )));
                  }),
                  _buildGridMenu(context, Icons.assignment, 'Program\nLatihan', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('Program Latihan')),
                      body: SafeArea(child: TrainerProgramsTab(primaryColor: primaryColor)),
                    )));
                  }),
                  _buildGridMenu(context, Icons.storefront, 'Profil\nPublik', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupProfessionalPage(roleType: 'trainer')));
                  }),
                ],
              ),
              
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jadwal Mendatang',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('Lihat Semua', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              _buildScheduleItem(
                time: '14:00',
                clientName: 'Budi Santoso',
                type: 'Personal Training - Chest',
              ),
              _buildScheduleItem(
                time: '16:30',
                clientName: 'Siti Aminah',
                type: 'Virtual Coaching - Cardio',
              ),
              _buildScheduleItem(
                time: '19:00',
                clientName: 'Agus Pratama',
                type: 'Consultation - Diet Plan',
              ),
              
              const SizedBox(height: 32),
              
              const Text(
                'Aktivitas Klien Terbaru',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              
              _buildActivityItem('Andi menyelesaikan rencana latihan punggung.', '2 jam lalu'),
              _buildActivityItem('Rina mencatat defisit 300 kalori hari ini.', '5 jam lalu'),
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
        color: color.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: iconColor),
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

  Widget _buildScheduleItem({required String time, required String clientName, required String type}) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(type, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            height: 10,
            width: 10,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(color: Colors.black87, fontSize: 14)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
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
