import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

// ─── Colour tokens ───────────────────────────────────────────────────────────
const _bg      = Color(0xFFF4F6FA);
const _sidebar  = Colors.white;
const _card     = Colors.white;
const _cardBdr  = Color(0xFFE2E8F0);
const _gold     = Color(0xFFFFB300);
const _goldDim  = Color(0xFFE6A100);
const _text1    = Color(0xFF0F1621);
const _text2    = Color(0xFF4A5568);
const _text3    = Color(0xFF94A3B8);
const _purple   = Color(0xFF7C3AED);
const _teal     = Color(0xFF0D9488);
const _rose     = Color(0xFFEF4444);
const _green    = Color(0xFF16A34A);
const _blue     = Color(0xFF2563EB);

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});
  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  final _pb = sl<PocketBase>();

  int  _tab  = 0;
  bool _busy = true;

  // Stats
  int _nUsers = 0, _nTrainers = 0, _nGyms = 0, _nFoods = 0;

  // Cached Futures to prevent multiple requests and auto-cancellations on tab navigation
  Future<List<RecordModel>>? _usersFuture;
  Future<List<RecordModel>>? _trainersFuture;
  Future<List<RecordModel>>? _gymsFuture;
  Future<List<RecordModel>>? _foodsFuture;

  // Users tab
  String _q = '', _roleFilter = 'all';

  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350))..forward();
    _refresh();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() => _busy = true);
    try {
      final uFuture = _pb.collection('users').getFullList(sort: '-created', fields: 'id,name,email,role,is_trainer,is_gym,created,emailVisibility');
      final tFuture = _pb.collection('trainers').getFullList(sort: '-created');
      final gFuture = _pb.collection('gyms').getFullList(sort: '-created');
      final fFuture = _pb.collection('foods').getFullList(sort: '-created');

      final r = await Future.wait([
        uFuture,
        tFuture,
        gFuture,
        fFuture,
      ]);
      if (!mounted) return;
      final users = r[0];
      setState(() {
        _usersFuture = uFuture;
        _trainersFuture = tFuture;
        _gymsFuture = gFuture;
        _foodsFuture = fFuture;
        _nUsers    = users.where((u) => u.getStringValue('role') == 'users' || u.getStringValue('role') == 'user').length;
        _nTrainers = r[1].length;
        _nGyms     = r[2].length;
        _nFoods    = r[3].length;
        _busy      = false;
      });
    } catch (_) {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(String col, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(message: 'Data akan dihapus permanen. Lanjutkan?'),
    );
    if (ok != true || !mounted) return;
    try {
      await _pb.collection(col).delete(id);
      if (mounted) {
        _refresh();
        _snack('Data berhasil dihapus', _green);
      }
    } catch (e) {
      if (mounted) _snack('Gagal: $e', _rose);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(20),
    ));
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 850;

    return Scaffold(
      backgroundColor: _bg,
      drawer: isMobile
          ? Drawer(
              child: _buildSidebar(isMobileDrawer: true),
            )
          : null,
      body: FadeTransition(
        opacity: _fadeCtrl,
        child: Row(children: [
          if (!isMobile) _buildSidebar(),
          Expanded(child: _buildMain(isMobile: isMobile)),
        ]),
      ),
    );
  }

  // ── SIDEBAR ────────────────────────────────────────────────────────────────
  Widget _buildSidebar({bool isMobileDrawer = false}) {
    final logo = Container(
      padding: const EdgeInsets.fromLTRB(22, 30, 22, 24),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_gold, _goldDim],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('FitMotion', style: GoogleFonts.outfit(color: _text1, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.2)),
          Text('ADMIN PORTAL', style: GoogleFonts.outfit(color: _gold, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2.0)),
        ]),
      ]),
    );

    final content = Column(children: [
      logo,
      Container(height: 1, color: _cardBdr),
      const SizedBox(height: 14),

      // Nav
      _SideItem(icon: Icons.grid_view_rounded,    label: 'Ringkasan',        sel: _tab == 0, onTap: () => _setTab(0, isMobileDrawer: isMobileDrawer)),
      _SideItem(icon: Icons.people_alt_outlined,   label: 'Pengguna',         sel: _tab == 1, onTap: () => _setTab(1, isMobileDrawer: isMobileDrawer)),
      _SideItem(icon: Icons.verified_outlined,     label: 'Verifikasi Mitra', sel: _tab == 2, onTap: () => _setTab(2, isMobileDrawer: isMobileDrawer)),
      _SideItem(icon: Icons.restaurant_outlined,   label: 'Dataset Makanan',  sel: _tab == 3, onTap: () => _setTab(3, isMobileDrawer: isMobileDrawer)),

      const Spacer(),
      Container(height: 1, color: _cardBdr),
      const SizedBox(height: 8),
      _SideItem(
        icon: Icons.logout_rounded, label: 'Keluar', sel: false, danger: true,
        onTap: () => context.read<AuthBloc>().add(LogoutRequested()),
      ),
      const SizedBox(height: 16),
    ]);

    return Container(
      width: 248,
      decoration: const BoxDecoration(
        color: _sidebar,
        border: Border(right: BorderSide(color: _cardBdr, width: 1)),
      ),
      child: isMobileDrawer ? SafeArea(child: content) : content,
    );
  }

  void _setTab(int t, {bool isMobileDrawer = false}) {
    if (isMobileDrawer) {
      Navigator.pop(context);
    }
    setState(() { _tab = t; _q = ''; _roleFilter = 'all'; });
  }

  // ── MAIN ──────────────────────────────────────────────────────────────────
  Widget _buildMain({required bool isMobile}) {
    const titles = ['Ringkasan', 'Manajemen Pengguna', 'Verifikasi Mitra', 'Dataset Makanan'];
    return Column(children: [
      // Top bar
      Container(
        height: 62,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: _cardBdr)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            if (isMobile) ...[
              Builder(builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: _text1),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              )),
              const SizedBox(width: 8),
            ],
            Container(width: 3, height: 20, decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 12),
            Text(titles[_tab], style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: _text1)),
          ]),
          OutlinedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded, size: 15),
            label: Text('Refresh', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
            style: OutlinedButton.styleFrom(
              foregroundColor: _text2,
              side: const BorderSide(color: _cardBdr),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ]),
      ),
      // Content
      Expanded(
        child: _busy
            ? const Center(child: CircularProgressIndicator(color: _gold))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: _buildContent(isMobile: isMobile),
              ),
      ),
    ]);
  }

  Widget _buildContent({required bool isMobile}) {
    switch (_tab) {
      case 0: return _buildOverview(isMobile: isMobile);
      case 1: return _buildUsers();
      case 2: return _buildMitra(isMobile: isMobile);
      case 3: return _buildFoods();
      default: return const SizedBox();
    }
  }

  // ── OVERVIEW ──────────────────────────────────────────────────────────────
  Widget _buildOverview({required bool isMobile}) {
    final cards = [
      _StatCard(label: 'Total User',   value: '$_nUsers',    icon: Icons.person_outline,            color: _gold,   sub: 'role: users'),
      _StatCard(label: 'Trainer',      value: '$_nTrainers', icon: Icons.sports_outlined,            color: _teal,   sub: 'terdaftar'),
      _StatCard(label: 'Gym',          value: '$_nGyms',     icon: Icons.domain_outlined,            color: _rose,   sub: 'terdaftar'),
      _StatCard(label: 'Data Makanan', value: '$_nFoods',    icon: Icons.restaurant_menu_outlined,   color: _green,  sub: 'dataset'),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (isMobile)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          itemCount: cards.length,
          itemBuilder: (_, i) => cards[i],
        )
      else
        Row(children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 14),
          Expanded(child: cards[1]),
          const SizedBox(width: 14),
          Expanded(child: cards[2]),
          const SizedBox(width: 14),
          Expanded(child: cards[3]),
        ]),
      const SizedBox(height: 24),

      // System status + quick nav
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _cardBdr)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('Status Sistem', style: GoogleFonts.outfit(color: _text1, fontWeight: FontWeight.w700, fontSize: 15)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 7, height: 7, decoration: const BoxDecoration(color: _green, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('PocketBase Terhubung', style: GoogleFonts.outfit(color: _green, fontSize: 11, fontWeight: FontWeight.w600)),
              ]),
            ),
          ]),
          const SizedBox(height: 20),
          Text('Navigasi Cepat', style: GoogleFonts.outfit(color: _text2, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(spacing: 10, runSpacing: 10, children: [
            _QuickBtn(label: 'Kelola Pengguna',  icon: Icons.people_alt_outlined,  onTap: () => _setTab(1)),
            _QuickBtn(label: 'Verifikasi Mitra', icon: Icons.verified_outlined,    onTap: () => _setTab(2)),
            _QuickBtn(label: 'Tambah Makanan',   icon: Icons.add_circle_outline,   onTap: () { _setTab(3); _showAddFood(); }),
          ]),
        ]),
      ),
    ]);
  }

  // ── USERS ─────────────────────────────────────────────────────────────────
  Widget _buildUsers() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('Daftar Pengguna', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: _text1)),
        const SizedBox(width: 16),
        _GoldBtn(label: 'Tambah Pengguna', icon: Icons.person_add_alt_1_rounded, onTap: _showAddUser),
      ]),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _SearchField(hint: 'Cari nama atau email…', onChanged: (v) => setState(() => _q = v.toLowerCase()))),
        const SizedBox(width: 12),
        _LightDrop(
          value: _roleFilter,
          items: const {'all': 'Semua Role', 'users': 'User', 'admin': 'Admin'},
          onChanged: (v) => setState(() => _roleFilter = v),
        ),
      ]),
      const SizedBox(height: 16),
      _FutureTable<RecordModel>(
        future: _usersFuture ?? Future.value([]),
        columns: const ['Nama', 'Email', 'Role', 'Bergabung', 'Aksi'],
        empty: 'Tidak ada pengguna.',
        filter: (u) {
          final name  = u.getStringValue('name').toLowerCase();
          final email = (u.data['email']?.toString() ?? '').toLowerCase();
          var role    = u.getStringValue('role');
          if (role == 'user') role = 'users';
          if (_q.isNotEmpty && !name.contains(_q) && !email.contains(_q)) return false;
          if (_roleFilter != 'all' && role != _roleFilter) return false;
          return true;
        },
        rowBuilder: (u) {
          final name    = u.getStringValue('name');
          final email   = u.data['email']?.toString() ?? '—';
          final role    = u.getStringValue('role');
          final created = u.created.isNotEmpty ? u.created.substring(0, 10) : '-';
          return DataRow(cells: [
            DataCell(Row(children: [
              CircleAvatar(radius: 14, backgroundColor: _roleColor(role).withValues(alpha: 0.15),
                child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(color: _roleColor(role), fontWeight: FontWeight.bold, fontSize: 12))),
              const SizedBox(width: 10),
              Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13, color: _text1)),
            ])),
            DataCell(Text(email, style: GoogleFonts.outfit(color: _text2, fontSize: 12))),
            DataCell(_RoleBadge(role: role)),
            DataCell(Text(created, style: GoogleFonts.outfit(color: _text3, fontSize: 11))),
            DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
              _IconBtn(icon: Icons.edit_outlined,  color: _blue, onTap: () => _showEditUser(u)),
              _IconBtn(icon: Icons.delete_outline, color: _rose, onTap: () => _delete('users', u.id)),
            ])),
          ]);
        },
      ),
    ]);
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin': return _rose;
      default:      return const Color(0xFFD97706);
    }
  }

  void _showAddUser() {
    final nc = TextEditingController(), ec = TextEditingController(), pc = TextEditingController();
    String role = 'users'; bool isTr = false, isGy = false;
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, ss) => _LightDialog(
      title: 'Tambah Pengguna',
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _LightTF(ctrl: nc, label: 'Nama Lengkap'),
        _LightTF(ctrl: ec, label: 'Email', kb: TextInputType.emailAddress),
        _LightTF(ctrl: pc, label: 'Password', hide: true),
        _LightDrop2(value: role, label: 'Role',
          items: const {'users': 'User', 'admin': 'Admin'},
          onChanged: (v) => ss(() => role = v)),
        _LightSwitch(label: 'Trainer', value: isTr, onChanged: (v) => ss(() => isTr = v)),
        _LightSwitch(label: 'Gym',     value: isGy, onChanged: (v) => ss(() => isGy = v)),
      ]),
      onSave: () async {
        if (nc.text.isEmpty || ec.text.isEmpty || pc.text.isEmpty) return;
        await _pb.collection('users').create(body: {
          'name': nc.text, 'email': ec.text,
          'password': pc.text, 'passwordConfirm': pc.text,
          'role': role, 'is_trainer': isTr, 'is_gym': isGy, 'emailVisibility': true,
        });
        if (ctx.mounted) Navigator.pop(ctx);
        _refresh();
      },
    )));
  }

  void _showEditUser(RecordModel u) {
    final nc = TextEditingController(text: u.getStringValue('name'));
    final ec = TextEditingController(text: u.getStringValue('email'));
    final pc = TextEditingController();
    String role = u.getStringValue('role');
    if (role.isEmpty || role == 'user') role = 'users';
    bool isTr = u.data['is_trainer'] == true, isGy = u.data['is_gym'] == true;
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, ss) => _LightDialog(
      title: 'Edit Pengguna',
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _LightTF(ctrl: nc, label: 'Nama Lengkap'),
        _LightTF(ctrl: ec, label: 'Email', kb: TextInputType.emailAddress),
        _LightTF(ctrl: pc, label: 'Sandi Baru (Opsional)', hide: true),
        _LightDrop2(value: role, label: 'Role',
          items: const {'users': 'User', 'admin': 'Admin'},
          onChanged: (v) => ss(() => role = v)),
        _LightSwitch(label: 'Trainer', value: isTr, onChanged: (v) => ss(() => isTr = v)),
        _LightSwitch(label: 'Gym',     value: isGy, onChanged: (v) => ss(() => isGy = v)),
      ]),
      onSave: () async {
        final body = <String, dynamic>{
          'name': nc.text,
          'email': ec.text,
          'role': role,
          'is_trainer': isTr,
          'is_gym': isGy,
          'emailVisibility': true,
        };
        if (pc.text.isNotEmpty) { body['password'] = pc.text; body['passwordConfirm'] = pc.text; }
        await _pb.collection('users').update(u.id, body: body);
        if (ctx.mounted) Navigator.pop(ctx);
        _refresh();
      },
    )));
  }

  // ── MITRA ─────────────────────────────────────────────────────────────────
  Widget _buildMitra({required bool isMobile}) {
    final panels = [
      _MitraPanel(
        future: _trainersFuture ?? Future.value([]),
        title: 'Trainer', col: 'trainers',
        icon: Icons.sports_outlined, color: _teal, onDelete: _delete),
      _MitraPanel(
        future: _gymsFuture ?? Future.value([]),
        title: 'Gym', col: 'gyms',
        icon: Icons.domain_outlined, color: _rose, onDelete: _delete),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Verifikasi & Kelola Mitra', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: _text1)),
      const SizedBox(height: 16),
      if (isMobile)
        Column(children: [
          panels[0],
          const SizedBox(height: 16),
          panels[1],
        ])
      else
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: panels[0]),
          const SizedBox(width: 16),
          Expanded(child: panels[1]),
        ]),
    ]);
  }

  // ── FOODS ─────────────────────────────────────────────────────────────────
  Widget _buildFoods() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('Dataset Makanan', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: _text1)),
        const SizedBox(width: 16),
        _GoldBtn(label: 'Tambah Makanan', icon: Icons.add_rounded, onTap: _showAddFood),
      ]),
      const SizedBox(height: 16),
      _FutureTable<RecordModel>(
        future: _foodsFuture ?? Future.value([]),
        columns: const ['Nama', 'Kalori', 'Protein', 'Karbohidrat', 'Lemak', 'Dibuat', 'Aksi'],
        empty: 'Belum ada data makanan.',
        rowBuilder: (f) => DataRow(cells: [
          DataCell(Text(f.getStringValue('name'), style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13, color: _text1))),
          DataCell(_NumBadge(value: '${f.getIntValue('calories')}', unit: 'kcal', color: const Color(0xFFD97706))),
          DataCell(_NumBadge(value: '${f.getIntValue('protein')}',  unit: 'g',    color: _teal)),
          DataCell(_NumBadge(value: '${f.getIntValue('carbs')}',    unit: 'g',    color: _purple)),
          DataCell(_NumBadge(value: '${f.getIntValue('fat')}',      unit: 'g',    color: _rose)),
          DataCell(Text(f.created.isNotEmpty ? f.created.substring(0, 10) : '-',
            style: GoogleFonts.outfit(color: _text3, fontSize: 11))),
          DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
            _IconBtn(icon: Icons.edit_outlined,  color: _blue, onTap: () => _showEditFood(f)),
            _IconBtn(icon: Icons.delete_outline, color: _rose, onTap: () => _delete('foods', f.id)),
          ])),
        ]),
      ),
    ]);
  }

  void _showAddFood() {
    final nc = TextEditingController(), cc = TextEditingController();
    final pc = TextEditingController(), bc = TextEditingController(), fc = TextEditingController();
    showDialog(context: context, builder: (_) => _LightDialog(
      title: 'Tambah Makanan',
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _LightTF(ctrl: nc, label: 'Nama Makanan'),
        _LightTF(ctrl: cc, label: 'Kalori (kcal)', kb: TextInputType.number),
        _LightTF(ctrl: pc, label: 'Protein (g)',   kb: TextInputType.number),
        _LightTF(ctrl: bc, label: 'Karbohidrat (g)', kb: TextInputType.number),
        _LightTF(ctrl: fc, label: 'Lemak (g)',     kb: TextInputType.number),
      ]),
      onSave: () async {
        if (nc.text.isEmpty) return;
        await _pb.collection('foods').create(body: {
          'name': nc.text,
          'calories': int.tryParse(cc.text) ?? 0,
          'protein':  int.tryParse(pc.text) ?? 0,
          'carbs':    int.tryParse(bc.text) ?? 0,
          'fat':      int.tryParse(fc.text) ?? 0,
        });
        if (mounted) Navigator.pop(context);
        _refresh();
      },
    ));
  }

  void _showEditFood(RecordModel f) {
    final nc = TextEditingController(text: f.getStringValue('name'));
    final cc = TextEditingController(text: '${f.getIntValue('calories')}');
    final pc = TextEditingController(text: '${f.getIntValue('protein')}');
    final bc = TextEditingController(text: '${f.getIntValue('carbs')}');
    final fc = TextEditingController(text: '${f.getIntValue('fat')}');
    showDialog(context: context, builder: (_) => _LightDialog(
      title: 'Edit Makanan',
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _LightTF(ctrl: nc, label: 'Nama Makanan'),
        _LightTF(ctrl: cc, label: 'Kalori (kcal)', kb: TextInputType.number),
        _LightTF(ctrl: pc, label: 'Protein (g)',   kb: TextInputType.number),
        _LightTF(ctrl: bc, label: 'Karbohidrat (g)', kb: TextInputType.number),
        _LightTF(ctrl: fc, label: 'Lemak (g)',     kb: TextInputType.number),
      ]),
      onSave: () async {
        await _pb.collection('foods').update(f.id, body: {
          'name': nc.text,
          'calories': int.tryParse(cc.text) ?? 0,
          'protein':  int.tryParse(pc.text) ?? 0,
          'carbs':    int.tryParse(bc.text) ?? 0,
          'fat':      int.tryParse(fc.text) ?? 0,
        });
        if (mounted) Navigator.pop(context);
        _refresh();
      },
    ));
  }
}

