import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../professional/presentation/pages/subscription_page.dart';

class ProgressTab extends StatelessWidget {
  final Color primaryColor;

  const ProgressTab({super.key, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState.user;
        final hasPremiumStatus = user != null && (user.isTrainer || user.isGym || user.role == 'pro');

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Analisis Kemajuan',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -0.5),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 8),
              Text(
                'Lihat seberapa jauh kamu sudah melangkah.',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 32),

              // SUMMARY CARDS
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Berat Badan',
                      value: '73.5',
                      unit: 'kg',
                      trend: '-1.5kg',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Rata-rata Kalori',
                      value: '1,840',
                      unit: 'kcal',
                      trend: 'Stabil',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),

              // STACK UNTUK PREMIUM OVERLAY
              Stack(
                children: [
                  // KONTEN GRAFIK PREMIUM
                  Column(
                    children: [
                      // CARD 1: NUTRIENT BREAKDOWN
                      _buildCard(
                        title: 'Keseimbangan Nutrisi',
                        subtitle: 'Proporsi asupan harianmu',
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 140,
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 4,
                                    centerSpaceRadius: 30,
                                    sections: [
                                      PieChartSectionData(color: Colors.orange.shade400, value: 40, showTitle: false, radius: 18),
                                      PieChartSectionData(color: primaryColor, value: 30, showTitle: false, radius: 18),
                                      PieChartSectionData(color: Colors.red.shade400, value: 30, showTitle: false, radius: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  _buildNutrientLegend('Karbo', '40%', Colors.orange.shade400),
                                  const SizedBox(height: 10),
                                  _buildNutrientLegend('Protein', '30%', primaryColor),
                                  const SizedBox(height: 10),
                                  _buildNutrientLegend('Lemak', '30%', Colors.red.shade400),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // CARD 2: WEIGHT TREND
                      _buildCard(
                        title: 'Tren Berat Badan',
                        subtitle: 'Progress 30 hari terakhir',
                        child: SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                              ),
                              titlesData: const FlTitlesData(
                                show: true,
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    const FlSpot(0, 75.0),
                                    const FlSpot(1, 74.8),
                                    const FlSpot(2, 74.2),
                                    const FlSpot(3, 74.5),
                                    const FlSpot(4, 73.9),
                                    const FlSpot(5, 73.5),
                                  ],
                                  isCurved: true,
                                  color: primaryColor,
                                  barWidth: 5,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                      radius: 3,
                                      color: Colors.white,
                                      strokeWidth: 2,
                                      strokeColor: primaryColor,
                                    ),
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [primaryColor.withOpacity(0.15), primaryColor.withOpacity(0.0)],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // SINGLE BLUR OVERLAY BANNER
                  if (!hasPremiumStatus)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: Container(
                            color: Colors.white.withOpacity(0.4),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.lock, color: primaryColor, size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        'PREMIUM FEATURE',
                                        style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Buka Analisis Nutrisi Lengkap',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black, letterSpacing: -0.5),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Berlangganan FitMotion Pro untuk melihat analisis nutrisi makro (karbohidrat, protein, lemak) serta grafik tren berat badan lengkap Anda.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const SubscriptionPage(roleType: 'pro')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: primaryColor,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                  ),
                                  child: const Text('Aktifkan Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 120),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard({required String title, required String value, required String unit, required String trend, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, 
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(unit, style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            trend, 
            style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientLegend(String name, String percentage, Color color) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name, 
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          )
        ),
        Text(percentage, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildCard({required String title, required String subtitle, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, 
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            subtitle, 
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
