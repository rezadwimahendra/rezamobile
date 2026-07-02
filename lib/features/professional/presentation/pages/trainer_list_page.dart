import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/professional_bloc.dart';
import '../bloc/professional_event.dart';
import '../bloc/professional_state.dart';
import '../../../chat/presentation/pages/chat_page.dart';

class TrainerListPage extends StatefulWidget {
  const TrainerListPage({super.key});

  @override
  State<TrainerListPage> createState() => _TrainerListPageState();
}

class _TrainerListPageState extends State<TrainerListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfessionalBloc>().add(TrainersListRequested());
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFFB800);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Semua Pelatih', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocBuilder<ProfessionalBloc, ProfessionalState>(
        builder: (context, state) {
          if (state.status == ProfessionalStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          
          if (state.status == ProfessionalStatus.error) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          if (state.trainers.isEmpty) {
            return const Center(child: Text('Belum ada pelatih yang terdaftar.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: state.trainers.length,
            itemBuilder: (context, index) {
              final t = state.trainers[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person, size: 40, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(t.specialty ?? 'General Trainer', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.payments, color: Colors.green, size: 16),
                              const SizedBox(width: 4),
                              Text('Rp ${t.price}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              receiverId: t.userId,
                              receiverName: t.name,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('Hubungi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
