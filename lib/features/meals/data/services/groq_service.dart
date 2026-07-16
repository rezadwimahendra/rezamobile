import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../injection.dart';

class AIAnalysisResult {
  final String foodName;
  final int calories;
  final int carbs;
  final int protein;
  final int fat;

  AIAnalysisResult({
    required this.foodName,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  factory AIAnalysisResult.fromJson(Map<String, dynamic> json) {
    return AIAnalysisResult(
      foodName: json['foodName'] ?? json['nama'] ?? 'Makanan tidak dikenal',
      calories: json['calories'] ?? json['kalori'] ?? 0,
      carbs: json['carbs'] ?? json['karbohidrat'] ?? 0,
      protein: json['protein'] ?? json['protein'] ?? 0,
      fat: json['fat'] ?? json['lemak'] ?? 0,
    );
  }
}

class GroqService {
  final List<String> apiKeys;
  int _currentKeyIndex = 0;

  GroqService({required this.apiKeys});

  void _rotateKey() {
    if (apiKeys.length <= 1) return;
    _currentKeyIndex = (_currentKeyIndex + 1) % apiKeys.length;
    print('DEBUG: Mengganti ke Groq API Key indeks ke-$_currentKeyIndex');
  }

  Future<AIAnalysisResult?> identifyFood(XFile image) async {
    try {
      // 1. Cek Kuota Harian di SharedPreferences
      final prefs = sl<SharedPreferences>();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10); // Format "yyyy-MM-dd"
      
      final lastAnalysisDate = prefs.getString('ai_last_analysis_date') ?? '';
      int count = prefs.getInt('ai_daily_analysis_count') ?? 0;
      
      if (lastAnalysisDate == todayStr) {
        if (count >= 2) {
          throw 'Batas kuota harian tercapai. Anda hanya bisa menggunakan fitur AI 2 kali per hari. Silakan coba lagi besok!';
        }
      }

      final Uint8List imageBytes = await image.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      int attempts = 0;
      final maxAttempts = apiKeys.isNotEmpty ? apiKeys.length : 1;

      while (attempts < maxAttempts) {
        final activeKey = apiKeys.isNotEmpty ? apiKeys[_currentKeyIndex] : '';
        try {
          print('DEBUG: Mengirim foto ke Groq dengan API Key index $_currentKeyIndex...');
          
          final response = await http.post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $activeKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
              'response_format': {
                'type': 'json_object'
              },
              'messages': [
                {
                  'role': 'user',
                  'content': [
                    {
                      'type': 'text',
                      'text': 'Analyze this food/meal image. Estimate its nutritional value for a single serving size. '
                              'Return ONLY a JSON object containing the properties: foodName, calories, carbs, protein, and fat. '
                              'The foodName MUST be in Indonesian. The other nutritional properties MUST be integer values. '
                              'Example: {"foodName": "Tempe Goreng", "calories": 200, "carbs": 12, "protein": 10, "fat": 13}'
                    },
                    {
                      'type': 'image_url',
                      'image_url': {
                        'url': 'data:image/jpeg;base64,$base64Image',
                      }
                    }
                  ]
                }
              ],
              'temperature': 0.2,
              'max_tokens': 150,
            }),
          );

          if (response.statusCode == 200) {
            final Map<String, dynamic> data = jsonDecode(response.body);
            final String? text = data['choices']?[0]?['message']?['content'];

            if (text != null && text.isNotEmpty) {
              String cleanJson = text;
              if (cleanJson.contains('```json')) {
                cleanJson = cleanJson.split('```json').last;
              }
              if (cleanJson.contains('```')) {
                cleanJson = cleanJson.split('```').first;
              }
              cleanJson = cleanJson.trim();

              final parsedJson = jsonDecode(cleanJson) as Map<String, dynamic>;
              final result = AIAnalysisResult.fromJson(parsedJson);
              print('DEBUG: Groq mendeteksi: ${result.foodName} (${result.calories} kalori)');

              // 2. Berhasil! Simpan hitungan baru
              if (lastAnalysisDate != todayStr) {
                await prefs.setString('ai_last_analysis_date', todayStr);
                await prefs.setInt('ai_daily_analysis_count', 1);
              } else {
                await prefs.setInt('ai_daily_analysis_count', count + 1);
              }

              return result;
            }
          }

          final errorBody = response.body;
          print('DEBUG: Groq Error Status ${response.statusCode}: $errorBody');
          
          attempts++;
          if (attempts < maxAttempts) {
            print('DEBUG: Groq Key index $_currentKeyIndex gagal. Memutar ke key selanjutnya...');
            _rotateKey();
            continue; // Coba lagi dengan key cadangan
          } else {
            throw 'Gagal menghubungi Groq: HTTP ${response.statusCode} - $errorBody';
          }
        } catch (e) {
          print('DEBUG: Exception pada Groq Key index $_currentKeyIndex: $e');
          if (e.toString().contains('Batas kuota harian')) {
            rethrow;
          }
          
          attempts++;
          if (attempts < maxAttempts) {
            print('DEBUG: Key index $_currentKeyIndex gagal dengan error. Memutar ke key selanjutnya...');
            _rotateKey();
            continue;
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
