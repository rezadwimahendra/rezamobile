import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../../injection.dart';

import '../../../professional/presentation/pages/trainer_dashboard_page.dart';
import '../../../professional/presentation/pages/gym_dashboard_page.dart';
import '../../../professional/presentation/pages/subscription_page.dart';
import '../../../auth/presentation/pages/complete_profile_page.dart';
import './security_settings_page.dart';
import './help_center_page.dart';

class ProfilePage extends StatelessWidget {
  final String userName;
  final String userRole;

  const ProfilePage({
    super.key,
    required this.userName,
    required this.userRole,
  });

  void _logout(BuildContext context) {
    context.read<AuthBloc>().add(LogoutRequested());
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null && context.mounted) {
      context.read<AuthBloc>().add(UpdateAvatarRequested(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFFB800);
    final pb = sl<PocketBase>();
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Profil Saya', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CompleteProfilePage()));
            },
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) => 
            (previous.isUploadingAvatar == true && current.isUploadingAvatar == false) ||
            (previous.status == AuthStatus.authenticated && current.status == AuthStatus.unauthenticated),
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            return;
          }
          if (state.avatarErrorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal memperbarui foto profil: ${state.avatarErrorMessage}'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            // Bersihkan cache gambar agar gambar baru segera dimuat
            PaintingBinding.instance.imageCache.clear();
            PaintingBinding.instance.imageCache.clearLiveImages();
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto profil berhasil diperbarui!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          final user = state.user;
          final String displayUserName = user?.name ?? userName;
          final String initial = displayUserName.isNotEmpty ? displayUserName[0].toUpperCase() : 'U';

          String memberStatus = 'Member Reguler';
          if (user != null) {
            if (user.isTrainer && user.isGym) {
              memberStatus = 'Premium Business Partner';
            } else if (user.isTrainer) {
              memberStatus = 'Professional Trainer';
            } else if (user.isGym) {
              memberStatus = 'Business Partner';
            } else if (user.role == 'pro') {
              if (user.isSubscriptionActive) {
                memberStatus = 'FitMotion Pro';
              } else {
                memberStatus = 'Premium Berakhir';
              }
            }
          }

          final avatarUrl = (user?.avatar != null && user!.avatar!.isNotEmpty)
              ? "${pb.baseUrl}/api/files/users/${user.id}/${user.avatar}?t=${user.updated}"
              : null;

          debugPrint('DEBUG: profile page avatarUrl = $avatarUrl');

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // HEADER AREA
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle, 
                              border: Border.all(color: primaryColor.withOpacity(0.5), width: 2)
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey.shade100,
                              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                              child: avatarUrl == null 
                                ? Text(initial, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black87))
                                : null,
                            ),
                          ),
                          if (state.isUploadingAvatar == true)
                            Positioned.fill(
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black38,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(color: primaryColor),
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: state.isUploadingAvatar == true ? null : () => _pickImage(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                                child: state.isUploadingAvatar == true
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                                    )
                                  : const Icon(Icons.camera_alt, color: Colors.black, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        displayUserName, 
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        memberStatus, 
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 24),
                      


                      // PHYSICAL STATS ROW
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: _buildStatItem('Umur', '${user?.age ?? 0}', 'thn')),
                            _buildDividerVertical(),
                            Expanded(child: _buildStatItem('Tinggi', '${user?.height ?? 0}', 'cm')),
                            _buildDividerVertical(),
                            Expanded(child: _buildStatItem('Berat', '${user?.initialWeight ?? 0}', 'kg')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // SECTION 1: PRO
                _buildSectionHeader('LAYANAN PROFESIONAL'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildMenuCard(
                    items: [
                      _buildMenuItem(
                        Icons.verified_user_outlined, 
                        'FitMotion Pro Trainer', 
                        () {
                          if (user?.hasTrainerRole ?? false) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => TrainerDashboardPage(userName: user!.name)));
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionPage(roleType: 'trainer')));
                          }
                        },
                      ),
                      _buildMenuItem(
                        Icons.storefront_outlined, 
                        'FitMotion Business Partner', 
                        () {
                          if (user?.hasGymRole ?? false) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => GymDashboardPage(userName: user!.name)));
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionPage(roleType: 'gym')));
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // SECTION 2: ACCOUNTS
                _buildSectionHeader('PENGATURAN AKUN'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildMenuCard(
                    items: [
                      _buildMenuItem(Icons.person_outline, 'Informasi Pribadi', () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CompleteProfilePage()));
                      }),
                      _buildMenuItem(Icons.shield_outlined, 'Keamanan Akun', () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsPage()));
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // SECTION 3: SUPPORT
                _buildSectionHeader('DUKUNGAN'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildMenuCard(
                    items: [
                      _buildMenuItem(Icons.help_outline, 'Pusat Bantuan', () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterPage()));
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // LOGOUT
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: InkWell(
                    onTap: () {
                      _logout(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'Keluar dari Akun', 
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 15)
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 12),
      child: Text(
        title, 
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1.2)
      ),
    );
  }



  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
            const SizedBox(width: 4),
            Text(unit, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildDividerVertical() {
    return Container(height: 24, width: 1, color: Colors.grey.shade200);
  }

  Widget _buildMenuCard({required List<Widget> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
      title: Text(
        title, 
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
