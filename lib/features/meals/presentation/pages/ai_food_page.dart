import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../injection.dart';
import '../../data/services/gemini_service.dart';
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
    });

    try {
      final String? foodName = await sl<GeminiService>().identifyFood(_imageXFile!);

      setState(() {
        _isAnalyzing = false;
        if (foodName != null && foodName.isNotEmpty) {
          _detectedFood = foodName;
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
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
          Expanded(
            child: Container(
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
                                    'Gemini sedang menganalisis...',
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
                  const SizedBox(height: 12),
                  if (_detectedFood != "Makanan tidak dikenali")
                    ElevatedButton.icon(
                      onPressed: _navigateToSearch,
                      icon: const Icon(Icons.search, color: Colors.black, size: 18),
                      label: const Text('Cari & Tambah Nutrisi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
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
    );
  }
}
