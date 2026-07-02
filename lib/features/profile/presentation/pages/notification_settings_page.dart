import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _foodReminder = true;
  bool _workoutReminder = true;
  bool _professionalUpdate = true;
  bool _weeklyReport = false;

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
        title: const Text('Pengaturan Notifikasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('AKTIVITAS'),
            _buildSettingCard([
              _buildToggleItem(
                icon: Icons.restaurant_menu,
                color: Colors.orange,
                title: 'Pengingat Makan',
                subtitle: 'Ingatkan saya untuk mencatat makanan harian.',
                value: _foodReminder,
                onChanged: (val) => setState(() => _foodReminder = val),
              ),
              _buildDivider(),
              _buildToggleItem(
                icon: Icons.fitness_center,
                color: Colors.blue,
                title: 'Pengingat Latihan',
                subtitle: 'Notifikasi jadwal latihan yang sudah dibuat.',
                value: _workoutReminder,
                onChanged: (val) => setState(() => _workoutReminder = val),
              ),
            ]),
            
            const SizedBox(height: 32),
            
            _buildSectionHeader('PROFESIONAL & UPDATE'),
            _buildSettingCard([
              _buildToggleItem(
                icon: Icons.verified_user_outlined,
                color: Colors.green,
                title: 'Update Pelatih',
                subtitle: 'Pesan masuk dan feedback dari pelatih Anda.',
                value: _professionalUpdate,
                onChanged: (val) => setState(() => _professionalUpdate = val),
              ),
              _buildDivider(),
              _buildToggleItem(
                icon: Icons.analytics_outlined,
                color: Colors.purple,
                title: 'Laporan Mingguan',
                subtitle: 'Ringkasan kemajuan kebugaran setiap minggu.',
                value: _weeklyReport,
                onChanged: (val) => setState(() => _weeklyReport = val),
              ),
            ]),
            
            const SizedBox(height: 40),
            
            Center(
              child: Text(
                'Anda dapat menonaktifkan semua notifikasi kapan saja melalui pengaturan sistem perangkat Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1),
      ),
    );
  }

  Widget _buildSettingCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.black,
      ),
    );
  }

  Widget _buildDivider() => Divider(height: 1, color: Colors.grey.shade50, indent: 60);
}
