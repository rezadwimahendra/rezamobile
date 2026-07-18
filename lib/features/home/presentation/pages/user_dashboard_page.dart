import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:image_picker/image_picker.dart';
import '../../../meals/data/services/groq_service.dart';
import '../widgets/dashboard_tab.dart';
import '../../../meals/presentation/widgets/diary_tab.dart';
import '../../../meals/presentation/bloc/meals_bloc.dart';
import '../../../meals/presentation/bloc/meals_state.dart';
import '../../../meals/presentation/bloc/meals_event.dart';
import '../../../professional/presentation/widgets/explore_tab.dart'; // Dikembalikan
import '../../../meals/presentation/pages/food_search_page.dart';
import '../../../meals/presentation/pages/ai_food_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import './goal_edit_page.dart';
import '../../../../injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/weight_bloc.dart';
import '../bloc/weight_bloc_state.dart';
import './weight_log_page.dart';
import './height_log_page.dart'; // Baru
import './exercise_log_page.dart';
import '../widgets/progress_tab.dart';
import '../../../professional/presentation/pages/consultation_history_page.dart';
// import '../../../community/presentation/pages/community_page.dart'; // Dihapus karena tidak terpakai

class UserDashboardPage extends StatefulWidget {
  final String userName;
  final String userRole;

  const UserDashboardPage({super.key, required this.userName, required this.userRole});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  int _currentIndex = 0;
  DateTime _selectedDate = DateTime.now(); // Baru

  void _loadData() {
    final userId = sl<PocketBase>().authStore.model?.id;
    if (userId != null) {
      context.read<MealsBloc>().add(UserMealsFetched(userId: userId, date: _selectedDate));
      context.read<MealsBloc>().add(UserExercisesFetched(userId: userId, date: _selectedDate));
      context.read<WeightBloc>().add(LatestWeightFetched(userId));
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFFFB800),
              onPrimary: Colors.black,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadData();
    }
  }

  Future<void> _quickAICameraScan() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Foto Makanan dengan AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Ambil Foto Langsung (Kamera)'),
              onTap: () {
                Navigator.pop(ctx);
                _processAIImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _processAIImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processAIImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);
    if (photo == null) return;

    // Tampilkan Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFFFFB800)),
                SizedBox(height: 16),
                Text(
                  'Mengidentifikasi makanan dengan AI...',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final AIAnalysisResult? result = await sl<GroqService>().identifyFood(photo);
      final String? foodName = result?.foodName;
      
      if (mounted) {
        Navigator.pop(context); // Tutup loading dialog
        
        if (foodName != null && foodName.isNotEmpty) {
          // Buka FoodSearchPage dengan initialQuery
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FoodSearchPage(
                mealName: 'Sarapan',
                initialQuery: foodName,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('AI tidak dapat mengenali makanan tersebut. Silakan masukkan manual.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Tutup loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menganalisis foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFFB800);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final authUser = authState.user;
        final String currentUserName = authUser?.name ?? widget.userName;
        final String initial = currentUserName.isNotEmpty ? currentUserName[0].toUpperCase() : 'U';
        final pb = sl<PocketBase>();
        final avatarUrl = (authUser?.avatar != null && authUser!.avatar!.isNotEmpty)
            ? "${pb.baseUrl}/api/files/users/${authUser.id}/${authUser.avatar}?t=${authUser.updated}"
            : null;

        debugPrint('DEBUG: dashboard avatarUrl = $avatarUrl');

        final List<Widget> pages = [
          // Index 0: Dasbor
          BlocBuilder<MealsBloc, MealsState>(
            builder: (context, mealsState) {
              return BlocBuilder<WeightBloc, WeightState>(
                builder: (context, weightState) {
                  int totalCals = 0;
                  int totalProtein = 0;
                  int totalCarbs = 0;
                  int totalFat = 0;

                  for (var meal in mealsState.userMeals) {
                    totalCals += meal.food.calories * meal.servings;
                    totalProtein += meal.food.protein * meal.servings;
                    totalCarbs += meal.food.carbs * meal.servings;
                    totalFat += meal.food.fat * meal.servings;
                  }
                  final goalCals = authUser?.goalCalories ?? 0;
                  double? currentWeight;
                  if (weightState is WeightLoaded && weightState.latestWeight != null) {
                    currentWeight = weightState.latestWeight?.weight;
                  } else {
                    currentWeight = authUser?.initialWeight;
                  }
                  final now = DateTime.now();
                  final isToday = _selectedDate.day == now.day && _selectedDate.month == now.month && _selectedDate.year == now.year;
                  final dateLabel = isToday ? 'Hari ini' : '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';

                  return DashboardTab(
                    primaryColor: primaryColor,
                    totalCalories: totalCals,
                    goalCalories: goalCals,
                    burnedCalories: mealsState.totalBurnedCalories,
                    totalProtein: totalProtein,
                    totalCarbs: totalCarbs,
                    totalFat: totalFat,
                    totalMinutes: mealsState.totalExerciseMinutes,
                    totalDistance: mealsState.totalExerciseDistance,
                    dateLabel: dateLabel,
                    onDateTap: _pickDate,
                    currentWeight: currentWeight,
                    currentHeight: authUser?.height,
                    onEditRequested: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GoalEditPage(currentGoal: goalCals))),
                    onWeightLogRequested: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => WeightLogPage(currentWeight: currentWeight)));
                      _loadData();
                    },
                    onHeightLogRequested: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => HeightLogPage(currentHeight: authUser?.height)));
                      _loadData();
                    },
                    onExerciseLogRequested: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const ExerciseLogPage()));
                      _loadData();
                    },
                  );
                },
              );
            },
          ),
          // Index 1: Buku Harian
          DiaryTab(primaryColor: primaryColor),
          // Index 2: Foto AI
          AiFoodPage(primaryColor: primaryColor),
          // Index 3: Kemajuan
          ProgressTab(primaryColor: primaryColor),
          // Index 4: Jelajah
          const ExploreTab(),
        ];

        return Scaffold(
          backgroundColor: Colors.white,
          extendBody: false,
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFFBE6),
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfilePage(
                        userName: currentUserName,
                        userRole: widget.userRole,
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFE91E63),
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                      : null,
                ),
              ),
            ),
            centerTitle: true,
            title: const Text('FitMotion', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 24)),
            actions: [
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConsultationHistoryPage())),
              ),
            ],
          ),
          body: pages[_currentIndex],
          bottomNavigationBar: BottomAppBar(
            color: Colors.white,
            elevation: 8,
            padding: EdgeInsets.zero,
            child: SafeArea(
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTabItem(Icons.grid_view_sharp, 'Dasbor', 0),
                    _buildTabItem(Icons.menu_book, 'Harian', 1),
                    _buildTabItem(Icons.auto_awesome, 'Foto AI', 2),
                    _buildTabItem(Icons.bar_chart, 'Progres', 3),
                    _buildTabItem(Icons.explore_outlined, 'Jelajah', 4),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 0) {
          _loadData(); // Pastikan Dasbor selalu ambil data hari ini
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? const Color(0xFFFFB800) : Colors.grey, size: 24),
            Text(label, style: TextStyle(color: isActive ? const Color(0xFFFFB800) : Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
