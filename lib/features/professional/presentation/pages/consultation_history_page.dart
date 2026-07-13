import 'package:flutter/material.dart';
import '../../../chat/data/datasources/chat_remote_data_source.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../../injection.dart';
import 'package:pocketbase/pocketbase.dart';

class ConsultationHistoryPage extends StatefulWidget {
  const ConsultationHistoryPage({super.key});

  @override
  State<ConsultationHistoryPage> createState() => _ConsultationHistoryPageState();
}

class _ConsultationHistoryPageState extends State<ConsultationHistoryPage> {
  List<Map<String, dynamic>> _chatPartners = [];
  bool _isLoadingPartners = true;

  @override
  void initState() {
    super.initState();
    _loadChatPartners();
  }

  Future<void> _loadChatPartners() async {
    try {
      final partners = await sl<ChatRemoteDataSource>().getChatPartners();
      final pb = sl<PocketBase>();
      final List<Map<String, dynamic>> loadedPartners = [];

      for (String partnerId in partners) {
        try {
          final userRecord = await pb.collection('users').getOne(partnerId);
          final String name = userRecord.getStringValue('name');
          final String role = userRecord.getStringValue('role');
          final String avatar = userRecord.getStringValue('avatar');
          final bool isTrainer = userRecord.data['is_trainer'] == true;
          final bool isGym = userRecord.data['is_gym'] == true;

          String subtitle = 'Pengguna';
          if (role == 'admin') {
            subtitle = 'Administrator';
          } else if (isTrainer) {
            subtitle = 'Pelatih Profesional';
          } else if (isGym) {
            subtitle = 'Mitra Gym';
          }

          loadedPartners.add({
            'userId': partnerId,
            'name': name.isNotEmpty ? name : 'Pengguna FitMotion',
            'subtitle': subtitle,
            'avatar': avatar,
            'role': role,
          });
        } catch (e) {
          debugPrint('Error fetching user $partnerId details: $e');
          // Add fallback so the chat history is still interactive
          loadedPartners.add({
            'userId': partnerId,
            'name': 'Pengguna FitMotion',
            'subtitle': 'Hubungan Pesan Aktif',
            'avatar': '',
            'role': 'user',
          });
        }
      }

      if (mounted) {
        setState(() {
          _chatPartners = loadedPartners;
          _isLoadingPartners = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPartners = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFFB800);
    final String baseUrl = sl<PocketBase>().baseUrl;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pesan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoadingPartners
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _chatPartners.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('Belum ada pesan', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _chatPartners.length,
                  itemBuilder: (context, index) {
                    final partner = _chatPartners[index];
                    final String? avatar = partner['avatar'];
                    String? imageUrl;
                    if (avatar != null && avatar.isNotEmpty) {
                      imageUrl = "$baseUrl/api/files/users/${partner['userId']}/$avatar";
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: ListTile(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPage(
                                receiverId: partner['userId'],
                                receiverName: partner['name'],
                              ),
                            ),
                          );
                          _loadChatPartners();
                        },
                        leading: CircleAvatar(
                          backgroundColor: primaryColor.withOpacity(0.1),
                          backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                          child: imageUrl == null
                              ? Text(partner['name'][0].toUpperCase(), style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold))
                              : null,
                        ),
                        title: Text(partner['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(partner['subtitle'], style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      ),
                    );
                  },
                ),
    );
  }
}
