import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Baru
import '../bloc/steps_bloc.dart'; // Baru
import '../bloc/steps_event.dart'; // Baru
import '../bloc/steps_state.dart'; // Baru

class DashboardTab extends StatefulWidget {
  final Color primaryColor;
  final int totalCalories;
  final int goalCalories;
  final int burnedCalories;
  final int totalProtein; // Baru
  final int totalCarbs;   // Baru
  final int totalFat;
  final int totalMinutes; // Baru
  final double totalDistance; // Baru
  final double? currentWeight;
  final int? currentHeight;
  final String dateLabel; // Baru: Untuk menampilkan "Hari ini" atau tanggal lain
  final VoidCallback? onDateTap; // Baru: Untuk buka kalender
  final VoidCallback onEditRequested;
  final VoidCallback onWeightLogRequested;
  final VoidCallback onExerciseLogRequested;

  const DashboardTab({
    super.key,
    required this.primaryColor,
    required this.totalCalories,
    required this.goalCalories,
    this.burnedCalories = 0,
    this.totalProtein = 0, // Baru
    this.totalCarbs = 0,   // Baru
    this.totalFat = 0,
    this.totalMinutes = 0, // Baru
    this.totalDistance = 0.0, // Baru
    this.currentWeight,
    this.currentHeight,
    required this.dateLabel, // Baru
    this.onDateTap, // Baru
    required this.onEditRequested,
    required this.onWeightLogRequested,
    required this.onExerciseLogRequested,
  });

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: widget.onDateTap,
                child: Row(
                  children: [
                    Text(
                      widget.dateLabel, 
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.calendar_month, color: widget.primaryColor, size: 24),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: widget.onEditRequested,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFFFF7E6), borderRadius: BorderRadius.circular(20)),
                child: Text('Edit', style: TextStyle(color: widget.primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // SISTEM SLIDE
        SizedBox(
          height: 220, 
          child: PageView(
            controller: _pageController,
            onPageChanged: (int page) => setState(() => _currentPage = page),
            children: [
              _buildCaloriePage(),
              _buildActivityPage(),
              _buildNutritionPage(),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Dot Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index ? widget.primaryColor : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
          )),
        ),
        
        const SizedBox(height: 25),
        
        // Grid Langkah & Latihan
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BlocBuilder<StepsBloc, StepsState>(
                builder: (context, state) {
                  String label = 'Hubungkan...';
                  int steps = 0;
                  if (state is StepsLoaded) {
                    steps = state.steps;
                    label = '$steps Langkah';
                  } else if (state is StepsLoading) {
                    label = 'Menghubungkan...';
                  }

                  return _card(
                    'Langkah',
                    Row(
                      children: [
                        const Icon(Icons.directions_walk, color: Colors.pink, size: 24),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            label, 
                            style: TextStyle(
                              fontSize: state is StepsLoaded ? 14 : 9, 
                              color: state is StepsLoaded ? Colors.black : Colors.grey,
                              fontWeight: state is StepsLoaded ? FontWeight.bold : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (state is! StepsLoaded) Icon(Icons.chevron_right, size: 14, color: Colors.grey.shade400),
                      ],
                    ),
                    onTap: () {
                      if (state is StepsInitial || state is StepsPermissionDenied) {
                        context.read<StepsBloc>().add(StepsStarted());
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _card(
                'Latihan',
                Column(
                  children: [
                    _miniInfo(Icons.local_fire_department, '${widget.burnedCalories} kal', Colors.orange),
                  ],
                ),
                showPlus: true,
                onPlusTap: widget.onExerciseLogRequested,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 15),
        
        // Row Berat Badan & Tinggi Badan
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _card(
                'Berat Badan',
                Text(
                  widget.currentWeight != null ? '${widget.currentWeight} kg' : '--', 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
                subtitle: '90 hari terakhir',
                showPlus: true,
                onPlusTap: widget.onWeightLogRequested,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _card(
                'Tinggi Badan',
                Text(
                  widget.currentHeight != null && widget.currentHeight! > 0 ? '${widget.currentHeight} cm' : '--', 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
                subtitle: 'Terdaftar',
                showPlus: false,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 100),
      ],
    );
  }

  // --- SLIDE 1: KALORI ---
  Widget _buildCaloriePage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kalori', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Sisa = Sasaran - Makan + Latihan', style: TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 15),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCircularIndicator('${widget.goalCalories - widget.totalCalories + widget.burnedCalories}', 'Sisa'),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoItem(Icons.flag, 'Sasaran', '${widget.goalCalories}', Colors.grey),
                      const SizedBox(height: 8),
                      _infoItem(Icons.restaurant, 'Makanan', '${widget.totalCalories}', widget.primaryColor),
                      const SizedBox(height: 8),
                      _infoItem(Icons.local_fire_department, 'Latihan', '${widget.burnedCalories}', Colors.orange),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SLIDE 2: AKTIVITAS ---
  Widget _buildActivityPage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Aktivitas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Statistik pergerakan hari ini', style: TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _activityStat(Icons.directions_run, '${widget.totalMinutes}/30', 'Menit', Colors.green)),
                Expanded(
                  child: BlocBuilder<StepsBloc, StepsState>(
                    builder: (context, state) {
                      int steps = 0;
                      if (state is StepsLoaded) steps = state.steps;
                      return _activityStat(Icons.do_not_step, '$steps/6k', 'Langkah', Colors.blue);
                    },
                  ),
                ),
                Expanded(child: _activityStat(Icons.map, widget.totalDistance.toStringAsFixed(1), 'Jarak', Colors.purple)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SLIDE 3: NUTRISI ---
  Widget _buildNutritionPage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nutrisi (Makro)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Target gizi harian dikonsumsi', style: TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _macroItem('Protein', '${widget.totalProtein}/150g', Colors.redAccent)),
                Expanded(child: _macroItem('Karbo', '${widget.totalCarbs}/200g', Colors.orangeAccent)),
                Expanded(child: _macroItem('Lemak', '${widget.totalFat}/50g', Colors.yellow.shade700)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text('*Data dari makanan yang Anda catat', style: TextStyle(fontSize: 9, color: Colors.grey, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  // WIDGET HELPER
  Widget _buildCircularIndicator(String value, String label) {
    return Container(
      width: 75, height: 75,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade50),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _activityStat(IconData icon, String value, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        FittedBox(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey), overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _macroItem(String label, String value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 30, height: 4, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        Text(value, style: const TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _infoItem(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis)),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _miniInfo(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _card(String title, Widget content, {String? subtitle, bool showPlus = false, VoidCallback? onPlusTap, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                if (showPlus) GestureDetector(onTap: onPlusTap, child: const Icon(Icons.add, size: 16)),
              ],
            ),
            if (subtitle != null) Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.grey), overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }
}
