import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../meals/presentation/bloc/meals_bloc.dart';
import '../../../meals/presentation/bloc/meals_event.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ExerciseLogPage extends StatefulWidget {
  const ExerciseLogPage({super.key});

  @override
  State<ExerciseLogPage> createState() => _ExerciseLogPageState();
}

class _ExerciseLogPageState extends State<ExerciseLogPage> {
  final List<Map<String, dynamic>> _exercises = [
    {'name': 'Lari (Pace Sedang)', 'calsPerUnit': 10.0, 'icon': Icons.directions_run, 'type': 'cardio', 'unit': 'Menit'},
    {'name': 'Jalan Santai', 'calsPerUnit': 4.0, 'icon': Icons.directions_walk, 'type': 'cardio', 'unit': 'Menit'},
    {'name': 'Bersepeda', 'calsPerUnit': 8.0, 'icon': Icons.directions_bike, 'type': 'cardio', 'unit': 'Menit'},
    {'name': 'Angkat Beban', 'calsPerUnit': 0.5, 'icon': Icons.fitness_center, 'type': 'strength', 'unit': 'Repetisi'},
    {'name': 'Renang', 'calsPerUnit': 12.0, 'icon': Icons.pool, 'type': 'cardio', 'unit': 'Menit'},
    {'name': 'Yoga', 'calsPerUnit': 3.0, 'icon': Icons.self_improvement, 'type': 'cardio', 'unit': 'Menit'},
  ];

  Map<String, dynamic>? _selectedExercise;
  final _mainInputController = TextEditingController(); // Durasi atau Repetisi
  final _distanceController = TextEditingController();  // Jarak (km)
  final _weightController = TextEditingController();    // Beban (kg)
  final _setsController = TextEditingController(text: '3'); // Khusus Strength
  bool _isLoading = false;

  @override
  void dispose() {
    _mainInputController.dispose();
    _distanceController.dispose();
    _weightController.dispose();
    _setsController.dispose();
    super.dispose();
  }
  Future<void> _saveExercise() async {
    if (_selectedExercise == null || _mainInputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi data latihan dulu ya!')),
      );
      return;
    }

    final int inputValue = int.tryParse(_mainInputController.text) ?? 0;
    final double distanceValue = double.tryParse(_distanceController.text) ?? 0.0;
    final double weightValue = double.tryParse(_weightController.text) ?? 0.0;
    
    int calsBurned = 0;
    final name = _selectedExercise!['name'].toString();
    if (_selectedExercise!['type'] == 'strength') {
      final int sets = int.tryParse(_setsController.text) ?? 0;
      final double perUnit = _selectedExercise!['calsPerUnit'] as double;
      calsBurned = (perUnit * inputValue * sets + (weightValue * 0.05)).toInt();
    } else {
      final double perUnit = _selectedExercise!['calsPerUnit'] as double;
      if (name.contains('Lari') || name.contains('Jalan') || name.contains('Bersepeda')) {
        double factorMin = 5.0; double factorKm = 60.0;
        if (name.contains('Jalan')) { factorMin = 3.0; factorKm = 30.0; }
        else if (name.contains('Bersepeda')) { factorMin = 4.0; factorKm = 40.0; }
        calsBurned = (inputValue * factorMin + distanceValue * factorKm).toInt();
      } else {
        calsBurned = (perUnit * inputValue).toInt();
      }
    }