// =============================================================================
//   SIDEBAR NAV ITEM
// =============================================================================
class _SideItem extends StatefulWidget {
  final IconData icon; final String label; final bool sel, danger; final VoidCallback onTap;
  const _SideItem({required this.icon, required this.label, required this.sel, required this.onTap, this.danger = false});
  @override State<_SideItem> createState() => _SideItemState();
}
class _SideItemState extends State<_SideItem> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final Color bg = widget.sel
        ? _gold.withValues(alpha: 0.12)
        : _h
            ? (widget.danger ? _rose.withValues(alpha: 0.06) : _bg)
            : Colors.transparent;
    final Color fg = widget.sel
        ? const Color(0xFFD97706)
        : widget.danger
            ? (_h ? _rose : _text3)
            : (_h ? _text1 : _text2);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _h = true),
        onExit:  (_) => setState(() => _h = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: widget.sel ? Border.all(color: _gold.withValues(alpha: 0.3)) : null,
            ),
            child: Row(children: [
              Icon(widget.icon, color: fg, size: 18),
              const SizedBox(width: 12),
              Text(widget.label, style: GoogleFonts.outfit(color: fg, fontWeight: widget.sel ? FontWeight.w700 : FontWeight.w500, fontSize: 13)),
              if (widget.sel) ...[const Spacer(), Container(width: 5, height: 5, decoration: BoxDecoration(color: _gold, shape: BoxShape.circle))],
            ]),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
