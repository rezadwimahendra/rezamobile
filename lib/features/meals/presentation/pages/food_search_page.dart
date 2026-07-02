import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../injection.dart';
import '../bloc/meals_bloc.dart';
import '../bloc/meals_event.dart';
import '../bloc/meals_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/services/gemini_service.dart';

class FoodSearchPage extends StatefulWidget {
  final String mealName;
  final DateTime? selectedDate;
  final String? initialQuery; // Baru

  const FoodSearchPage({super.key, required this.mealName, this.selectedDate, this.initialQuery});

  @override
  State<FoodSearchPage> createState() => _FoodSearchPageState();
}

class _FoodSearchPageState extends State<FoodSearchPage> {
  final _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isAIAnalyzing = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      context.read<MealsBloc>().add(FoodsFetched(query: widget.initialQuery));
    } else {
      context.read<MealsBloc>().add(const FoodsFetched());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Method untuk memilih sumber gambar (Kamera atau Galeri)
  Future<void> _pickImageAndAnalyze() async {
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
            const Text('Pilih Foto Makanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Ambil Foto Langsung'),
              onTap: () {
                Navigator.pop(ctx);
                _processImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _processImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);
    
    if (photo != null) {
      setState(() => _isAIAnalyzing = true);
      
      try {
        // Panggil servis Gemini untuk identifikasi makanan
        final String? foodName = await sl<GeminiService>().identifyFood(photo);
        
        if (mounted) {
          setState(() => _isAIAnalyzing = false);
          
          if (foodName != null && foodName.isNotEmpty) {
            // Tampilkan hasil tebakan di kolom pencarian
            _searchController.text = foodName;
            // Jalankan pencarian nutrisi secara otomatis
            context.read<MealsBloc>().add(FoodsFetched(query: foodName));
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('AI mendeteksi: $foodName'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('AI tidak dapat mengenali makanan tersebut. Coba foto lebih jelas.')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isAIAnalyzing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error AI: Pastikan API Key valid & koneksi stabil ($e)'), 
              backgroundColor: Colors.red
            ),
          );
        }
      }
    }
  }

  Future<void> _showAddFoodDialog() async {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final carbCtrl = TextEditingController();
    final proteinCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final isFormValid = nameCtrl.text.isNotEmpty && calCtrl.text.isNotEmpty;
            
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Buat Makanan Baru', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl, 
                      decoration: const InputDecoration(labelText: 'Nama Makanan'),
                      onChanged: (_) => setStateDialog(() {}),
                    ),
                    TextField(
                      controller: calCtrl, 
                      decoration: const InputDecoration(labelText: 'Kalori (kal)'), 
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setStateDialog(() {}),
                    ),
                    TextField(controller: carbCtrl, decoration: const InputDecoration(labelText: 'Karbohidrat (g)'), keyboardType: TextInputType.number),
                    TextField(controller: proteinCtrl, decoration: const InputDecoration(labelText: 'Protein (g)'), keyboardType: TextInputType.number),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isFormValid ? () {
                      context.read<MealsBloc>().add(FoodCreated(
                        name: nameCtrl.text,
                        calories: int.tryParse(calCtrl.text) ?? 0,
                        carbs: int.tryParse(carbCtrl.text) ?? 0,
                        protein: int.tryParse(proteinCtrl.text) ?? 0,
                        fat: 0,
                      ));
                      Navigator.pop(ctx);
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      disabledBackgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            );
          },
        );
      }
    );
  }

  Widget _buildFoodItem(dynamic food) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          title: Text(food.name.isNotEmpty ? food.name : 'Makanan Tanpa Nama', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Text('Protein: ${food.protein} g | Karbo: ${food.carbs} g', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${food.calories} kal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.add_circle, color: primaryColor, size: 28),
                onPressed: () {
                  final userId = sl<AuthBloc>().state.user?.id;
                  if (userId != null) {
                    context.read<MealsBloc>().add(MealAdded(
                      userId: userId,
                      food: food,
                      mealType: widget.mealName.toLowerCase(),
                      servings: 1,
                      date: widget.selectedDate ?? DateTime.now(),
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sesi telah berakhir, silakan login kembali'), backgroundColor: Colors.red),
                    );
                  }
                },
              ),
            ],
          ),
          onTap: () {
            // Kita biarkan onTap kosong atau samakan dengan tombol agar seluruh baris bisa ditekan
            final userId = sl<AuthBloc>().state.user?.id;
            if (userId != null) {
              context.read<MealsBloc>().add(MealAdded(
                userId: userId,
                food: food,
                mealType: widget.mealName.toLowerCase(),
                servings: 1,
                date: widget.selectedDate ?? DateTime.now(),
              ));
            }
          },
        ),
        const Divider(height: 1, indent: 24, endIndent: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.mealName,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          if (_isAIAnalyzing)
            const LinearProgressIndicator(minHeight: 3, color: Colors.blue),
            
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                context.read<MealsBloc>().add(FoodsFetched(query: val));
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                hintText: 'Cari makanan...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.grey, size: 20),
                    tooltip: 'Foto AI',
                    onPressed: _pickImageAndAnalyze,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          Expanded(
            child: BlocListener<MealsBloc, MealsState>(
              listener: (context, state) {
                if (state.status == MealsStatus.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Makanan berhasil ditambahkan!'), backgroundColor: Colors.green),
                  );
                  Navigator.pop(context);
                } else if (state.status == MealsStatus.error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal: ${state.errorMessage}'), backgroundColor: Colors.red),
                  );
                }
              },
              child: BlocBuilder<MealsBloc, MealsState>(
                builder: (context, state) {
                  if (state.status == MealsStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.foods.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_outlined, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'Makanan tidak ditemukan',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Coba ketik nama lain atau gunakan Foto AI di atas.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade500),
                            )
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: state.foods.length,
                    itemBuilder: (context, index) {
                      return _buildFoodItem(state.foods[index]);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFoodDialog,
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('Buat Makanan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
