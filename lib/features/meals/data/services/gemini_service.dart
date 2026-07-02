import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class GeminiService {
  final String apiKey;
  late final GenerativeModel _model;

  GeminiService({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      // Menambahkan safety settings agar AI tidak terlalu sensitif memblokir gambar makanan
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      ],
    );
  }

  Future<String?> identifyFood(XFile image) async {
    try {
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

      print('DEBUG: Mengirim foto ke Gemini...');
      final response = await _model.generateContent(content);
      
      if (response.text != null && response.text!.isNotEmpty) {
        final result = response.text!.trim().replaceAll(RegExp(r'[^\w\s]'), '');
        print('DEBUG: Gemini mendeteksi: $result');
        return result;
      }
      
      print('DEBUG: Gemini memberikan respon kosong.');
      return null;
    } catch (e) {
      print('DEBUG: Gemini Error Detail: $e');
      // Berikan error yang lebih spesifik ke UI
      if (e.toString().contains('403')) {
        throw 'API Key belum diaktifkan atau tidak memiliki izin (Error 403). Pastikan Generative Language API sudah ENABLE di Google Cloud.';
      } else if (e.toString().contains('429')) {
        throw 'Terlalu banyak permintaan (Kuota habis). Coba lagi nanti.';
      }
      throw 'Gagal menghubungi AI: $e';
    }
  }
}