//   STAT CARD
// =============================================================================
class _StatCard extends StatelessWidget {
  final String label, value, sub; final IconData icon; final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color, required this.sub});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _cardBdr),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Row(children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 22),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.outfit(color: _text2, fontSize: 11, fontWeight: FontWeight.w600)),
        Text(value, style: GoogleFonts.outfit(color: _text1, fontSize: 22, fontWeight: FontWeight.w900, height: 1.2)),
        Text(sub, style: GoogleFonts.outfit(color: _text3, fontSize: 10)),
      ])),
    ]),
  );
}

// =============================================================================
//   MITRA PANEL
// =============================================================================
class _MitraPanel extends StatelessWidget {
  final Future<List<RecordModel>> future; final String title, col; final IconData icon; final Color color;
  final Future<void> Function(String, String) onDelete;
  const _MitraPanel({required this.future, required this.title, required this.col, required this.icon, required this.color, required this.onDelete});
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBdr),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Text(title, style: GoogleFonts.outfit(color: _text1, fontWeight: FontWeight.w700, fontSize: 14)),
        ]),
        const SizedBox(height: 14),
        const Divider(color: _cardBdr, height: 1),
        const SizedBox(height: 12),
        FutureBuilder<List<RecordModel>>(
          future: future,
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator(color: _gold)),
              );
            }
            if (!snap.hasData || snap.data!.isEmpty) {
              return SizedBox(
                height: 120,
                child: Center(child: Text('Belum ada data.', style: GoogleFonts.outfit(color: _text3))),
              );
            }
            final items = snap.data!.map((item) {
              final name  = item.getStringValue('name');
              final sub   = item.getStringValue('specialty').isNotEmpty
                  ? item.getStringValue('specialty')
                  : item.getStringValue('location');
              final desc  = item.getStringValue('description');
              final price = item.getIntValue('price');
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _cardBdr)),
                child: Row(children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name, style: GoogleFonts.outfit(color: _text1, fontWeight: FontWeight.w600, fontSize: 13)),
                    if (sub.isNotEmpty)  Text(sub,  style: GoogleFonts.outfit(color: _text2, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (desc.isNotEmpty) Text(desc, style: GoogleFonts.outfit(color: _text3, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ])),
                  if (price > 0) ...[
                    Text(_fmtPrice(price), style: GoogleFonts.outfit(color: _gold, fontWeight: FontWeight.w700, fontSize: 11)),
                    const SizedBox(width: 8),
                  ],
                  GestureDetector(
                    onTap: () => onDelete(col, item.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: _rose.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
                      child: const Icon(Icons.delete_outline, size: 15, color: _rose),
                    ),
                  ),
                ]),
              );
            }).toList();
            return Column(children: items);
          },
        ),
      ]),
    );
  }

  String _fmtPrice(int v) {
    if (v >= 1000000) return 'Rp ${(v / 1000000).toStringAsFixed(1)}jt';
    if (v >= 1000)    return 'Rp ${(v / 1000).toStringAsFixed(0)}rb';
    return 'Rp $v';
  }
}

