import 'package:pocketbase/pocketbase.dart';

void main() async {
  final pb = PocketBase('http://127.0.0.1:8090');
  try {
    final result = await pb.collection("users").authWithPassword("admin@fitmotion.com", "password123");
    print("Login successful! Role: " + result.record!.data["role"].toString());
  } catch (e) {
    print("Login failed: " + e.toString());
  }
}
