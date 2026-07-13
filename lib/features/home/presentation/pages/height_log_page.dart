import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../../injection.dart';

class HeightLogPage extends StatefulWidget {
  final int? currentHeight;
  const HeightLogPage({super.key, this.currentHeight});

  @override
  State<HeightLogPage> createState() => _HeightLogPageState();
}

class _HeightLogPageState extends State<HeightLogPage> {
  late TextEditingController _heightController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController(
      text: widget.currentHeight?.toString() ?? ''
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _saveHeight() async {
    final heightText = _heightController.text;
    if (heightText.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final pb = sl<PocketBase>();
      final userId = pb.authStore.model?.id;

      if (userId == null) return;

      int newHeight = int.tryParse(heightText) ?? 0;

      // Update users collection
      await pb.collection('users').update(userId, body: {
        'height': newHeight,
      });

      // Recalculate calories using the new height
      final user = context.read<AuthBloc>().state.user;
      if (user != null) {
        final double currentWeight = user.initialWeight; // Kita bisa ambil dari latestweight juga
        final int age = user.age;
        
        final int newGoal = (((10 * currentWeight) + (6.25 * newHeight) - (5 * age) - 80) * 1.2).toInt();

        if (newGoal > 500) { 
          await pb.collection('users').update(userId, body: {
            'goal_calories': newGoal,
          });
        }
      }

      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckRequested());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tinggi badan berhasil diperbarui')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error saving height: $e');
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
        title: const Text('Catat Tinggi Badan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
              'Berapa tinggi badan Anda saat ini?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tinggi badan diperlukan untuk menghitung kebutuhan kalori dan status kesehatan yang akurat.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 40),
            
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
              cursorColor: primaryColor,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText: '000',
                suffixText: 'cm',
                suffixStyle: const TextStyle(fontSize: 20, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: primaryColor, width: 2),
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
                onPressed: _isLoading ? null : _saveHeight,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('Simpan Tinggi Badan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
