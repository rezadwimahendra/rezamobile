import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:fitness_app/injection.dart';

abstract class PaymentRemoteDataSource {
  /// Mengambil Snap Token dari Backend/Middleware
  Future<String> getSnapToken({
    required String orderId,
    required double amount,
    required String customerName,
    required String customerEmail,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  @override
  Future<String> getSnapToken({
    required String orderId,
    required double amount,
    required String customerName,
    required String customerEmail,
  }) async {
    try {
      final pbUrl = sl<PocketBase>().baseUrl;
      final baseIpUri = Uri.parse(pbUrl);
      final middlewareUrl = 'http://${baseIpUri.host}:3000/snap-token';

      print('DEBUG: Mencoba menghubungi middleware di $middlewareUrl...');
      final response = await http.post(
        Uri.parse(middlewareUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'order_id': orderId,
          'gross_amount': amount,
          'first_name': customerName,
          'email': customerEmail,
        }),
      ).timeout(const Duration(seconds: 5)); // Batas tunggu 5 detik

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['redirect_url'] ?? "https://app.midtrans.com/snap/v2/vtweb/${data['token']}"; 
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Midtrans Error: ${errorData['message'] ?? response.body}');
      }
    } catch (e) {
      print('DEBUG: Payment Error: $e');
      rethrow; // Biarkan UI menangkap error aslinya
    }
  }
}
