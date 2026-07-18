import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:fitness_app/injection.dart';
import '../bloc/professional_bloc.dart';
import '../bloc/professional_event.dart';
import '../bloc/professional_state.dart';
import '../../../community/presentation/pages/user_profile_page.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _baseUrl = sl<PocketBase>().baseUrl;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update hintText of search field
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchInitialData();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _fetchInitialData() {
    context.read<ProfessionalBloc>().add(TrainersListRequested());
    context.read<ProfessionalBloc>().add(GymsListRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Pelatih Pro'),
            Tab(text: 'Mitra Gym'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: _tabController.index == 0 
                    ? 'Cari nama atau keahlian/spesialisasi pelatih...' 
                    : 'Cari nama atau lokasi gym mitra...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: const Icon(Icons.search, size: 20, color: Colors.blueGrey),
                suffixIcon: _searchQuery.isNotEmpty 
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Icon(Icons.clear, size: 18, color: Colors.blueGrey),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF1F3F5),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTrainersList(),
                _buildGymsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainersList() {
    return BlocBuilder<ProfessionalBloc, ProfessionalState>(
      builder: (context, state) {
        if (state.status == ProfessionalStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final trainers = state.trainers;
        final filteredTrainers = trainers.where((t) {
          final query = _searchQuery.toLowerCase();
          return t.name.toLowerCase().contains(query) ||
              (t.specialty?.toLowerCase().contains(query) ?? false);
        }).toList();

        if (filteredTrainers.isEmpty) {
          return _buildEmptyState('Tidak menemukan pelatih yang cocok');
        }

        return RefreshIndicator(
          onRefresh: () async => context.read<ProfessionalBloc>().add(TrainersListRequested()),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredTrainers.length,
            itemBuilder: (context, index) {
              final trainer = filteredTrainers[index];
              return _buildProfessionalCard(
                trainer.name,
                trainer.specialty ?? 'General Fitness',
                trainer.price,
                trainer.id,
                trainer.userId,
                'trainers',
                trainer.avatar,
                isTrainer: true,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGymsList() {
    return BlocBuilder<ProfessionalBloc, ProfessionalState>(
      builder: (context, state) {
        if (state.status == ProfessionalStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final gyms = state.gyms;
        final filteredGyms = gyms.where((g) {
          final query = _searchQuery.toLowerCase();
          return g.name.toLowerCase().contains(query) ||
              (g.location?.toLowerCase().contains(query) ?? false);
        }).toList();

        if (filteredGyms.isEmpty) {
          return _buildEmptyState('Tidak menemukan gym yang cocok');
        }

        return RefreshIndicator(
          onRefresh: () async => context.read<ProfessionalBloc>().add(GymsListRequested()),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredGyms.length,
            itemBuilder: (context, index) {
              final gym = filteredGyms[index];
              return _buildProfessionalCard(
                gym.name,
                gym.location ?? 'Lokasi tidak tersedia',
                gym.price,
                gym.id,
                gym.userId,
                'gyms',
                gym.avatar,
                isGym: true,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProfessionalCard(
    String name, 
    String subtitle, 
    int price, 
    String recordId, 
    String userId, 
    String collection, 
    String? avatarName,
    {bool isTrainer = false, bool isGym = false}
  ) {
    String? imageUrl;
    if (avatarName != null && avatarName.isNotEmpty) {
      imageUrl = "$_baseUrl/api/files/$collection/$recordId/$avatarName";
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfilePage(
              userId: userId,
              userName: name,
              isTrainer: isTrainer,
              isGym: isGym,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                image: imageUrl != null ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null,
              ),
              child: imageUrl == null ? Icon(isTrainer ? Icons.person : Icons.apartment, color: Colors.grey) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle, 
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mulai dari Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w900, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black12),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.black12),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.black38)),
        ],
      ),
    );
  }
}
