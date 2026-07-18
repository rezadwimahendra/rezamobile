import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/professional_bloc.dart';
import '../bloc/professional_event.dart';
import '../bloc/professional_state.dart';
import '../../data/datasources/payment_remote_data_source.dart';
import 'payment_webview_page.dart';
import 'trainer_dashboard_page.dart';
import 'gym_dashboard_page.dart';

class SubscriptionPage extends StatelessWidget {
  final String roleType;

  const SubscriptionPage({super.key, required this.roleType});

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFFFB800).withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB800).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_rounded, color: Color(0xFFFFB800), size: 40),
              ),
              const SizedBox(height: 32),
              const Text(
                'PAYMENT SUCCESSFUL',
                style: TextStyle(color: Color(0xFFFFB800), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              Text(
                roleType == 'trainer' 
                    ? 'Welcome, Pro Trainer' 
                    : roleType == 'gym' 
                        ? 'Welcome, Partner' 
                        : 'Welcome, Premium User',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthCheckRequested());
                    if (roleType == 'pro') {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } else {
                      final userName = context.read<AuthBloc>().state.user?.name ?? "User";
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => roleType == 'trainer' 
                            ? TrainerDashboardPage(userName: userName)
                            : GymDashboardPage(userName: userName)
                        ),
                        (route) => route.isFirst,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text(roleType == 'pro' ? 'CLOSE' : 'OPEN DASHBOARD', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startPaymentFlow(BuildContext context) async {
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;
    final double amount = (roleType == 'trainer' || roleType == 'gym')
        ? 149000 
        : 29000;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFFFFB800))),
    );

    try {
      final paymentDS = PaymentRemoteDataSourceImpl(); 
      final token = await paymentDS.getSnapToken(
        orderId: "INV-${DateTime.now().millisecondsSinceEpoch}",
        amount: amount,
        customerName: user.name,
        customerEmail: user.email,
      );
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        final paymentResult = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => PaymentWebViewPage(paymentUrl: token)),
        );
        
        bool isSuccess = paymentResult == true;

        if (isSuccess && context.mounted) {
          context.read<ProfessionalBloc>().add(ProfessionalSubscribed(userId: user.id, roleType: roleType));
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTrainer = roleType == 'trainer';
    final isGym = roleType == 'gym';
    final isPro = roleType == 'pro';
    const primaryColor = Color(0xFFFFB800);
    final String priceText = (isTrainer || isGym)
        ? '149.000' 
        : '29.000';
    final String coverImage = isTrainer 
        ? 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=800&auto=format&fit=crop'
        : isGym 
            ? 'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?q=80&w=800&auto=format&fit=crop'
            : 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=800&auto=format&fit=crop';
        
    return BlocListener<ProfessionalBloc, ProfessionalState>(
      listener: (context, state) {
        if (state.status == ProfessionalStatus.success) {
          context.read<AuthBloc>().add(AuthCheckRequested());
          _showSuccessDialog(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.network(
                coverImage, 
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.6),
                colorBlendMode: BlendMode.darken,
              ),
            ),
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8), Colors.black],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Content
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Menyebar rata
                        children: [
                          // Header Row
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Icon(Icons.close, color: Colors.white, size: 28),
                              ),
                            ],
                          ),
                          
                          // Main Info
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: primaryColor),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  isTrainer 
                                      ? 'FITMOTION PRO' 
                                      : isGym 
                                          ? 'BUSINESS PARTNER' 
                                          : 'FITMOTION PREMIUM', 
                                  style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isTrainer 
                                    ? 'Tingkatkan Layanan\nKarir Anda Sekarang.' 
                                    : isGym 
                                        ? 'Digitalisasi Bisnis\nFitness Anda.'
                                        : 'Buka Analisis Nutrisi\n& Tren Kemajuan Anda.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                              ),
                            ],
                          ),

                          // Price Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Rp', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 4),
                                    Text(priceText, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
                                    Text(isPro ? ' /bln' : ' (Sekali Bayar)', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isPro 
                                      ? 'Paket aktif selama 30 hari sejak sukses pembayaran'
                                      : 'Kemitraan aktif selamanya (Permanen)',
                                  style: const TextStyle(color: Color(0xFFFFB800), fontSize: 10, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                const Divider(color: Colors.white10),
                                const SizedBox(height: 16),
                                if (isPro) ...[
                                  _buildTick('Grafik Tren Berat Badan Lengkap'),
                                  _buildTick('Analisis Keseimbangan Makronutrisi'),
                                  _buildTick('Rekomendasi Menu Makanan Harian'),
                                ] else ...[
                                  _buildTick(isTrainer ? 'Akses Dashboard Trainer' : 'Akses Dashboard Bisnis Gym'),
                                  _buildTick(isTrainer ? 'Priority Trainer Search' : 'Priority Gym Search'),
                                  _buildTick(isTrainer ? 'Kelola Klien Tanpa Batas' : 'Kelola Member & Fasilitas'),
                                  _buildTick('Termasuk Fitur Premium (Progres & Nutrisi)'),
                                ]
                              ],
                            ),
                          ),

                          // Bottom Section
                          Column(
                            children: [
                              BlocBuilder<ProfessionalBloc, ProfessionalState>(
                                builder: (context, state) {
                                  final isLoading = state.status == ProfessionalStatus.loading;
                                  return SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : () => _startPaymentFlow(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      child: isLoading 
                                        ? const CircularProgressIndicator(color: Colors.black)
                                        : const Text('AKTIFKAN SEKARANG', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              Text(
                                isPro
                                    ? 'Aman via Midtrans Gateway • Masa Aktif 30 Hari'
                                    : 'Aman via Midtrans Gateway • Akses Permanen / Lifetime',
                                style: const TextStyle(color: Colors.white24, fontSize: 9),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTick(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check, color: Color(0xFFFFB800), size: 16),
          const SizedBox(width: 8),
          Flexible(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
