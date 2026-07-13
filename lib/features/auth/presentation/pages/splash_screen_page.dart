import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/auth_event.dart';
import 'welcome_page.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Konfigurasi Animasi Premium
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
    
    // Memicu check session auth dari database
    context.read<AuthBloc>().add(AuthCheckRequested());

    // Beri waktu delay 2.5 detik lalu navigasikan ke halaman yang sesuai
    Timer(const Duration(milliseconds: 2500), _navigateNext);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateNext() {
    if (!mounted) return;
    
    final state = context.read<AuthBloc>().state;
    if (state.status == AuthStatus.authenticated) {
      final user = state.user;
      if (user != null && user.role == 'admin') {
        Navigator.of(context).pushReplacementNamed('/admin');
      } else if (user != null && (user.age == 0 || user.height == 0)) {
        Navigator.of(context).pushReplacementNamed('/complete-profile');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      // Jika belum login atau error/unauthenticated, arahkan ke WelcomePage
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const WelcomePageDirect(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF7F9FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Center Logo & Loader
            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Menampilkan Logo Asli FitMotion (Membesar Bersih)
                        Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Image.asset(
                            'assets/splash.png',
                            width: 200, // Diperbesar sedikit agar tetap gagah
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 54),
                        
                        // Loading Spinner Senada
                        const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Minimalist Footer
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'FITMOTION',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4.0,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'V 1.0.0',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Wrapper Page untuk mengarahkan kembali ke WelcomePage
// tanpa looping routing
class WelcomePageDirect extends StatelessWidget {
  const WelcomePageDirect({super.key});

  @override
  Widget build(BuildContext context) {
    // Import WelcomePage secara dinamis untuk menghindari circular dependency
    // di flutter
    return const WelcomePageAlternative();
  }
}

class WelcomePageAlternative extends StatefulWidget {
  const WelcomePageAlternative({super.key});

  @override
  State<WelcomePageAlternative> createState() => _WelcomePageAlternativeState();
}

class _WelcomePageAlternativeState extends State<WelcomePageAlternative> {
  // Import dari welcome_page.dart
  @override
  Widget build(BuildContext context) {
    return const WelcomePage();
  }
}
