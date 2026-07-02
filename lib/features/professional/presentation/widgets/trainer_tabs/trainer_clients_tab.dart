import 'package:flutter/material.dart';

class TrainerClientsTab extends StatelessWidget {
  final Color primaryColor;

  const TrainerClientsTab({super.key, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search Bar Section
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: TextFormField(
            decoration: InputDecoration(
              hintText: 'Cari klien berdasarkan nama...',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
            ),
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Klien Aktif',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('5 Member', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
        ),
        
        // List Klien
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 100), // Padding bawah ekstra
            itemCount: 5,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final clients = ['Budi Santoso', 'Siti Aminah', 'Agus Pratama', 'Rina Wati', 'Andi Wijaya'];
              final goals = ['Muscle Gain', 'Weight Loss', 'Endurance', 'Flexibility', 'Muscle Gain'];
              return _buildClientCard(clients[index], goals[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClientCard(String name, String goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F1F1)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              name[0],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: primaryColor)
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.track_changes, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(goal, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.black54, size: 20),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
