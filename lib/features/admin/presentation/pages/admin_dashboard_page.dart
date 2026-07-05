import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;
  final pb = sl<PocketBase>();

  // Metrics database
  int _totalUsers = 0;
  int _totalTrainers = 0;
  int _totalGyms = 0;
  int _totalFoods = 0;
  bool _isLoading = true;

  // Search & Filters
  String _userSearchQuery = '';
  String _userFilterRole = 'all'; // all, user, pro, admin, trainer, gym

  // Theme Colors: Premium White & Gold/Yellow
  final Color _primaryColor = const Color(0xFFFFB300); // Amber Gold
  final Color _bgColor = const Color(0xFFF8F9FA); // Off-White
  final Color _surfaceColor = Colors.white; // Card / Sidebar Background
  final Color _textColor = const Color(0xFF2D3748); // Slate Navy
  final Color _subtextColor = const Color(0xFF718096); // Grey
  final Color _borderColor = const Color(0xFFE2E8F0); // Subtle Border

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final futures = await Future.wait([
        pb.collection('users').getFullList(),
        pb.collection('trainers').getFullList(),
        pb.collection('gyms').getFullList(),
        pb.collection('foods').getFullList(),
      ]);

      if (mounted) {
        setState(() {
          _totalUsers = futures[0].length;
          _totalTrainers = futures[1].length;
          _totalGyms = futures[2].length;
          _totalFoods = futures[3].length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal sinkron data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Row(
        children: [
          // SIDEBAR - Menggunakan konstruksi working dari tmp_admin
          _buildSidebar(),

          // MAIN PANEL CONTENT
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: _primaryColor))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(32.0),
                          child: _buildSelectedContent(),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String title = 'Ringkasan Sistem';
    if (_selectedIndex == 1) title = 'Database Pengguna';
    if (_selectedIndex == 2) title = 'Verifikasi Mitra';
    if (_selectedIndex == 3) title = 'Dataset Makanan';

    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: _surfaceColor,
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          ElevatedButton.icon(
            onPressed: _loadMetrics,
            icon: Icon(Icons.refresh, size: 16, color: _textColor),
            label: Text('Sinkron Server', style: GoogleFonts.outfit(color: _textColor, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: _surfaceColor,
        border: Border(right: BorderSide(color: _borderColor)),
      ),
      child: Column(
        children: [
          // LOGO FITMOTION
          Container(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FitMotion',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _textColor,
                      ),
                    ),
                    Text(
                      'PORTAL ADMIN',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 20),

          // MENU LIST - Menggunakan HoverEffectWidget & ListTile seperti tmp_admin
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                _buildSidebarItem(0, Icons.grid_view_rounded, 'Ringkasan'),
                _buildSidebarItem(1, Icons.group_outlined, 'Manajemen User'),
                _buildSidebarItem(2, Icons.verified_user_outlined, 'Verifikasi Mitra'),
                _buildSidebarItem(3, Icons.local_dining_outlined, 'Data Makanan'),
              ],
            ),
          ),

          const Divider(height: 1),
          // LOGOUT BAR
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return HoverEffectWidget(
      builder: (isHovered) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? _primaryColor.withOpacity(0.15)
                : isHovered
                    ? Colors.grey.shade100
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
            leading: Icon(
              icon,
              color: isSelected
                  ? _primaryColor
                  : isHovered
                      ? _textColor
                      : _subtextColor,
            ),
            title: Text(
              title,
              style: GoogleFonts.outfit(
                color: isSelected
                    ? _textColor
                    : isHovered
                        ? _textColor
                        : _subtextColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return HoverEffectWidget(
      builder: (isHovered) {
        return Container(
          margin: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isHovered ? Colors.red.shade50 : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            onTap: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
            leading: Icon(
              Icons.logout,
              color: isHovered ? Colors.red : _subtextColor,
            ),
            title: Text(
              'Keluar Admin',
              style: GoogleFonts.outfit(
                color: isHovered ? Colors.red : _subtextColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverviewLanding();
      case 1:
        return _buildUserManagementContent();
      case 2:
        return _buildMitraVerificationContent();
      case 3:
        return _buildFoodsManagementContent();
      default:
        return const Center(child: Text('Fitur sedang dikembangkan'));
    }
  }

  // --- TAB 0: RINGKASAN SYSTEM ---
  Widget _buildOverviewLanding() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // METRICS CARDS
        Row(
          children: [
            Expanded(child: _buildStatCard('Total Pengguna', _totalUsers.toString(), Icons.people_outline)),
            const SizedBox(width: 20),
            Expanded(child: _buildStatCard('Mitra Pelatih', _totalTrainers.toString(), Icons.sports_kabaddi_outlined)),
            const SizedBox(width: 20),
            Expanded(child: _buildStatCard('Fasilitas Gym', _totalGyms.toString(), Icons.domain_outlined)),
            const SizedBox(width: 20),
            Expanded(child: _buildStatCard('Dataset Makanan', _totalFoods.toString(), Icons.local_pizza_outlined)),
          ],
        ),
        const SizedBox(height: 32),

        // WELCOME BANNER WIDGET
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _borderColor),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 8))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selamat Datang di Portal SuperAdmin!',
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: _textColor),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text('API Connected', style: GoogleFonts.outfit(color: Colors.green.shade800, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Segala kendali manajemen pengguna, pelatih kebugaran mitra, verifikasi permohonan gym, dan database hidangan makanan gizi telah terintegrasi penuh ke PocketBase node lokal.',
                style: GoogleFonts.outfit(color: _subtextColor, fontSize: 15, height: 1.6),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildQuickActionBtn('Kelola Akun Pengguna', () => setState(() => _selectedIndex = 1), Icons.group_add_outlined),
                  _buildQuickActionBtn('Verifikasi Trainer Baru', () => setState(() => _selectedIndex = 2), Icons.assignment_turned_in_outlined),
                  _buildQuickActionBtn('Tambah Database Makanan', () => setState(() => _selectedIndex = 3), Icons.dinner_dining_outlined),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionBtn(String label, VoidCallback onTap, IconData icon) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: _textColor),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: _textColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: _borderColor)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      label: Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: _primaryColor, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(color: _subtextColor, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(value, style: GoogleFonts.outfit(color: _textColor, fontSize: 32, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 1: MANAJEMEN USER ---
  Widget _buildUserManagementContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Daftar Akun Klien & Staf', style: GoogleFonts.outfit(fontSize: 18, color: _textColor, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: _showAddUserDialog,
              icon: const Icon(Icons.person_add_alt_1, size: 16, color: Colors.white),
              label: Text('Tambah User', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _textColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // SEARCH AND FILTER
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(color: _surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: _borderColor)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.search, color: _subtextColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: _textColor),
                        onChanged: (val) => setState(() => _userSearchQuery = val.toLowerCase()),
                        decoration: InputDecoration(
                          hintText: 'Cari nama atau email...',
                          hintStyle: GoogleFonts.outfit(color: _subtextColor, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: _surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: _borderColor)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _userFilterRole,
                  dropdownColor: _surfaceColor,
                  style: GoogleFonts.outfit(color: _textColor, fontSize: 13, fontWeight: FontWeight.bold),
                  icon: Icon(Icons.filter_alt_outlined, color: _primaryColor),
                  onChanged: (String? val) {
                    if (val != null) setState(() => _userFilterRole = val);
                  },
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tampilkan Semua')),
                    DropdownMenuItem(value: 'user', child: Text('Klien Biasa')),
                    DropdownMenuItem(value: 'pro', child: Text('Klien Premium')),
                    DropdownMenuItem(value: 'admin', child: Text('Staf Admin')),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // USER TABLE
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor),
          ),
          child: FutureBuilder<List<RecordModel>>(
            future: pb.collection('users').getFullList(sort: '-created'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(child: Text('Tidak ada user ditemukan', style: GoogleFonts.outfit(color: _subtextColor))),
                );
              }

              final filtered = snapshot.data!.where((u) {
                final name = u.getStringValue('name').toLowerCase();
                final email = u.getStringValue('email').toLowerCase();
                final matchSearch = name.contains(_userSearchQuery) || email.contains(_userSearchQuery);
                if (!matchSearch) return false;

                if (_userFilterRole == 'all') return true;
                return u.getStringValue('role') == _userFilterRole;
              }).toList();

              if (filtered.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(child: Text('Tidak ada pengguna yang cocok', style: GoogleFonts.outfit(color: _subtextColor))),
                );
              }

              return DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                columns: [
                  DataColumn(label: Text('Nama', style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Email', style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Tipe Akses', style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Mitra', style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Aksi', style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
                ],
                rows: filtered.map((u) {
                  final isTrainer = u.data['is_trainer'] == true;
                  final isGym = u.data['is_gym'] == true;
                  final role = u.getStringValue('role');

                  return DataRow(cells: [
                    DataCell(Text(u.getStringValue('name'), style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
                    DataCell(Text(u.getStringValue('email'), style: GoogleFonts.outfit(color: _subtextColor))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: role == 'admin'
                              ? Colors.red.shade50
                              : role == 'pro'
                                  ? _primaryColor.withOpacity(0.12)
                                  : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: role == 'admin' ? Colors.red : (role == 'pro' ? _textColor : _subtextColor),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Trainer', style: TextStyle(fontSize: 10)),
                            selected: isTrainer,
                            selectedColor: _primaryColor.withOpacity(0.3),
                            onSelected: (val) async {
                              await pb.collection('users').update(u.id, body: {'is_trainer': val});
                              _loadMetrics();
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Gym', style: TextStyle(fontSize: 10)),
                            selected: isGym,
                            selectedColor: _primaryColor.withOpacity(0.3),
                            onSelected: (val) async {
                              await pb.collection('users').update(u.id, body: {'is_gym': val});
                              _loadMetrics();
                            },
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 18),
                            onPressed: () => _showEditUserDialog(u),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                            onPressed: () => _deleteRecord('users', u.id),
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String selectedRole = 'user';
    bool isTrainer = false;
    bool isGym = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: _surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Tambah Pengguna Baru', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: _textColor)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap', labelStyle: TextStyle(color: Colors.grey)),
                ),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: Colors.grey)),
                ),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', labelStyle: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  dropdownColor: _surfaceColor,
                  decoration: const InputDecoration(labelText: 'Tipe Hak Akses', labelStyle: TextStyle(color: Colors.grey)),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('Klien Free')),
                    DropdownMenuItem(value: 'pro', child: Text('Klien Premium Pro')),
                    DropdownMenuItem(value: 'admin', child: Text('Administrator')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedRole = val);
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Status Trainer', style: TextStyle(fontSize: 13)),
                  value: isTrainer,
                  activeColor: _primaryColor,
                  onChanged: (val) => setDialogState(() => isTrainer = val),
                ),
                SwitchListTile(
                  title: const Text('Status Partner Gym', style: TextStyle(fontSize: 13)),
                  value: isGym,
                  activeColor: _primaryColor,
                  onChanged: (val) => setDialogState(() => isGym = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: TextStyle(color: _subtextColor))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, elevation: 0),
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty && passwordCtrl.text.isNotEmpty) {
                  try {
                    await pb.collection('users').create(body: {
                      'name': nameCtrl.text,
                      'email': emailCtrl.text,
                      'password': passwordCtrl.text,
                      'passwordConfirm': passwordCtrl.text,
                      'role': selectedRole,
                      'is_trainer': isTrainer,
                      'is_gym': isGym,
                      'verified': true,
                    });
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      _loadMetrics();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Klien berhasil dibuat!'), backgroundColor: Colors.green));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat user: $e'), backgroundColor: Colors.red));
                    }
                  }
                }
              },
              child: Text('Simpan', style: GoogleFonts.outfit(color: _textColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(RecordModel u) {
    final nameCtrl = TextEditingController(text: u.getStringValue('name'));
    final emailCtrl = TextEditingController(text: u.getStringValue('email'));
    final passwordCtrl = TextEditingController();
    String selectedRole = u.getStringValue('role');
    bool isTrainer = u.data['is_trainer'] == true;
    bool isGym = u.data['is_gym'] == true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: _surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Profil Pengguna', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: _textColor)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                ),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Sandi Baru (Optional)'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole.isEmpty ? 'user' : selectedRole,
                  dropdownColor: _surfaceColor,
                  decoration: const InputDecoration(labelText: 'Tipe Akses'),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('Klien Free')),
                    DropdownMenuItem(value: 'pro', child: Text('Klien Premium Pro')),
                    DropdownMenuItem(value: 'admin', child: Text('Administrator')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedRole = val);
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Status Trainer', style: TextStyle(fontSize: 13)),
                  value: isTrainer,
                  activeColor: _primaryColor,
                  onChanged: (val) => setDialogState(() => isTrainer = val),
                ),
                SwitchListTile(
                  title: const Text('Status Partner Gym', style: TextStyle(fontSize: 13)),
                  value: isGym,
                  activeColor: _primaryColor,
                  onChanged: (val) => setDialogState(() => isGym = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: TextStyle(color: _subtextColor))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, elevation: 0),
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
                  try {
                    final body = {
                      'name': nameCtrl.text,
                      'email': emailCtrl.text,
                      'role': selectedRole,
                      'is_trainer': isTrainer,
                      'is_gym': isGym,
                    };
                    if (passwordCtrl.text.isNotEmpty) {
                      body['password'] = passwordCtrl.text;
                      body['passwordConfirm'] = passwordCtrl.text;
                    }
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      _loadMetrics();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil dirubah'), backgroundColor: Colors.green));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kesalahan: $e'), backgroundColor: Colors.red));
                    }
                  }
                }
              },
              child: Text('Simpan', style: GoogleFonts.outfit(color: _textColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 2: VERIFIKASI MITRA ---
  Widget _buildMitraVerificationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Verifikasi & Permohonan Mitra',
          style: GoogleFonts.outfit(fontSize: 18, color: _textColor, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildMitraCardList('Mitra Trainer Kebugaran', 'trainers')),
            const SizedBox(width: 20),
            Expanded(child: _buildMitraCardList('Fasilitas Gym & Venue', 'gyms')),
          ],
        ),
      ],
    );
  }

  Widget _buildMitraCardList(String title, String collection) {
    return Container(
      height: 480,
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 16, color: _textColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<RecordModel>>(
              future: pb.collection(collection).getFullList(sort: '-created'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Belum ada data pendaftar.', style: GoogleFonts.outfit(color: _subtextColor)));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (ctx, idx) {
                    final item = snapshot.data![idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified_outlined, color: _primaryColor, size: 20),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.getStringValue('name'), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: _textColor)),
                                Text(
                                  item.getStringValue('specialty').isNotEmpty
                                      ? item.getStringValue('specialty')
                                      : 'Lokasi: ${item.getStringValue('location')}',
                                  style: GoogleFonts.outfit(color: _subtextColor, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                            onPressed: () => _deleteRecord(collection, item.id),
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

  // --- TAB 3: DATA MANAJEMEN MAKANAN ---
  Widget _buildFoodsManagementContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Dataset Hidangan Makanan Mandiri', style: GoogleFonts.outfit(fontSize: 18, color: _textColor, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: _showAddFoodDialog,
              icon: const Icon(Icons.restaurant, size: 16, color: Colors.white),
              label: Text('Tambah Makanan', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _textColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: _surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderColor)),
          child: FutureBuilder<List<RecordModel>>(
            future: pb.collection('foods').getFullList(sort: '-created'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(child: Text('Kosong. Klik Tambah Makanan untuk membuat data baru.', style: GoogleFonts.outfit(color: _subtextColor))),
                );
              }

              return DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                columns: [
                  DataColumn(label: Text('Nama Makanan', style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Energi Kalori', style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Kandungan Gizi Makro', style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Hapus', style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
                ],
                rows: snapshot.data!.map((f) {
                  return DataRow(cells: [
                    DataCell(Text(f.getStringValue('name'), style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
                    DataCell(Text('${f.getIntValue('calories')} Kcal', style: GoogleFonts.outfit(color: Colors.orange.shade700, fontWeight: FontWeight.bold))),
                    DataCell(Text(
                      'Protein: ${f.getIntValue('protein')}g • Karbohidrat: ${f.getIntValue('carbs')}g • Lemak: ${f.getIntValue('fat')}g',
                      style: GoogleFonts.outfit(color: _subtextColor, fontSize: 13),
                    )),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => _deleteRecord('foods', f.id),
                      ),
                    ),
                  ]);
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddFoodDialog() {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final protCtrl = TextEditingController();
    final carbCtrl = TextEditingController();
    final fatCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Tambah Hidangan Baru', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: _textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Makanan')),
            TextField(controller: calCtrl, decoration: const InputDecoration(labelText: 'Kalori (Kcal)'), keyboardType: TextInputType.number),
            TextField(controller: protCtrl, decoration: const InputDecoration(labelText: 'Protein (g)'), keyboardType: TextInputType.number),
            TextField(controller: carbCtrl, decoration: const InputDecoration(labelText: 'Karbohidrat (g)'), keyboardType: TextInputType.number),
            TextField(controller: fatCtrl, decoration: const InputDecoration(labelText: 'Lemak (g)'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: TextStyle(color: _subtextColor))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, elevation: 0),
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty && calCtrl.text.isNotEmpty) {
                try {
                  await pb.collection('foods').create(body: {
                    'name': nameCtrl.text,
                    'calories': int.tryParse(calCtrl.text) ?? 0,
                    'protein': int.tryParse(protCtrl.text) ?? 0,
                    'carbs': int.tryParse(carbCtrl.text) ?? 0,
                    'fat': int.tryParse(fatCtrl.text) ?? 0,
                  });
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    _loadMetrics();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Makanan berhasil ditambahkan'), backgroundColor: Colors.green));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kesalahan: $e'), backgroundColor: Colors.red));
                  }
                }
              }
            },
            child: Text('Simpan', style: GoogleFonts.outfit(color: _textColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRecord(String collection, String id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Hapus', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin menghapus data ini permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    try {
      await pb.collection(collection).delete(id);
      _loadMetrics();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil dihapus dari node!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red));
      }
    }
  }
}

// Custom simple stateful hover widget to support elegant animations
class HoverEffectWidget extends StatefulWidget {
  final Widget Function(bool isHovered) builder;

  const HoverEffectWidget({super.key, required this.builder});

  @override
  State<HoverEffectWidget> createState() => _HoverEffectWidgetState();
}

class _HoverEffectWidgetState extends State<HoverEffectWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: widget.builder(_isHovered),
    );
  }
}
