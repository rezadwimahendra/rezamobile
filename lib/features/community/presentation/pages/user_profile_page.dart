import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:fitness_app/injection.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../professional/presentation/bloc/professional_bloc.dart';
import '../../../professional/presentation/bloc/professional_event.dart';
import '../../../professional/presentation/bloc/professional_state.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final String userName;
  final bool isTrainer;
  final bool isGym;

  const UserProfilePage({
    super.key,
    required this.userId,
    required this.userName,
    required this.isTrainer,
    required this.isGym,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    final role = widget.isTrainer ? 'trainer' : 'gym';
    context.read<ProfessionalBloc>().add(ProfessionalDataRequested(userId: widget.userId, role: role));
  }

  Future<void> _openExternalMapApp(double latitude, double longitude) async {
    final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final appleMapsUrl = 'https://maps.apple.com/?q=$latitude,$longitude';

    try {
      final googleMapsUri = Uri.parse(googleMapsUrl);
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        final appleMapsUri = Uri.parse(appleMapsUrl);
        await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak dapat membuka peta: $e')),
          );
        }
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 28, bottom: 8),
      child: Text(
        title, 
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 1.0)
      ),
    );
  }

  Widget _buildMenuCard({required List<Widget> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(children: items),
    );
  }

  Widget _buildRowItem(IconData icon, String title, String value, {VoidCallback? onTap}) {
    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: const Color(0xFF94A3B8), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.bold, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: body,
      );
    }
    return body;
  }

  Widget _buildLocationRow(dynamic prof) {
    final hasCoords = prof.latitude != null && prof.longitude != null && prof.latitude != 0.0 && prof.longitude != 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.location_on_outlined, color: Color(0xFF94A3B8), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lokasi', 
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 6),
                Text(
                  prof.location!,
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.bold, height: 1.4),
                ),
                if (hasCoords) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _openExternalMapApp(prof.latitude!, prof.longitude!),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.near_me_rounded, color: Colors.blue, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Petunjuk Rute (Maps)',
                          style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final baseUrl = sl<PocketBase>().baseUrl;

    return BlocBuilder<ProfessionalBloc, ProfessionalState>(
      builder: (context, state) {
        final prof = state.professional;
        final filteredGallery = prof?.gallery
            ?.where((item) => item.toString().trim().isNotEmpty && item.toString().trim() != '/')
            .toList() ?? [];
        final hasGallery = filteredGallery.isNotEmpty;
        final collection = widget.isTrainer ? 'trainers' : 'gyms';

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.isTrainer ? 'Profil Pelatih' : 'Profil Gym',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            centerTitle: true,
          ),
          body: (state.status == ProfessionalStatus.loading)
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : (state.status == ProfessionalStatus.error || prof == null)
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'Gagal memuat profil: ${state.errorMessage ?? "Penyebab tidak diketahui"}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _fetchData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Coba Lagi'),
                            )
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Header Block
                          Container(
                            width: double.infinity,
                            color: Colors.white,
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                            child: Column(
                              children: [
                                _buildAvatar(prof, baseUrl, collection, primaryColor),
                                const SizedBox(height: 16),
                                Text(
                                  prof.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.isTrainer 
                                      ? (prof.specialty?.isNotEmpty == true 
                                          ? prof.specialty!.split(RegExp(r'[,\u2022\u00b7]')).first.trim() 
                                          : 'Professional Trainer')
                                      : 'FitMotion Gym Partner',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),

                          // Contact Button (If not current user)
                          if (context.read<AuthBloc>().state.user?.id != widget.userId)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                              child: SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatPage(
                                          receiverId: widget.userId,
                                          receiverName: widget.userName,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: const Color(0xFF0F172A),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'Kirim Pesan Chat',
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                                  ),
                                ),
                              ),
                            ),

                          // Description Section
                          _buildSectionHeader('TENTANG'),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildMenuCard(
                              items: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    prof.description.isNotEmpty ? prof.description : 'Tidak ada deskripsi profil.',
                                    style: const TextStyle(color: Color(0xFF475569), height: 1.6, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Profile Details Section
                          _buildSectionHeader('INFORMASI LAYANAN'),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildMenuCard(
                              items: [
                                if (widget.isTrainer && prof.specialty != null && prof.specialty!.isNotEmpty) ...[
                                  _buildRowItem(
                                    Icons.fitness_center_rounded,
                                    'Spesialisasi',
                                    prof.specialty!,
                                  ),
                                  const Divider(color: Color(0xFFF1F5F9), height: 1, indent: 20, endIndent: 20),
                                ],
                                _buildRowItem(
                                  Icons.payments_outlined,
                                  widget.isTrainer ? 'Tarif Per Sesi' : 'Membership Per Bulan',
                                  'Rp ${prof.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                ),
                                if (!widget.isTrainer && prof.nonMemberPrice != null) ...[
                                  const Divider(color: Color(0xFFF1F5F9), height: 1, indent: 20, endIndent: 20),
                                  _buildRowItem(
                                    Icons.confirmation_num_outlined,
                                    'Tiket Harian',
                                    'Rp ${prof.nonMemberPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                  ),
                                ],
                                if (prof.location != null && prof.location!.isNotEmpty) ...[
                                  const Divider(color: Color(0xFFF1F5F9), height: 1, indent: 20, endIndent: 20),
                                  _buildLocationRow(prof),
                                ],
                              ],
                            ),
                          ),

                          // Gallery Section
                          _buildSectionHeader('PORTFOLIO & GALERI'),
                          if (hasGallery)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredGallery.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3, 
                                  crossAxisSpacing: 10, 
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1.0,
                                ),
                                itemBuilder: (context, index) {
                                  final fileUrl = "$baseUrl/api/files/$collection/${prof.id}/${filteredGallery[index]}";
                                  return GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => Dialog.fullscreen(
                                          backgroundColor: Colors.black.withOpacity(0.95),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              GestureDetector(
                                                onTap: () => Navigator.pop(context),
                                                child: Container(
                                                  color: Colors.transparent,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  child: InteractiveViewer(
                                                    child: Image.network(
                                                      fileUrl,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: MediaQuery.of(context).padding.top + 16,
                                                right: 20,
                                                child: GestureDetector(
                                                  onTap: () => Navigator.pop(context),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.2),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                      size: 22,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFF1F5F9)),
                                        image: DecorationImage(image: NetworkImage(fileUrl), fit: BoxFit.cover),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            _buildEmptyGallery(),

                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildAvatar(dynamic prof, String baseUrl, String collection, Color primaryColor) {
    String? imageUrl;
    if (prof != null && prof.avatar != null && prof.avatar!.toString().trim().isNotEmpty) {
      imageUrl = "$baseUrl/api/files/$collection/${prof.id}/${prof.avatar}";
    }

    if (imageUrl != null && imageUrl.endsWith('/')) {
      imageUrl = null;
    }

    return Center(
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          image: imageUrl != null ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null,
        ),
        child: imageUrl == null
            ? Icon(widget.isTrainer ? Icons.person : Icons.apartment, size: 40, color: Colors.grey.shade400)
            : null,
      ),
    );
  }

  Widget _buildEmptyGallery() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: const Center(
        child: Text(
          'Belum ada portofolio.',
          style: TextStyle(
            color: Color(0xFF94A3B8), 
            fontSize: 13, 
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}


