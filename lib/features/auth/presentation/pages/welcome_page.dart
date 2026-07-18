import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_intro_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Data dinamis untuk Carousel/Slider
  final List<Map<String, String>> _pages = [
    {
      'image': 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=1000&auto=format&fit=crop',
      'title': 'Siap untuk menang?\nMulai pelacakan, mudah saja!',
      'cardTitle': 'Protein',
    },
    {
      'image': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1000&auto=format&fit=crop',
      'title': 'Pantau asupan nutrisi\ndan target kalori harian.',
      'cardTitle': 'Kalori',
    },
    {
      'image': 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=1000&auto=format&fit=crop',
      'title': 'Capai bentuk ideal dengan\ndedikasi luar biasa.',
      'cardTitle': 'Workout',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxHeight < 680;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // Header Text (Static)
                      const Text(
                        'Selamat datang di',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'FitMotion',
                        style: TextStyle(
                          color: primaryColor, 
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Slider / Carousel Area (Gambar + Text)
                      SizedBox(
                        height: isSmallScreen ? 340 : 420,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (int page) {
                            setState(() {
                              _currentPage = page;
                            });
                          },
                          itemCount: _pages.length,
                          itemBuilder: (context, index) {
                            final data = _pages[index];
                            return Column(
                              children: [
                                // Gambar Utama (Hero)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Container(
                                        width: double.infinity,
                                        color: Colors.grey.shade200,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(
                                              data['image']!, 
                                              fit: BoxFit.cover,
                                            ),
                                            // Overlay Card seperti digambar
                                            Positioned(
                                              bottom: 24,
                                              left: 20,
                                              child: Container(
                                                padding: const EdgeInsets.all(16),
                                                width: 180,
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2), 
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(data['cardTitle']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                                        const Text('7 Hari', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 12),
                                                    // Simplified Bar Chart
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: List.generate(7, (idx) {
                                                        final heights = [10.0, 24.0, 18.0, 26.0, 20.0, 32.0, 36.0];
                                                        final h2 = [30.0, 10.0, 25.0, 18.0, 28.0, 22.0, 35.0];
                                                        final h3 = [15.0, 30.0, 15.0, 35.0, 10.0, 25.0, 20.0];
                                                        
                                                        double height = heights[idx];
                                                        if (index == 1) height = h2[idx];
                                                        if (index == 2) height = h3[idx];

                                                        return Container(
                                                          width: 14,
                                                          height: height,
                                                          color: primaryColor,
                                                        );
                                                      }),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    const Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text('S', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                                        Text('S', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                                        Text('R', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                                        Text('K', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                                        Text('J', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                                        Text('S', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                                        Text('M', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                // Subtitle yang berubah setiap digeser
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                  child: Text(
                                    data['title']!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 18 : 22,
                                      fontWeight: FontWeight.bold,
                                      height: 1.3,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Carousel Page Indicator (Dots)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index 
                                  ? primaryColor 
                                  : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                      const Spacer(),
                      const SizedBox(height: 24),
                      
                      // Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterIntroPage()),
                            );
                          },
                          child: const Text('Daftar'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          );
                        },
                        child: const Text('Masuk'),
                      ),
                      
                      const SizedBox(height: 16),
                      const Text(
                        'Versi 1.0.0',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
