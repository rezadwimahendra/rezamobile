import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_model.dart';

class NutritionExternalDataSource {
  final http.Client client;

  NutritionExternalDataSource({required this.client});

  // DAFTAR MAKANAN DASAR INDONESIA (Valid & Cepat)
  final List<FoodModel> _localCommonFoods = [
    FoodModel(id: 'local_1', name: 'Nasi Putih (1 Piring)', calories: 204, carbs: 44, protein: 4, fat: 0),
    FoodModel(id: 'local_2', name: 'Nasi Goreng', calories: 333, carbs: 40, protein: 12, fat: 13),
    FoodModel(id: 'local_3', name: 'Telur Dadar', calories: 153, carbs: 1, protein: 10, fat: 12),
    FoodModel(id: 'local_4', name: 'Telur Ceplok', calories: 92, carbs: 0, protein: 6, fat: 7),
    FoodModel(id: 'local_5', name: 'Ayam Goreng', calories: 260, carbs: 0, protein: 25, fat: 17),
    FoodModel(id: 'local_6', name: 'Ayam Bakar', calories: 167, carbs: 0, protein: 25, fat: 6),
    FoodModel(id: 'local_7', name: 'Mie Instan (Goreng)', calories: 380, carbs: 54, protein: 8, fat: 14),
    FoodModel(id: 'local_8', name: 'Mie Instan (Rebus)', calories: 310, carbs: 45, protein: 7, fat: 11),
    FoodModel(id: 'local_9', name: 'Bakso Sapi (1 Porsi)', calories: 300, carbs: 20, protein: 15, fat: 18),
    FoodModel(id: 'local_10', name: 'Roti Tawar (1 Lembar)', calories: 70, carbs: 13, protein: 2, fat: 1),
    FoodModel(id: 'local_11', name: 'Tempe Goreng', calories: 120, carbs: 8, protein: 9, fat: 7),
    FoodModel(id: 'local_12', name: 'Tahu Goreng', calories: 80, carbs: 2, protein: 5, fat: 6),
    FoodModel(id: 'local_13', name: 'Sate Ayam (10 Tusuk)', calories: 450, carbs: 5, protein: 40, fat: 30),
  ];

  Map<String, String> get _headers => {
    'User-Agent': 'FitMotionApp - Android - Version 1.4 - contact@fitmotion.com',
    'Accept': 'application/json',
  };

  Future<List<FoodModel>> searchFoods(String query) async {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();

    // 1. Ambil dari database lokal (Gampang & Valid)
    final localResults = _localCommonFoods.where((f) => f.name.toLowerCase().contains(q)).toList();

    // 2. Ambil dari API Global (Untuk Produk Kemasan/Snack)
    final url = Uri.https('world.openfoodfacts.org', '/cgi/search.pl', {
      'search_terms': query,
      'search_simple': '1',
      'action': 'process',
      'json': '1',
      'page_size': '60',
    });

    try {
      print("DEBUG: [NutritionExternalDataSource] Searching global foods: $query");
      final response = await client.get(url, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List products = data['products'] ?? [];
        
        // FILTER SUPER KETAT: Nama Harus Mengandung Query
        final apiResults = products.where((p) {
          final String nameId = (p['product_name_id'] ?? '').toString().toLowerCase();
          final String nameEn = (p['product_name'] ?? '').toString().toLowerCase();
          final String brand = (p['brands'] ?? '').toString().toLowerCase();
          
          // Wajib ada kata kunci di salah satu kolom nama/brand
          return nameId.contains(q) || nameEn.contains(q) || brand.contains(q);
        }).map((p) {
          final nutriments = p['nutriments'] ?? {};
          final String displayName = p['product_name_id'] ?? p['product_name'] ?? p['generic_name'] ?? 'Produk';
          
          return FoodModel(
            id: p['code']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            name: displayName,
            calories: _parseValue(nutriments['energy-kcal_100g']),
            carbs: _parseValue(nutriments['carbohydrates_100g']),
            protein: _parseValue(nutriments['proteins_100g']),
            fat: _parseValue(nutriments['fat_100g']),
          );
        }).where((f) => f.calories > 0).toList();

        // Gabungkan Lokal + API (Lokal di atas)
        return [...localResults, ...apiResults];
      }
      return localResults;
    } catch (e) {
      return localResults;
    }
  }

  Future<FoodModel?> getProductByBarcode(String barcode) async {
    final url = Uri.https('world.openfoodfacts.org', '/api/v0/product/$barcode.json');
    print("DEBUG: [getProductByBarcode] Querying OpenFoodFacts with barcode: $barcode");
    try {
      final response = await client.get(url, headers: _headers);
      print("DEBUG: [getProductByBarcode] Response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'];
        print("DEBUG: [getProductByBarcode] status value: $status");
        if (status == 1 || status == '1') {
          final p = data['product'];
          if (p == null) {
            print("DEBUG: [getProductByBarcode] product block is null");
            return null;
          }
          final nutriments = p['nutriments'] ?? {};
          final String displayName = p['product_name_id'] ?? p['product_name'] ?? p['product_name_en'] ?? p['generic_name'] ?? 'Produk Barcode';
          print("DEBUG: [getProductByBarcode] Found matching product: $displayName");
          return FoodModel(
            id: p['code']?.toString() ?? barcode,
            name: displayName,
            calories: _parseValue(nutriments['energy-kcal_100g']),
            carbs: _parseValue(nutriments['carbohydrates_100g']),
            protein: _parseValue(nutriments['proteins_100g']),
            fat: _parseValue(nutriments['fat_100g']),
          );
        } else {
          print("DEBUG: [getProductByBarcode] Product not found in Open Food Facts (status is not 1)");
        }
      } else {
        print("DEBUG: [getProductByBarcode] HTTP Request failed with status code ${response.statusCode}");
      }
      return null;
    } catch (e, stack) {
      print("DEBUG: [getProductByBarcode] Exception occurred: $e");
      print(stack);
      return null;
    }
  }

  int _parseValue(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    if (val is String) return double.tryParse(val)?.toInt() ?? 0;
    return 0;
  }
}
