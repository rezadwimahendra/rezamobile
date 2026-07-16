import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
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
    
    // Hilangkan native splash screen begitu custom splash terpasang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });

    // Konfigurasi Animasi Premium
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
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
      backgroundColor: const Color(0xFFFFB800),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD54F), Color(0xFFFFB800)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Loading Spinner Gelap Kontras
                      const SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F172A)),
                        ),
                      ),
                    const SizedBox(height: 36),
                    
                    // Brand Name
                    const Text(
                      'FITMOTION',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'TRACK • TRAIN • TRANSFORM',
                      style: TextStyle(
                        fontSize: 10,
                        color: const Color(0xFF0F172A).withOpacity(0.7),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
               ),
              );
            },
          ),
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