    final userId = context.read<AuthBloc>().state.user?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);
    
    // Dispatch event ke Bloc
    context.read<MealsBloc>().add(ExerciseAdded(
      userId: userId,
      name: name,
      calories: calsBurned,
      date: DateTime.now(),
      duration: _selectedExercise!['type'] == 'cardio' ? int.tryParse(_mainInputController.text) : null,
      distance: _selectedExercise!['type'] == 'cardio' ? double.tryParse(_distanceController.text) : null,
    ));

    // Tunggu sedikit agar BLoC memproses
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Latihan berhasil dicatat!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final int inputValue = int.tryParse(_mainInputController.text) ?? 0;
    final double distanceValue = double.tryParse(_distanceController.text) ?? 0.0;
    final double weightValue = double.tryParse(_weightController.text) ?? 0.0;
    
    int calsBurned = 0;
    if (_selectedExercise != null) {
      final name = _selectedExercise!['name'].toString();
      if (_selectedExercise!['type'] == 'strength') {
        final int sets = int.tryParse(_setsController.text) ?? 0;
        final double perUnit = _selectedExercise!['calsPerUnit'] as double;
        // Penyesuaian kalori angkat beban: (rep * set * cals) + bonus dari beban
        calsBurned = (perUnit * inputValue * sets + (weightValue * 0.05)).toInt();
      } else {
        final double perUnit = _selectedExercise!['calsPerUnit'] as double;
        // Jika Lari/Jalan/Sepeda, gunakan kombinasi durasi dan jarak
        if (name.contains('Lari') || name.contains('Jalan') || name.contains('Bersepeda')) {
          // Lari: 5 cal/min + 60 cal/km
          // Bersepeda: 4 cal/min + 40 cal/km
          // Jalan: 3 cal/min + 30 cal/km
          double factorMin = 5.0;
          double factorKm = 60.0;
          
          if (name.contains('Jalan')) {
            factorMin = 3.0; factorKm = 30.0;
          } else if (name.contains('Bersepeda')) {
            factorMin = 4.0; factorKm = 40.0;
          }

          calsBurned = (inputValue * factorMin + distanceValue * factorKm).toInt();
        } else {
          calsBurned = (perUnit * inputValue).toInt();
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Catat Latihan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Apa yang kamu lakukan hari ini?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 24),
            
            // Grid Pilihan Latihan
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                final ex = _exercises[index];
                final isSelected = _selectedExercise == ex;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedExercise = ex;
                    _mainInputController.clear();
                    _distanceController.clear();
                  }),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor.withOpacity(0.1) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey.shade200,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(ex['icon'] as IconData, color: isSelected ? primaryColor : Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          ex['name'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Input Dinamis
            if (_selectedExercise != null) ...[
              if (_selectedExercise!['type'] == 'strength') ...[
                _buildInputColumn(
                  label: 'Beban Latihan',
                  controller: _weightController,
                  hint: '',
                  unit: 'Kg',
                  isDecimal: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputColumn(
                        label: 'Set',
                        controller: _setsController,
                        hint: '',
                        unit: 'Set',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputColumn(
                        label: 'Repetisi',
                        controller: _mainInputController,
                        hint: '',
                        unit: 'Reps',
                      ),
                    ),
                  ],
                ),
              ] else if (_selectedExercise!['name'].toString().contains('Lari') || 
                         _selectedExercise!['name'].toString().contains('Jalan') || 
                         _selectedExercise!['name'].toString().contains('Bersepeda')) ...[
                // Cardio dengan Jarak: Durasi + Jarak
                _buildInputColumn(
                  label: 'Durasi Latihan',
                  controller: _mainInputController,
                  hint: '',
                  unit: 'Menit',
                ),
                const SizedBox(height: 16),
                _buildInputColumn(
                  label: 'Jarak Tempuh',
                  controller: _distanceController,
                  hint: '',
                  unit: 'Km',
                  isDecimal: true,
                ),
              ] else ...[
                _buildInputColumn(
                  label: 'Durasi Latihan',
                  controller: _mainInputController,
                  hint: '',
                  unit: 'Menit',
                ),
              ],
            ],
            
            const SizedBox(height: 40),
            
            // Hasil Estimasi
            if (_selectedExercise != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Estimasi Kalori Terbakar', style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
                        Text(
                          '$calsBurned Kalori',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.orange),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            
            const SizedBox(height: 48),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _saveExercise,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                : const Text('Simpan Latihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputColumn({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String unit,
    bool isDecimal = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: unit,
            suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }
}
