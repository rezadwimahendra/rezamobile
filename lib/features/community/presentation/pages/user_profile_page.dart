import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:fitness_app/injection.dart';
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

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final baseUrl = sl<PocketBase>().baseUrl; // PocketBase IP

    return BlocBuilder<ProfessionalBloc, ProfessionalState>(
      builder: (context, state) {
        final prof = state.professional;
        final hasGallery = prof != null && prof.gallery != null && prof.gallery!.isNotEmpty;
        final collection = widget.isTrainer ? 'trainers' : 'gyms';

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Avatar Area
                _buildAvatar(prof, baseUrl, collection),
                
                const SizedBox(height: 16),
                Text(prof?.name ?? widget.userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(
                  widget.isTrainer ? 'Professional Trainer' : 'FitMotion Gym Partner',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                
                const SizedBox(height: 24),
                
                // Social Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStat('${prof?.gallery?.length ?? 0}', 'Koleksi'),
                    _buildDivider(),
                    _buildStat('0', 'Rating'),
                  ],
                ),

                const SizedBox(height: 32),

                // Action Buttons
                if (context.read<AuthBloc>().state.user?.id != widget.userId)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(receiverId: widget.userId, receiverName: widget.userName)));
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade200),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Pesan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),

                const SizedBox(height: 40),

                // Description & Info Operasional/Tarif
                if (prof != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tentang Kami', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(prof.description, style: const TextStyle(color: Colors.black54, height: 1.5)),
                        const SizedBox(height: 24),

                        if (!widget.isTrainer) ...[
                          const Text('Jadwal & Jam Operasional', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time_filled, color: Colors.blue, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "${(prof.openDays != null && prof.openDays!.isNotEmpty) ? prof.openDays! : 'Setiap Hari'} \n(${prof.openTime ?? '08:00'} - ${prof.closeTime ?? '22:00'})",
                                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],

                        const Text('Informasi Tarif', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.isTrainer ? 'Tarif Per Sesi' : 'Harga Member (1 Bulan)', style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('Rp ${prof.price}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black87)),
                                  ],
                                ),
                              ),
                              if (!widget.isTrainer && prof.nonMemberPrice != null) ...[
                                Container(width: 1, height: 40, color: Colors.amber.shade200, margin: const EdgeInsets.symmetric(horizontal: 12)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Harga Non-Member (1 Hari)', style: TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('Rp ${prof.nonMemberPrice}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black87)),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],

                // PORTFOLIO GALLERY GRID
                const Text('PORTFOLIO & DOKUMENTASI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.blueGrey)),
                const SizedBox(height: 16),
                
                if (hasGallery)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: prof.gallery!.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, 
                        crossAxisSpacing: 4, 
                        mainAxisSpacing: 4,
                      ),
                      itemBuilder: (context, index) {
                        final fileUrl = "$baseUrl/api/files/$collection/${prof.id}/${prof.gallery![index]}";
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog.fullscreen(
                                backgroundColor: Colors.black.withOpacity(0.95),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Ketuk area manapun di latar belakang untuk menutup
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        color: Colors.transparent,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                    InteractiveViewer(
                                      child: Image.network(
                                        fileUrl,
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                        height: double.infinity,
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
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(image: NetworkImage(fileUrl), fit: BoxFit.cover),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  _buildEmptyGallery(),
                
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(dynamic prof, String baseUrl, String collection) {
    String? imageUrl;
    if (prof != null && prof.avatar != null && prof.avatar!.isNotEmpty) {
      imageUrl = "$baseUrl/api/files/$collection/${prof.id}/${prof.avatar}";
    }

    return Center(
      child: Container(
        width: 100, height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200, width: 3),
          image: imageUrl != null ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null,
        ),
        child: imageUrl == null ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
      ),
    );
  }

  Widget _buildStat(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 20, width: 1, margin: const EdgeInsets.symmetric(horizontal: 24), color: Colors.grey.shade200);
  }

  Widget _buildEmptyGallery() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.photo_library_outlined, size: 48, color: Colors.black12),
          SizedBox(height: 16),
          Text('Belum ada foto galeri portofolio.', style: TextStyle(color: Colors.black26, fontSize: 13)),
        ],
      ),
    );
  }
}
