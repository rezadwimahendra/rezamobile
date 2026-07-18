import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

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
        title: const Text('Pusat Bantuan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apa yang bisa kami bantu?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // FAQ SECTION
            _buildSectionHeader('TANYA JAWAB (FAQ)'),
            _buildActionCard(
              child: Column(
                children: [
                  _buildExpansionTile('Bagaimana cara mencatat makanan?', 'Anda bisa menggunakan fitur scan AI di dashboard atau mencari makanan secara manual di tab nutrisi.'),
                  _buildDivider(),
                  _buildExpansionTile('Cara menjadi pelatih profesional?', 'Buka menu Profil > Pusat Bisnis Mitra, lalu pilih paket Pelatih Profesional.'),
                  _buildDivider(),
                  _buildExpansionTile('Apakah data saya aman?', 'Ya, semua data kesehatan dan profil Anda aman tersimpan dan terenkripsi di server kami.'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // CONTACT SUPPORT
            _buildSectionHeader('HUBUNGI KAMI'),
            _buildActionCard(
              child: Column(
                children: [
                  _buildListMenu(
                    icon: Icons.support_agent,
                    title: 'Customer Service (WhatsApp)',
                    iconColor: Colors.green,
                    onTap: () => _launchURL(context, 'https://wa.me/6282371362312?text=Halo%20FitMotion%20Support'),
                  ),
                  _buildDivider(),
                  _buildListMenu(
                    icon: Icons.mail_outline,
                    title: 'Email Support',
                    iconColor: Colors.blue,
                    onTap: () => _launchURL(context, 'mailto:support@fitmotion.com?subject=FitMotion%20Support%20Request'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            // APP VERSION
            Center(
              child: Column(
                children: [
                  Text(
                    'FitMotion Professional',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Versi 1.0.0 (Build 2026)',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
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

  Widget _buildActionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: child,
    );
  }

  Widget _buildExpansionTile(String title, String content) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Text(content, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5)),
      ],
      shape: const RoundedRectangleBorder(side: BorderSide.none),
    );
  }

  Widget _buildListMenu({required IconData icon, required String title, Color? iconColor, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: (iconColor ?? Colors.black).withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor ?? Colors.black87, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() => Divider(height: 1, color: Colors.grey.shade50, indent: 60);

  Future<void> _launchURL(BuildContext context, String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak dapat membuka link: $urlString'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
