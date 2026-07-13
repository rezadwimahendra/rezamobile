import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../../../injection.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../../data/models/user_model.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current user data
    final user = context.read<AuthBloc>().state.user;
    if (user != null) {
      _nameController.text = user.name;
      _ageController.text = user.age > 0 ? user.age.toString() : '';
      _heightController.text = user.height > 0 ? user.height.toString() : '';
      _weightController.text = user.initialWeight > 0 ? user.initialWeight.toString() : '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      final pb = sl<PocketBase>();
      final userId = pb.authStore.model?.id;
      
      if (userId == null) throw Exception('Sesi tidak ditemukan');

      final String name = _nameController.text.trim();
      final int age = int.parse(_ageController.text);
      final int height = int.parse(_heightController.text);
      final double weight = double.parse(_weightController.text);
      
      // Hitung target kalori otomatis (Rough estimate: weight * 30)
      final int autoGoal = (weight * 30).toInt();

      final updatedRecord = await pb.collection('users').update(userId, body: {
        'name': name,
        'age': age,
        'height': height,
        'initial_weight': weight,
        'goal_calories': autoGoal,
        'emailVisibility': true,
      });

      // Juga simpan berat badan pertama ke koleksi 'weights'
      try {
        await pb.collection('weights').create(body: {
          'user': userId,
          'weights': weight,
          'date': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // Abaikan jika tabel weights belum ada atau error
        debugPrint('Gagal simpan berat pertama: $e');
      }

      // Update auth store dan bloc state
      pb.authStore.save(pb.authStore.token, updatedRecord);
      
      if (mounted) {
        final userModel = UserModel.fromRecord(updatedRecord);
        context.read<AuthBloc>().add(AuthUserChanged(userModel));
        
        // Cek apakah ini edit atau registrasi pertama
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context);
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan profil: $e'), backgroundColor: Colors.red),
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.of(context).canPop() 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          : null,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Informasi Data Diri',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Data ini akan membantu kami menghitung rencana kalori dan nutrisi yang tepat untuk Anda.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 48),
                
                // Input Nama
                _buildInputField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama Anda',
                  icon: Icons.person_outline,
                  isNumber: false,
                ),
                const SizedBox(height: 24),

                // Input Usia
                _buildInputField(
                  controller: _ageController,
                  label: 'Usia Anda',
                  hint: 'Contoh: 25',
                  suffix: 'Tahun',
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 24),
                
                // Input Tinggi
                _buildInputField(
                  controller: _heightController,
                  label: 'Tinggi Badan',
                  hint: 'Contoh: 170',
                  suffix: 'cm',
                  icon: Icons.height,
                ),
                const SizedBox(height: 24),
                
                // Input Berat
                _buildInputField(
                  controller: _weightController,
                  label: 'Berat Badan Saat Ini',
                  hint: 'Contoh: 65.5',
                  suffix: 'kg',
                  icon: Icons.monitor_weight_outlined,
                  isDecimal: true,
                ),
                
                const SizedBox(height: 60),
                
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'Simpan Perubahan', 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? suffix,
    required IconData icon,
    bool isNumber = true,
    bool isDecimal = false,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber 
              ? TextInputType.numberWithOptions(decimal: isDecimal)
              : TextInputType.text,
          validator: (value) => value == null || value.isEmpty ? 'Harap diisi' : null,
          style: const TextStyle(fontWeight: FontWeight.bold),
          cursorColor: primaryColor,
          selectionControls: MaterialTextSelectionControls(),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.normal),
            prefixIcon: Icon(icon, color: Colors.grey, size: 20),
            suffixText: suffix,
            suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}
