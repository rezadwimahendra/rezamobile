import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'register_page.dart';

class RegisterIntroPage extends StatelessWidget {
  const RegisterIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Memanggil warna dominan Kuning sesuai Tema Aplikasi
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Daftar',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.normal, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              
              const Text(
                'Selamat datang! Mari kita\nsesuaikan MyFitnessPal dengan\nsasaranmu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.3,
                  color: Colors.black,
                  letterSpacing: -0.3,
                ),
              ),
              
              const Spacer(flex: 2),
              
              // Tombol Lanjutkan (Kuning)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, 
                  foregroundColor: Colors.black, // Teks warna hitam untuk kontras kuning
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Lanjutkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const Spacer(flex: 3),
              
              // Teks Kebijakan Privasi
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.grey, 
                    fontSize: 13,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Kami akan mengumpulkan informasi pribadi dari dan tentang Anda, kemudian menggunakannya untuk berbagai tujuan, termasuk untuk menyesuaikan pengalaman MyFitnessPal Anda. Baca selengkapnya tentang tujuan, praktik kami, serta pilihan dan hak Anda dalam '),
                    TextSpan(
                      text: 'Kebijakan Privasi',
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold), // Kuning
                      recognizer: TapGestureRecognizer()..onTap = () {},
                    ),
                    const TextSpan(text: ' kami.'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
