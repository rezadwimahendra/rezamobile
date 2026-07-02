import 'package:flutter/material.dart';

class MoreTab extends StatelessWidget {
  final Color primaryColor;
  final String userName;
  final VoidCallback onLogout;

  const MoreTab({
    super.key,
    required this.primaryColor,
    required this.userName,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final String initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profil Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            color: primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.pink.shade400,
                  child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black)),
                      const Text('Anggota FitMotion Reguler', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ),
                const Icon(Icons.edit, color: Colors.grey)
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Daftar Pengaturan
          ListTile(
            leading: Icon(Icons.person, color: primaryColor),
            title: const Text('Profil Saya', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.flag, color: primaryColor),
            title: const Text('Sasaran Kalori & Nutrisi', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.emoji_events, color: primaryColor),
            title: const Text('Riwayat Prestasi (Badge)', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.settings, color: primaryColor),
            title: const Text('Pengaturan Aplikasi', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {},
          ),
          
          const SizedBox(height: 48),
          
          // Tombol Logout Merah
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ElevatedButton(
              onPressed: onLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 20),
                  SizedBox(width: 8),
                  Text('Keluar Akun (Logout)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
