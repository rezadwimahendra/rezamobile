import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../injection.dart';

class GeminiService {
  final List<String> apiKeys;
  int _currentKeyIndex = 0;
  late GenerativeModel _model;

  GeminiService({required this.apiKeys}) {
    _initializeModel();
  }

  void _initializeModel() {
    final activeKey = apiKeys.isNotEmpty ? apiKeys[_currentKeyIndex] : '';
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: activeKey,
      // Menambahkan safety settings agar AI tidak terlalu sensitif memblokir gambar makanan
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      ],
    );
  }

  void _rotateKey() {
    if (apiKeys.length <= 1) return;
    _currentKeyIndex = (_currentKeyIndex + 1) % apiKeys.length;
    print('DEBUG: Mengganti ke API Key indeks ke-$_currentKeyIndex');
    _initializeModel();
  }

  Future<String?> identifyFood(XFile image) async {
    try {
      // 1. Cek Kuota Harian di SharedPreferences
      final prefs = sl<SharedPreferences>();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10); // Format "yyyy-MM-dd"
      
      final lastAnalysisDate = prefs.getString('ai_last_analysis_date') ?? '';
      int count = prefs.getInt('ai_daily_analysis_count') ?? 0;
      
      if (lastAnalysisDate == todayStr) {
        if (count >= 3) {
          throw 'Batas kuota harian tercapai. Anda hanya bisa menggunakan fitur AI 3 kali per hari. Silakan coba lagi besok!';
        }
      }

      final Uint8List imageBytes = await image.readAsBytes();
      
      final content = [
        Content.multi([
          DataPart('image/jpeg', imageBytes),
          TextPart(
            'Identify the food in this image. Answer with only the name of the food in Indonesian. '
            'Example: "Nasi Goreng", "Ayam Bakar", "Sate Ayam". '
            'If you see multiple items, pick the most prominent one. No punctuation, just the name.'
          ),
        ])
      ];

      int attempts = 0;
      final maxAttempts = apiKeys.isNotEmpty ? apiKeys.length : 1;

      while (attempts < maxAttempts) {
        try {
          print('DEBUG: Mengirim foto ke Gemini dengan API Key index $_currentKeyIndex...');
          final response = await _model.generateContent(content);
          
          if (response.text != null && response.text!.isNotEmpty) {
            final result = response.text!.trim().replaceAll(RegExp(r'[^\w\s]'), '');
            print('DEBUG: Gemini mendeteksi: $result');

            // 2. Berhasil! Simpan hitungan baru
            if (lastAnalysisDate != todayStr) {
              await prefs.setString('ai_last_analysis_date', todayStr);
              await prefs.setInt('ai_daily_analysis_count', 1);
            } else {
              await prefs.setInt('ai_daily_analysis_count', count + 1);
            }

            return result;
          }
          
          print('DEBUG: Gemini memberikan respon kosong.');
          return null;
        } catch (e) {
          final errorStr = e.toString();
          print('DEBUG: Gemini Error pada index $_currentKeyIndex: $errorStr');
          
          if (errorStr.contains('Batas kuota harian')) {
            rethrow;
          }

          // Putar API Key untuk kesalahan koneksi/API apa pun (seperti 404, 403, 429, dll.)
          // agar jika ada salah satu key belum aktif atau limit, aplikasi tetap mencoba key berikutnya.
          attempts++;
          if (attempts < maxAttempts) {
            print('DEBUG: Key index $_currentKeyIndex gagal dengan error. Memutar ke key selanjutnya...');
            _rotateKey();
            continue; // Coba lagi dengan key berikutnya
          }
          
          // Jika semua key sudah dicoba dan tetap gagal, lempar error ke UI
          if (errorStr.contains('403')) {
            throw 'API Key belum diaktifkan atau tidak memiliki izin (Error 403). Pastikan Generative Language API sudah ENABLE di Google Cloud.';
          } else if (errorStr.contains('429') || errorStr.contains('ResourceExhausted')) {
            throw 'Terlalu banyak permintaan (Semua kuota API Key habis). Coba lagi nanti.';
          } else if (errorStr.contains('not found') || errorStr.contains('not supported')) {
            throw 'Model tidak ditemukan/tidak didukung untuk API Key Anda (Error 404). Pastikan Generative Language API sudah ENABLE di Google Cloud Console untuk semua key.';
          }
          throw 'Gagal menghubungi AI setelah $attempts percobaan: $e';
        }
      }
      
      throw 'Terlalu banyak permintaan (Semua kuota API Key habis). Coba lagi nanti.';
    } catch (e) {
      rethrow;
    }
  }
}
