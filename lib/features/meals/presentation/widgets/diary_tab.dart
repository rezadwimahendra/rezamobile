import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../../../injection.dart';
import '../bloc/meals_bloc.dart';
import '../bloc/meals_event.dart';
import '../bloc/meals_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../pages/food_search_page.dart';

class DiaryTab extends StatefulWidget {
  final Color primaryColor;
  const DiaryTab({super.key, required this.primaryColor});

  @override
  State<DiaryTab> createState() => _DiaryTabState();
}

class _DiaryTabState extends State<DiaryTab> {
  DateTime _selectedDate = DateTime.now();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi scroll controller untuk memposisikan "Hari Ini" di tengah/awal
    _scrollController = ScrollController(initialScrollOffset: 7 * 65.0 - 150.0);
    _fetchDiary();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isSendingReport = false;

  void _fetchDiary() {
    final userId = sl<AuthBloc>().state.user?.id;
    if (userId != null) {
      context.read<MealsBloc>().add(UserMealsFetched(userId: userId, date: _selectedDate));
    }
  }

  Future<void> _sendDailyEmailReport({
    required String email,
    required String userName,
    required int totalCalories,
    required int goalCalories,
    required int remainingCalories,
    required List<dynamic> meals,
  }) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email pengguna tidak ditemukan!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSendingReport = true;
    });

    try {
      final pbUrl = sl<PocketBase>().baseUrl;
      final baseIpUri = Uri.parse(pbUrl);
      final middlewareUrl = 'http://${baseIpUri.host}:3000/send-report';

      final client = sl<http.Client>();
      
      final formattedMeals = meals.map((m) => {
        'name': m.food.name,
        'calories': m.food.calories * m.servings,
        'mealType': m.mealType,
      }).toList();

      final response = await client.post(
        Uri.parse(middlewareUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'userName': userName,
          'date': DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
          'totalCalories': totalCalories,
          'goalCalories': goalCalories,
          'remainingCalories': remainingCalories,
          'meals': formattedMeals,
        }),
      );

      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        String msg = resData['message'] ?? 'Laporan berhasil dikirim ke email!';
        if (resData['previewUrl'] != null) {
          print("DEBUG Ethereal Mail URL: ${resData['previewUrl']}");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(msg),
                if (resData['previewUrl'] != null)
                  Text(
                    'Preview: ${resData['previewUrl']}',
                    style: const TextStyle(fontSize: 11, color: Colors.yellowAccent),
                  ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 8),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim: ${response.body}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghubungi email server ($e)'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isSendingReport = false;
      });
    }
  }

  Widget _buildDateSelector() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 21, // Tampilkan 3 minggu (1 minggu lalu, minggu ini, 1 minggu depan)
        itemBuilder: (context, index) {
          // Index 7 adalah Hari Ini jika kita mulai dari Durations(days: 7)
          final date = DateTime.now().subtract(Duration(days: 7 - index));
          final isSelected = date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;
          
          final dayName = DateFormat('E', 'id_ID').format(date);
          final dayNumber = DateFormat('d').format(date);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
              _fetchDiary();
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: isSelected ? widget.primaryColor : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    dayNumber,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, String mealName, String recommendedCals, List<dynamic> meals) {
    int currentCals = 0;
    for (var m in meals) {
      final calories = m.food.calories as int;
      final servings = m.servings as int;
      currentCals += calories * servings;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(mealName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black)),
                Text('$currentCals', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(recommendedCals, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const Text('kal', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            
            if (meals.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...meals.map((meal) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        meal.food.name,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${meal.food.calories * meal.servings} kal',
                      style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )).toList(),
            ],

            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200, thickness: 1.5),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => FoodSearchPage(
                    mealName: mealName,
                    selectedDate: _selectedDate,
                  )),
                );
                _fetchDiary(); // Refresh after adding
              },
              child: Row(
                children: [
                  Icon(Icons.add_circle, color: widget.primaryColor),
                  const SizedBox(width: 8),
                  Text('TAMBAHKAN MAKANAN', style: TextStyle(color: widget.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return BlocBuilder<MealsBloc, MealsState>(
          builder: (context, mealsState) {
            int totalCals = 0;
            Map<String, List<dynamic>> categoricalMeals = {
              'sarapan': [],
              'makan siang': [],
              'makan malam': [],
              'camilan': [],
            };

            for (var meal in mealsState.userMeals) {
              final type = meal.mealType.toLowerCase();
              final cals = meal.food.calories * meal.servings;
              totalCals += cals;
              if (categoricalMeals.containsKey(type)) {
                categoricalMeals[type]!.add(meal);
              }
            }

            final goalCals = authState.user?.goalCalories ?? 0;
            final remaining = goalCals - totalCals; 
            
            final dateDisplay = DateFormat('MMMM d, y').format(_selectedDate);
            final isToday = DateFormat('yMd').format(_selectedDate) == DateFormat('yMd').format(DateTime.now());

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDateSelector(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isToday ? 'Hari ini' : dateDisplay, 
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black)
                          ),
                          if (isToday) Text(dateDisplay, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('$remaining', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.black)),
                          const Text('Kalori Tersisa', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                        ]
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                    ),
                    color: Colors.grey.shade50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: widget.primaryColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.mark_email_unread_outlined, color: Colors.black87, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kirim Laporan Harian',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                                ),
                                Text(
                                  'Kirim ringkasan makan hari ini ke email Anda.',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          _isSendingReport 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : TextButton(
                                  onPressed: () => _sendDailyEmailReport(
                                    email: authState.user?.email ?? '',
                                    userName: authState.user?.name ?? '',
                                    totalCalories: totalCals,
                                    goalCalories: goalCals,
                                    remainingCalories: remaining,
                                    meals: mealsState.userMeals,
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: widget.primaryColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  child: const Text('Kirim', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMealCard(context, 'Sarapan', 'Rekomendasi ${(goalCals * 0.3).toInt()} kal', categoricalMeals['sarapan'] ?? []),
                  _buildMealCard(context, 'Makan Siang', 'Rekomendasi ${(goalCals * 0.3).toInt()} kal', categoricalMeals['makan siang'] ?? []),
                  _buildMealCard(context, 'Makan Malam', 'Rekomendasi ${(goalCals * 0.3).toInt()} kal', categoricalMeals['makan malam'] ?? []),
                  _buildMealCard(context, 'Camilan', 'Rekomendasi ${(goalCals * 0.1).toInt()} kal', categoricalMeals['camilan'] ?? []),
                  
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
