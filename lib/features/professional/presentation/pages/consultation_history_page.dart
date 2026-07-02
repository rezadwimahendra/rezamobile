import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/professional_bloc.dart';
import '../bloc/professional_state.dart';
import '../bloc/professional_event.dart';
import '../../../chat/data/datasources/chat_remote_data_source.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../../injection.dart';

class ConsultationHistoryPage extends StatefulWidget {
  const ConsultationHistoryPage({super.key});

  @override
  State<ConsultationHistoryPage> createState() => _ConsultationHistoryPageState();
}

class _ConsultationHistoryPageState extends State<ConsultationHistoryPage> {
  List<String> _chatPartnerIds = [];
  bool _isLoadingPartners = true;

  @override
  void initState() {
    super.initState();
    _loadChatPartners();
    context.read<ProfessionalBloc>().add(TrainersListRequested());
  }

  Future<void> _loadChatPartners() async {
    try {
      final partners = await sl<ChatRemoteDataSource>().getChatPartners();
      if (mounted) {
        setState(() {
          _chatPartnerIds = partners;
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
      body: BlocBuilder<ProfessionalBloc, ProfessionalState>(
        builder: (context, state) {
          if (state.status == ProfessionalStatus.loading || _isLoadingPartners) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          // Filter pelatih: hanya tampilkan jika ID-nya ada di daftar partner chat
          final activeTrainers = state.trainers.where((t) => _chatPartnerIds.contains(t.userId)).toList();

          if (activeTrainers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Belum ada pesan', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeTrainers.length,
            itemBuilder: (context, index) {
              final trainer = activeTrainers[index];
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          receiverId: trainer.userId,
                          receiverName: trainer.name,
                        ),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Text(trainer.name[0], style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(trainer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(trainer.specialty ?? 'Pelatih Profesional', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
