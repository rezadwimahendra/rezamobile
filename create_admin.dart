import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('http://127.0.0.1:8090/api/collections/users/records');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'name': 'Super Admin',
      'email': 'superadmin@fitmotion.com',
      'password': 'password123',
      'passwordConfirm': 'password123',
      'role': 'admin'
    }),
  );
  
  print('Status code: \${response.statusCode}');
  print('Response body: \${response.body}');
}