// =============================================================================
//   FUTURE TABLE
// =============================================================================
class _FutureTable<T extends RecordModel> extends StatelessWidget {
  final Future<List<T>> future;
  final List<String> columns;
  final String empty;
  final DataRow Function(T) rowBuilder;
  final bool Function(T)? filter;
  const _FutureTable({required this.future, required this.columns, required this.empty, required this.rowBuilder, this.filter});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _cardBdr),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: FutureBuilder<List<T>>(
      future: future,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator(color: _gold)),
          );
        }
        if (!snap.hasData || snap.data!.isEmpty) {
          return SizedBox(
            height: 180,
            child: Center(child: Text(empty, style: GoogleFonts.outfit(color: _text3))),
          );
        }
        final rows = snap.data!.where((e) => filter == null || filter!(e)).map(rowBuilder).toList();
        if (rows.isEmpty) {
          return SizedBox(
            height: 180,
            child: Center(child: Text('Tidak ada hasil.', style: GoogleFonts.outfit(color: _text3))),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              headingTextStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 11, color: _text2, letterSpacing: 0.6),
              dataTextStyle: GoogleFonts.outfit(color: _text2, fontSize: 13),
              horizontalMargin: 22,
              columnSpacing: 40,
              dividerThickness: 1,
              dataRowColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) return const Color(0xFFF8FAFC);
                return Colors.transparent;
              }),
              columns: columns.map((c) => DataColumn(label: Text(c.toUpperCase()))).toList(),
              rows: rows,
            ),
          ),
        );
      },
    ),
  );
}

