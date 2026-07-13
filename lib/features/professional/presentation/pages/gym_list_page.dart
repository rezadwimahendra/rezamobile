import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../bloc/professional_bloc.dart';
import '../bloc/professional_event.dart';
import '../bloc/professional_state.dart';
import './map_webview_page.dart';
import '../../domain/entities/professional_entity.dart';

class GymListPage extends StatefulWidget {
  const GymListPage({super.key});

  @override
  State<GymListPage> createState() => _GymListPageState();
}

class _GymListPageState extends State<GymListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  // Jakarta mock coordinates as default fallback
  double _userLat = -6.2000;
  double _userLng = 106.8166;
  bool _isRealLocation = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfessionalBloc>().add(GymsListRequested());
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) return;

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _userLat = position.latitude;
          _userLng = position.longitude;
          _isRealLocation = true;
        });
      }
    } catch (e) {
      debugPrint('Error getting raw location: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295; // Math.PI / 180
    final double a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFFB800);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Mitra Gym & Studio', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari lokasi gym atau studio...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          Expanded(
            child: BlocBuilder<ProfessionalBloc, ProfessionalState>(
              builder: (context, state) {
                if (state.status == ProfessionalStatus.loading) {
                  return const Center(child: CircularProgressIndicator(color: primaryColor));
                }

                // Sort gyms by distance (if coordinates are present)
                final sortedGyms = List<ProfessionalEntity>.from(state.gyms);
                sortedGyms.sort((a, b) {
                  if (a.latitude != null && a.longitude != null && b.latitude != null && b.longitude != null) {
                    final distA = _calculateDistance(_userLat, _userLng, a.latitude!, a.longitude!);
                    final distB = _calculateDistance(_userLat, _userLng, b.latitude!, b.longitude!);
                    return distA.compareTo(distB);
                  }
                  // Put gyms with maps first
                  final hasMapA = a.latitude != null && a.longitude != null;
                  final hasMapB = b.latitude != null && b.longitude != null;
                  if (hasMapA && !hasMapB) return -1;
                  if (!hasMapA && hasMapB) return 1;
                  return 0;
                });

                // Filter local results based on search input
                final filteredGyms = sortedGyms.where((g) {
                  final query = _searchQuery.toLowerCase();
                  return g.name.toLowerCase().contains(query) ||
                      (g.location?.toLowerCase().contains(query) ?? false);
                }).toList();

                if (filteredGyms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          state.gyms.isEmpty
                              ? 'Belum ada mitra gym terdaftar'
                              : 'Tidak menemukan gym yang cocok',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredGyms.length,
                  itemBuilder: (context, index) {
                    final gym = filteredGyms[index];
                    
                    double? distance;
                    if (gym.latitude != null && gym.longitude != null) {
                      distance = _calculateDistance(_userLat, _userLng, gym.latitude!, gym.longitude!);
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            child: const Center(
                              child: Icon(Icons.fitness_center, size: 48, color: primaryColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(gym.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                                      child: Text('Aktif', style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 14, color: Colors.red),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(gym.location ?? 'Lokasi tidak tersedia', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                    ),
                                  ],
                                ),
                                if (gym.openTime != null && gym.closeTime != null) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 14, color: Colors.blue),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          "Operasional: ${(gym.openDays != null && gym.openDays!.isNotEmpty) ? gym.openDays! : 'Setiap Hari'} (${gym.openTime} - ${gym.closeTime})",
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (distance != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.directions_run, size: 14, color: primaryColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${distance.toStringAsFixed(1)} km dari lokasi Anda${_isRealLocation ? '' : ' (Simulasi)'}",
                                        style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                                            builder: (_) => Container(
                                              padding: const EdgeInsets.all(24),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(gym.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                                  const SizedBox(height: 8),
                                                  Text(gym.location ?? 'Lokasi tidak tersedia', style: const TextStyle(color: Colors.grey)),
                                                  if (gym.openTime != null && gym.closeTime != null) ...[
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.access_time_filled, size: 16, color: Colors.blue),
                                                        const SizedBox(width: 6),
                                                        Expanded(
                                                          child: Text(
                                                            'Operasional: ${(gym.openDays != null && gym.openDays!.isNotEmpty) ? gym.openDays! : "Setiap Hari"} (${gym.openTime} s/d ${gym.closeTime})',
                                                            style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.bold),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                  const SizedBox(height: 16),
                                                  const Text('Deskripsi:', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  const SizedBox(height: 8),
                                                  Text(gym.description),
                                                  const SizedBox(height: 16),
                                                  const Text('Informasi Tarif & Tiket masuk:', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          padding: const EdgeInsets.all(12),
                                                          decoration: BoxDecoration(
                                                            color: Colors.amber.shade50,
                                                            borderRadius: BorderRadius.circular(12),
                                                            border: Border.all(color: Colors.amber.shade200),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              const Text('Harga Member', style: TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                                                              const SizedBox(height: 4),
                                                              Text('Rp ${gym.price}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                                              const Text('Durasi: 1 Bulan', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      if (gym.nonMemberPrice != null) ...[
                                                        const SizedBox(width: 12),
                                                        Expanded(
                                                          child: Container(
                                                            padding: const EdgeInsets.all(12),
                                                            decoration: BoxDecoration(
                                                              color: Colors.grey.shade100,
                                                              borderRadius: BorderRadius.circular(12),
                                                              border: Border.all(color: Colors.grey.shade300),
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                const Text('Harga Non-Member', style: TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                                                                const SizedBox(height: 4),
                                                                Text('Rp ${gym.nonMemberPrice}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                                                const Text('Durasi: 1 Hari (Harian)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  const SizedBox(height: 24),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          side: BorderSide(color: Colors.grey.shade200),
                                        ),
                                        child: const Text('Detail', style: TextStyle(color: Colors.black)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (gym.latitude != null && gym.longitude != null) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => MapWebViewPage(
                                                  latitude: gym.latitude!,
                                                  longitude: gym.longitude!,
                                                  gymName: gym.name,
                                                ),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Lokasi peta belum diunggah oleh mitra gym ini.'),
                                                backgroundColor: Colors.redAccent,
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          elevation: 0,
                                        ),
                                        child: const Text('Lihat Map', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
