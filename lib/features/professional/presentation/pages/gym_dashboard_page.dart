import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../../../injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/professional_bloc.dart';
import '../bloc/professional_event.dart';
import '../bloc/professional_state.dart';
import './setup_professional_page.dart';
import './consultation_history_page.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/pages/complete_profile_page.dart';
import '../../../profile/presentation/pages/security_settings_page.dart';
import '../../../profile/presentation/pages/help_center_page.dart';

class GymDashboardPage extends StatefulWidget {
  final String userName;
  const GymDashboardPage({super.key, required this.userName});

  @override
  State<GymDashboardPage> createState() => _GymDashboardPageState();
}

class _GymDashboardPageState extends State<GymDashboardPage> {
  @override
  void initState() {
    super.initState();
    final userId = sl<AuthBloc>().state.user?.id;
    if (userId != null) {
      context.read<ProfessionalBloc>().add(
        ProfessionalDataRequested(userId: userId, role: 'gym'),
      );
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 24, bottom: 12),
      child: Text(
        title, 
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1.2)
      ),
    );
  }

  Widget _buildMenuCard({required List<Widget> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(children: items),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon, 
    String title, 
    String subtitle,
    Color accentColor,
    {VoidCallback? onTap}
  ) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.1), 
          borderRadius: BorderRadius.circular(12)
        ),
        child: Icon(icon, color: accentColor, size: 20),
      ),
      title: Text(
        title, 
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    const scaffoldBg = Color(0xFFF8FAFC);
    final baseUrl = sl<PocketBase>().baseUrl;

    return BlocBuilder<ProfessionalBloc, ProfessionalState>(
      builder: (context, state) {
        final prof = state.professional;
        String? imageUrl;
        if (prof != null && prof.avatar != null && prof.avatar!.toString().trim().isNotEmpty) {
          imageUrl = "$baseUrl/api/files/gyms/${prof.id}/${prof.avatar}";
        }
        if (imageUrl != null && imageUrl.endsWith('/')) {
          imageUrl = null;
        }

        final displayUserName = prof?.name ?? widget.userName;

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Gym Management',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flat Header (matching profile_page.dart layout)
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryColor, width: 2),
                            image: imageUrl != null 
                                ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                                : null,
                          ),
                          child: imageUrl == null 
                              ? Icon(Icons.apartment, color: primaryColor, size: 44)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          displayUserName, 
                          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'FitMotion Gym Partner', 
                          style: TextStyle(color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  // Quick Actions
                  _buildSectionHeader('QUICK ACTIONS'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildMenuCard(
                      items: [
                        _buildMenuItem(
                          context,
                          Icons.store_outlined, 
                          'Profil Publik', 
                          'Atur Lokasi, Harga & Bio',
                          Colors.blue,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupProfessionalPage(roleType: 'gym'))),
                        ),
                        const Divider(color: Color(0xFFF1F5F9), height: 1, indent: 56),
                        _buildMenuItem(
                          context,
                          Icons.chat_bubble_outline, 
                          'Chat Konsultasi', 
                          'Pesan Baru Klien',
                          Colors.orange,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConsultationHistoryPage())),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
