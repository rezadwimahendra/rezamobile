import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../../../injection.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class GoalEditPage extends StatefulWidget {
  final int currentGoal;
  const GoalEditPage({super.key, required this.currentGoal});

  @override
  State<GoalEditPage> createState() => _GoalEditPageState();
}

class _GoalEditPageState extends State<GoalEditPage> {
  late TextEditingController _goalController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _goalController = TextEditingController(text: widget.currentGoal.toString());
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _updateGoal() async {
    final goalText = _goalController.text;
    if (goalText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Target kalori tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pb = sl<PocketBase>();
      final userId = pb.authStore.model?.id;

      if (userId == null) throw Exception('User ID tidak ditemukan');

      final updatedRecord = await pb.collection('users').update(userId, body: {
        'goal_calories': int.tryParse(goalText) ?? 0,
      });

      // Update local storage PocketBase
      pb.authStore.save(pb.authStore.token, updatedRecord);

      if (mounted) {
        // Update state global di AuthBloc
        final userModel = UserModel.fromRecord(updatedRecord);
        context.read<AuthBloc>().add(AuthUserChanged(userModel));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sasaran berhasil diperbarui')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui sasaran: $e')),
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
        title: const Text('Atur Sasaran', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Target Kalori Harian',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tentukan berapa kalori yang ingin Anda konsumsi setiap hari untuk mencapai berat badan ideal.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            
            TextField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              cursorColor: primaryColor,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                labelText: 'Kalori (kkal)',
                labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                suffixIcon: Icon(Icons.flash_on, color: primaryColor),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
            
            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('Simpan Sasaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
