import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../injection.dart';
import '../../data/services/groq_service.dart';
import '../../data/models/food_model.dart';
import '../bloc/meals_bloc.dart';
import '../bloc/meals_event.dart';
import '../bloc/meals_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'food_search_page.dart';

class AiFoodPage extends StatefulWidget {
  final Color primaryColor;
  const AiFoodPage({super.key, required this.primaryColor});

  @override
  State<AiFoodPage> createState() => _AiFoodPageState();
}

class _AiFoodPageState extends State<AiFoodPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageXFile;
  Uint8List? _imageBytes;
  bool _isAnalyzing = false;
  String? _detectedFood;
  AIAnalysisResult? _analysisResult;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageXFile = pickedFile;
          _imageBytes = bytes;
          _detectedFood = null; // Reset hasil sebelumnya
          _analysisResult = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageXFile == null || _imageBytes == null) return;

    setState(() {
      _isAnalyzing = true;
      _detectedFood = null;
      _analysisResult = null;
    });

    try {
      final AIAnalysisResult? result = await sl<GroqService>().identifyFood(_imageXFile!);

      setState(() {
        _isAnalyzing = false;
        if (result != null) {
          _analysisResult = result;
          _detectedFood = result.foodName;
        } else {
          _detectedFood = "Makanan tidak dikenali";
        }
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error Analisis: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildNutritionInfo(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  void _navigateToSearch() {
    if (_detectedFood == null || _detectedFood == "Makanan tidak dikenali") return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodSearchPage(
          mealName: 'Sarapan',
          initialQuery: _detectedFood,
        ),
      ),
    );
  }

  void _showAddMealDirectlySheet() {
    if (_analysisResult == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih Waktu Makan',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              Text(
                'Tambahkan "${_analysisResult!.foodName}" ke catatan harian Anda.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              
              _buildMealTypeOption(ctx, 'Sarapan', Icons.light_mode_outlined),
              const SizedBox(height: 8),
              _buildMealTypeOption(ctx, 'Makan Siang', Icons.wb_sunny_outlined),
              const SizedBox(height: 8),
              _buildMealTypeOption(ctx, 'Makan Malam', Icons.nightlight_outlined),
              const SizedBox(height: 8),
              _buildMealTypeOption(ctx, 'Cemilan', Icons.cookie_outlined),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMealTypeOption(BuildContext sheetContext, String label, IconData icon) {
    return InkWell(
      onTap: () {
        Navigator.pop(sheetContext);
        _addFoodDirectlyToDiary(label);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, color: widget.primaryColor, size: 20),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 12),
          ],
        ),
      ),
    );
  }

  void _addFoodDirectlyToDiary(String mealType) {
    if (_analysisResult == null) return;
    
    final userId = sl<AuthBloc>().state.user?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi telah berakhir, silakan login kembali'), backgroundColor: Colors.red),
      );
      return;
    }

    final food = FoodModel(
      id: 'ai_temp_${DateTime.now().millisecondsSinceEpoch}',
      name: _analysisResult!.foodName,
      calories: _analysisResult!.calories,
      carbs: _analysisResult!.carbs,
      protein: _analysisResult!.protein,
      fat: _analysisResult!.fat,
    );

    context.read<MealsBloc>().add(MealAdded(
      userId: userId,
      food: food,
      mealType: mealType.toLowerCase(),
      servings: 1,
      date: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MealsBloc, MealsState>(
      listener: (context, state) {
        if (state.status == MealsStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${_analysisResult?.foodName ?? 'Makanan'}" berhasil ditambahkan ke catatan harian!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.status == MealsStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menambahkan makanan: ${state.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Header Tab
            const Column(
              children: [
                Text(
                  'AI Food Describer',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(height: 6),
                Text(
                  'Foto makanan Anda, biar AI yang menebak dan mencatat nutrisinya!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 24),
  
            // Area Gambar / Placeholder
            Container(
              height: 280,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: _imageBytes != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(_imageBytes!, fit: BoxFit.cover),
                        if (_isAnalyzing)
                          Container(
                            color: Colors.black.withOpacity(0.5),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(color: Color(0xFFFFB800)),
                                  SizedBox(height: 20),
                                  Text(
                                    'Sedang menganalisis makanan...',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBE6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.auto_awesome, color: widget.primaryColor, size: 48),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Belum ada foto yang dipilih',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Silakan ambil foto piring makanan Anda atau pilih dari galeri HP.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          const SizedBox(height: 24),

          // Jika ada hasil deteksi AI
          if (_detectedFood != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBE6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text('Hasil Analisis AI:', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    _detectedFood!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: widget.primaryColor),
                  ),
                  if (_analysisResult != null) ...[
                    const SizedBox(height: 14),
                    Divider(height: 1, color: widget.primaryColor.withOpacity(0.2)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNutritionInfo('Kalori', '${_analysisResult!.calories} kal', Colors.orange.shade700),
                        _buildNutritionInfo('Protein', '${_analysisResult!.protein}g', Colors.green.shade700),
                        _buildNutritionInfo('Karbo', '${_analysisResult!.carbs}g', Colors.blue.shade700),
                        _buildNutritionInfo('Lemak', '${_analysisResult!.fat}g', Colors.red.shade700),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (_detectedFood != "Makanan tidak dikenali")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showAddMealDirectlySheet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 0,
                              side: BorderSide(color: widget.primaryColor, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text('Tambah Langsung', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _navigateToSearch,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.primaryColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text('Cari & Bandingkan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Tombol Pilihan Aksi
          if (!_isAnalyzing)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, size: 18, color: Colors.black87),
                    label: const Text('Galeri', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, size: 18, color: Colors.black),
                    label: const Text('Kamera', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          
          if (_imageBytes != null && !_isAnalyzing && _detectedFood == null) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _analyzeImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Mulai Analisis AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ],
      ),
    ),
  );
}
}
