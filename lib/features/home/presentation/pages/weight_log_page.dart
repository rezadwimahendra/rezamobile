import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../../injection.dart';

class WeightLogPage extends StatefulWidget {
  final double? currentWeight;
  const WeightLogPage({super.key, this.currentWeight});

  @override
  State<WeightLogPage> createState() => _WeightLogPageState();
}

class _WeightLogPageState extends State<WeightLogPage> {
  late TextEditingController _weightController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.currentWeight?.toString() ?? ''
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveWeight() async {
    final weightText = _weightController.text;
    if (weightText.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final pb = sl<PocketBase>();
      final userId = pb.authStore.model?.id;

      if (userId == null) return;

      await pb.collection('weights').create(body: {
        'user': userId,
        'weights': double.tryParse(weightText) ?? 0,
        'date': DateTime.now().toIso8601String(),
      });

      // --- OTOMATIS HITUNG ULANG KALORI ---
      final user = context.read<AuthBloc>().state.user;
      if (user != null) {
        final double newWeight = double.tryParse(weightText) ?? user.initialWeight;
        final int height = user.height;
        final int age = user.age;
        
        // Rumus Mifflin-St Jeor (Sedentary factor 1.2)
        // BMR = (10 * weight) + (6.25 * height) - (5 * age) + 5 (Pria) atau -161 (Wanita)
        // Kita pakai rata-rata -80 untuk gender netral
        final int newGoal = (((10 * newWeight) + (6.25 * height) - (5 * age) - 80) * 1.2).toInt();

        if (newGoal > 500) { // Safety check
          await pb.collection('users').update(userId, body: {
            'goal_calories': newGoal,
          });
          
          if (mounted) {
            context.read<AuthBloc>().add(AuthCheckRequested());
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berat badan berhasil dicatat')),
        );
        Navigator.pop(context, true); // Return true to indicate update
      }
    } catch (e) {
      debugPrint('Error saving weight: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mencatat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Catat Berat Badan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Berapa berat badan Anda hari ini?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Menimbang berat badan secara rutin membantu Anda melacak kemajuan transformasi tubuh.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 40),
            
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText: '00.0',
                suffixText: 'kg',
                suffixStyle: const TextStyle(fontSize: 20, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            
            const SizedBox(height: 60),
            
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveWeight,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('Simpan Berat Badan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