// =============================================================================
//   SMALL WIDGETS
// =============================================================================
class _GoldBtn extends StatelessWidget {
  final String label; final IconData icon; final VoidCallback onTap;
  const _GoldBtn({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _gold,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: Colors.black),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 13)),
          ],
        ),
      ),
    ),
  );
}

class _QuickBtn extends StatelessWidget {
  final String label; final IconData icon; final VoidCallback onTap;
  const _QuickBtn({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 14, color: _gold),
    label: Text(label, style: GoogleFonts.outfit(color: _text1, fontWeight: FontWeight.w600, fontSize: 13)),
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      side: const BorderSide(color: _cardBdr),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

class _SearchField extends StatelessWidget {
  final String hint; final ValueChanged<String> onChanged;
  const _SearchField({required this.hint, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    height: 44,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: _cardBdr)),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: Row(children: [
      const Icon(Icons.search, color: _text3, size: 18),
      const SizedBox(width: 10),
      Expanded(child: TextField(
        onChanged: onChanged,
        style: GoogleFonts.outfit(fontSize: 13, color: _text1),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: _text3, fontSize: 13),
          border: InputBorder.none, isDense: true,
        ),
        cursorColor: _gold,
      )),
    ]),
  );
}

class _LightDrop extends StatelessWidget {
  final String value; final Map<String, String> items; final ValueChanged<String> onChanged;
  const _LightDrop({required this.value, required this.items, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: _cardBdr)),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(
      value: value,
      style: GoogleFonts.outfit(color: _text1, fontSize: 13, fontWeight: FontWeight.w600),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _gold),
      onChanged: (v) { if (v != null) onChanged(v); },
      items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: GoogleFonts.outfit(color: _text1, fontSize: 13)))).toList(),
    )),
  );
}

