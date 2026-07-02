import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/injection.dart' as di;

void main() {
  testWidgets('FitMotion App Smoke Test', (WidgetTester tester) async {
    // Inisialisasi Service Locator sebelum testing dijalankan
    await di.init();

    // Jalankan aplikasi FitMotion
    await tester.pumpWidget(const FitMotionApp());

    // Cek apakah aplikasi berhasil terbuka (misal: mencari teks Welcome atau FitMotion)
    expect(find.text('FitMotion'), findsAtLeast(1));
  });
}
