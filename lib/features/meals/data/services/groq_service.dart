import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketbase/pocketbase.dart';
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

  void _rotateKey(int keysCount) {
    if (keysCount <= 1) return;
    _currentKeyIndex = (_currentKeyIndex + 1) % keysCount;
    print('DEBUG: Mengganti ke Groq API Key indeks ke-$_currentKeyIndex');
  }

  Future<AIAnalysisResult?> identifyFood(XFile image) async {
    try {
      // 1. Cek Kuota 24 Jam di SharedPreferences (di-scope ke masing-masing user)
      final prefs = sl<SharedPreferences>();
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final dayAgoMs = nowMs - 24 * 60 * 60 * 1000;
      
      final pb = sl<PocketBase>();
      final userId = pb.authStore.model?.id ?? 'anonymous';
      
      // Load keys dari koleksi 'settings' di PocketBase secara dinamis (fallback ke local keys jika gagal/kosong)
      List<String> activeKeys = [...apiKeys];
      try {
        final settingsList = await pb.collection('settings').getFullList();
        if (settingsList.isNotEmpty) {
          final dbKeysString = settingsList.first.getStringValue('groq_keys');
          if (dbKeysString.isNotEmpty) {
            final parsedKeys = dbKeysString
                .split(RegExp(r'[,\n]'))
                .map((key) => key.trim())
                .where((key) => key.isNotEmpty)
                .toList();
            if (parsedKeys.isNotEmpty) {
              activeKeys = parsedKeys;
              print('DEBUG: Menggunakan ${activeKeys.length} API Keys dari database PocketBase settings');
            }
          }
        }
      } catch (e) {
        print('DEBUG: Menggunakan fallback apiKeys lokal karena: $e');
      }

      final dbKey = 'ai_analysis_timestamps_$userId';
      
      final timestampsPool = prefs.getStringList(dbKey) ?? [];
      final recentTimestamps = timestampsPool
          .map((t) => int.tryParse(t) ?? 0)
          .where((t) => t >= dayAgoMs)
          .toList();

      if (recentTimestamps.length >= 2) {
        final oldestTimestamp = recentTimestamps.first;
        final nextAvailableTimeMs = oldestTimestamp + 24 * 60 * 60 * 1000;
        final remainingMs = nextAvailableTimeMs - nowMs;
        
        final hours = remainingMs ~/ (60 * 60 * 1000);
        final minutes = (remainingMs % (60 * 60 * 1000)) ~/ (60 * 1000);
        
        String waitMessage = '';
        if (hours > 0) {
          waitMessage = 'dalam $hours jam $minutes menit';
        } else if (minutes > 0) {
          waitMessage = 'dalam $minutes menit';
        } else {
          waitMessage = 'beberapa detik lagi';
        }
        
        throw 'Batas kuota harian tercapai. Anda hanya bisa menggunakan fitur AI 2 kali dalam 24 jam. Silakan coba lagi $waitMessage!';
      }

      final Uint8List imageBytes = await image.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      int attempts = 0;
      final maxAttempts = activeKeys.isNotEmpty ? activeKeys.length : 1;

      while (attempts < maxAttempts) {
        final currentKeyIdx = _currentKeyIndex % activeKeys.length;
        final activeKey = activeKeys.isNotEmpty ? activeKeys[currentKeyIdx] : '';
        try {
          print('DEBUG: Mengirim foto ke Groq dengan API Key index $currentKeyIdx...');
          
          final response = await http.post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $activeKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': 'qwen/qwen3.6-27b',
              'response_format': {
                'type': 'json_object'
              },
              'reasoning_effort': 'none',
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

              // 2. Berhasil! Simpan timestamp baru
              final List<String> updatedTimestamps = [
                ...recentTimestamps.map((e) => e.toString()),
                nowMs.toString()
              ];
              await prefs.setStringList(dbKey, updatedTimestamps);

              return result;
            }
          }

          final errorBody = response.body;
          print('DEBUG: Groq Error Status ${response.statusCode}: $errorBody');
          
          attempts++;
          if (attempts < maxAttempts) {
            print('DEBUG: Groq Key index $currentKeyIdx gagal. Memutar ke key selanjutnya...');
            _rotateKey(activeKeys.length);
            continue; // Coba lagi dengan key cadangan
          } else {
            throw 'Gagal menghubungi Groq: HTTP ${response.statusCode} - $errorBody';
          }
        } catch (e) {
          print('DEBUG: Exception pada Groq Key index $currentKeyIdx: $e');
          if (e.toString().contains('Batas kuota harian')) {
            rethrow;
          }
          
          attempts++;
          if (attempts < maxAttempts) {
            print('DEBUG: Key index $currentKeyIdx gagal dengan error. Memutar ke key selanjutnya...');
            _rotateKey(activeKeys.length);
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