class _IconBtn extends StatelessWidget {
  final IconData icon; final Color color; final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 4),
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    ),
  );
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});
  @override
  Widget build(BuildContext context) {
    Color color; String label;
    switch (role) {
      case 'admin': color = _rose;   label = 'ADMIN';   break;
      default:      color = const Color(0xFFD97706); label = 'USER';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withValues(alpha: 0.25))),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 0.5)),
    );
  }
}

class _NumBadge extends StatelessWidget {
  final String value, unit; final Color color;
  const _NumBadge({required this.value, required this.unit, required this.color});
  @override
  Widget build(BuildContext context) => RichText(text: TextSpan(children: [
    TextSpan(text: value, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
    TextSpan(text: ' $unit', style: GoogleFonts.outfit(color: _text3, fontSize: 11)),
  ]));
}

class _Toggle extends StatelessWidget {
  final String label; final bool on; final VoidCallback onTap;
  const _Toggle({required this.label, required this.on, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: on ? _gold.withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: on ? _gold.withValues(alpha: 0.4) : _cardBdr),
      ),
      child: Text(label, style: TextStyle(color: on ? const Color(0xFFD97706) : _text3, fontWeight: on ? FontWeight.w700 : FontWeight.w500, fontSize: 10)),
    ),
  );
}

// =============================================================================
//   LIGHT DIALOG
// =============================================================================
class _LightDialog extends StatelessWidget {
  final String title; final Widget content; final Future<void> Function() onSave;
  const _LightDialog({required this.title, required this.content, required this.onSave});
  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: _cardBdr)),
    title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16, color: _text1)),
    content: SizedBox(width: 420, child: SingleChildScrollView(child: content)),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Batal', style: GoogleFonts.outfit(color: _text2, fontWeight: FontWeight.w600)),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: _gold, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
        onPressed: () async {
          try { await onSave(); }
          catch (e) {
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal: $e'), backgroundColor: _rose, behavior: SnackBarBehavior.floating));
          }
        },
        child: Text('Simpan', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.black)),
      ),
    ],
  );
}

class _ConfirmDialog extends StatelessWidget {
  final String message;
  const _ConfirmDialog({required this.message});
  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: _cardBdr)),
    title: Text('Konfirmasi', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: _text1)),
    content: Text(message, style: GoogleFonts.outfit(color: _text2)),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal', style: GoogleFonts.outfit(color: _text2))),
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: _rose, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
        onPressed: () => Navigator.pop(context, true),
        child: Text('Hapus', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    ],
  );
}

class _LightTF extends StatelessWidget {
  final TextEditingController ctrl; final String label;
  final TextInputType kb; final bool hide;
  const _LightTF({required this.ctrl, required this.label, this.kb = TextInputType.text, this.hide = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: ctrl, keyboardType: kb, obscureText: hide,
      style: GoogleFonts.outfit(fontSize: 14, color: _text1),
      cursorColor: _gold,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: _text2, fontSize: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _gold, width: 1.5)),
        isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
    ),
  );
}

class _LightSwitch extends StatelessWidget {
  final String label; final bool value; final ValueChanged<bool> onChanged;
  const _LightSwitch({required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label, style: GoogleFonts.outfit(color: _text1, fontSize: 13)),
    value: value, activeColor: _gold, onChanged: onChanged,
  );
}

class _LightDrop2 extends StatelessWidget {
  final String value, label; final Map<String, String> items; final ValueChanged<String> onChanged;
  const _LightDrop2({required this.value, required this.label, required this.items, required this.onChanged});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: _text2, fontSize: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _gold, width: 1.5)),
        isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _gold),
      items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: GoogleFonts.outfit(fontSize: 13)))).toList(),
      onChanged: (v) { if (v != null) onChanged(v); },
    ),
  );
}
