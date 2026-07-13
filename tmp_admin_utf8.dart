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

  // Statistics from PocketBase
  int _totalUsers = 0;
  int _totalTrainers = 0;
  int _totalGyms = 0;
  int _totalFoods = 0;
  bool _isLoadingStats = true;
  String _userSearchQuery = '';
  String _userFilterRole = 'all'; // 'all', 'user', 'pro', 'admin', 'trainer', 'gym'

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final usersRes = await pb.collection('users').getFullList();
      final trainersRes = await pb.collection('trainers').getFullList();
      final gymsRes = await pb.collection('gyms').getFullList();
      final foodsRes = await pb.collection('foods').getFullList();

      if (mounted) {
        setState(() {
          _totalUsers = usersRes.length;
          _totalTrainers = trainersRes.length;
          _totalGyms = gymsRes.length;
          _totalFoods = foodsRes.length;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Row(
        children: [
          // SIDEBAR / NAVIGATION
          _buildSidebar(context),

          // MAIN HEADER & SCROLLABLE CONTENT AREA
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: _buildSelectedContent(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Color(0xFF101010),
        border: Border(bottom: BorderSide(color: Color(0xFF202020), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedIndex == 0
                ? 'Welcome back, Admin!'
                : _selectedIndex == 1
                    ? 'Manajemen Pengguna'
                    : _selectedIndex == 2
                        ? 'Verifikasi Mitra / Professional'
                        : 'Manajemen Data Makanan',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: _loadStats,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Refresh Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C1C1E),
              foregroundColor: const Color(0xFFC5FE1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF333333)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFF101010),
      child: Column(
        children: [
          // Corporate Logo & Header
          Container(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC5FE1E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.bolt,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fitmotion',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'PORTAL ADMIN',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC5FE1E),
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF202020), height: 1),
          const SizedBox(height: 20),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                _buildSidebarItem(0, Icons.dashboard_outlined, 'Ringkasan'),
                _buildSidebarItem(1, Icons.people_outline, 'Manajemen User'),
                _buildSidebarItem(2, Icons.verified_outlined, 'Verifikasi Mitra'),
                _buildSidebarItem(3, Icons.restaurant_menu_outlined, 'Data Makanan'),
              ],
            ),
          ),

          // Log Out
          const Divider(color: Color(0xFF202020), height: 1),
          _buildLogoutButton(context),
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
                ? const Color(0xFF1E1E1E)
                : isHovered
                    ? const Color(0xFF181818)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFC5FE1E).withOpacity(0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: ListTile(
            onTap: () => setState(() => _selectedIndex = index),
            leading: Icon(
              icon,
              color: isSelected
                  ? const Color(0xFFC5FE1E)
                  : isHovered
                      ? Colors.white
                      : const Color(0xFF8E8E93),
            ),
            title: Text(
              title,
              style: GoogleFonts.outfit(
                color: isSelected
                    ? const Color(0xFFC5FE1E)
                    : isHovered
                        ? Colors.white
                        : const Color(0xFF8E8E93),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return HoverEffectWidget(
      builder: (isHovered) {
        return Container(
          margin: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isHovered ? const Color(0xFF2C1414) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            onTap: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
            leading: Icon(
              Icons.logout,
              color: isHovered ? Colors.redAccent : const Color(0xFF8E8E93),
            ),
            title: Text(
              'Keluar Admin',
              style: GoogleFonts.outfit(
                color: isHovered ? Colors.redAccent : const Color(0xFF8E8E93),
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
        return const Center(child: Text('Fitur Under Construction'));
    }
  }

  // --- 1. OVERVIEW LANDING DESIGN (MATCHES THE PROVIDED IMAGE) ---
  Widget _buildOverviewLanding() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ================= HERO BANNER =================
        Container(
          height: 380,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: const DecorationImage(
              image: NetworkImage(
                  'https://images.unsplash.com/photo-1594381898411-846e7d193883?q=80&w=1500&auto=format&fit=crop'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Dark Overlay Gradient
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.95),
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Title Text
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'DISCOVER THE STRONGER YOU',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFC5FE1E),
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'TRAIN HARD\nLIVE STRONG',
                            style: GoogleFonts.outfit(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'We help you build strength, boost confidence and achieve your fitness goals with expert guidance and support.',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: const Color(0xFFB0B0B0),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              HoverEffectWidget(
                                builder: (isHovered) => AnimatedScale(
                                  scale: isHovered ? 1.05 : 1.0,
                                  duration: const Duration(milliseconds: 150),
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFC5FE1E),
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 18),
                                    ),
                                    child: Row(
                                      children: [
                                        Text('Explore Programs',
                                            style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward,
                                            size: 16, color: Colors.black),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              HoverEffectWidget(
                                builder: (isHovered) => TextButton.icon(
                                  onPressed: () {},
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white),
                                    ),
                                    child: const Icon(Icons.play_arrow,
                                        color: Colors.white, size: 14),
                                  ),
                                  label: Text(
                                    'Watch Video',
                                    style: GoogleFonts.outfit(
                                      color: isHovered
                                          ? const Color(0xFFC5FE1E)
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Floating stats on the right of banner
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildOverlayStatTag(
                              '${_isLoadingStats ? "..." : _totalUsers}+', 'Users Registered'),
                          const SizedBox(height: 12),
                          _buildOverlayStatTag(
                              '${_isLoadingStats ? "..." : _totalTrainers}+', 'Active Trainers'),
                          const SizedBox(height: 12),
                          _buildOverlayStatTag(
                              '${_isLoadingStats ? "..." : _totalGyms}+', 'Mitra Gym & Venues'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // ================= ROW OF FEATURES =================
        GridView.count(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.2,
          children: [
            _buildFeatureCard(Icons.fitness_center_outlined, 'Modern Equipment',
                'Train with state-of-the-art equipment in a premium environment.'),
            _buildFeatureCard(Icons.support_agent_outlined, 'Expert Trainers',
                'Certified trainers to guide you every step of the way.'),
            _buildFeatureCard(Icons.checklist_rtl_outlined, 'Personalized Plans',
                'Customized workout & nutrition plans tailored just for you.'),
            _buildFeatureCard(Icons.favorite_border_outlined, 'Results That Last',
                'We focus on sustainable results and a healthier lifestyle.'),
          ],
        ),

        const SizedBox(height: 48),

        // ================= SECTION: OUR PROGRAMS =================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OUR PROGRAMS',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFC5FE1E),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'Find The Right Program For You',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: Row(
                children: [
                  Text('View All Programs',
                      style: GoogleFonts.outfit(
                          color: const Color(0xFFC5FE1E),
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward,
                      size: 14, color: Color(0xFFC5FE1E)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.72,
          children: [
            _buildProgramCard(
              'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=600&auto=format&fit=crop',
              'Strength Training',
              'Build muscle, increase strength and improve performance.',
              Icons.bolt,
            ),
            _buildProgramCard(
              'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=600&auto=format&fit=crop',
              'Yoga & Flexibility',
              'Improve flexibility, balance and mental well-being with expert-led yoga.',
              Icons.self_improvement,
            ),
            _buildProgramCard(
              'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=600&auto=format&fit=crop',
              'Cardio & HIIT',
              'Burn calories, boost endurance and improve your cardiovascular health.',
              Icons.directions_run,
            ),
            _buildProgramCard(
              'https://images.unsplash.com/photo-1490645935967-10de6ba17061?q=80&w=600&auto=format&fit=crop',
              'Nutrition Coaching',
              'Get personalized nutrition plans to fuel your body and goals.',
              Icons.eco,
            ),
          ],
        ),

        const SizedBox(height: 48),

        // ================= BANNER CARD: YOUR ONLY LIMIT IS YOU =================
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: NetworkImage(
                  'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=1000&auto=format&fit=crop'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.85),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'BE YOUR BEST',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFC5FE1E),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Your Only Limit Is You',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We believe fitness is not just about the body, it\'s about the mind, attitude and lifestyle.',
                          style: GoogleFonts.outfit(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC5FE1E),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                      ),
                      child: Text(
                        'Start Your Journey ->',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        // ================= SECTION: IMPACT NUMBERS & TESTIMONIALS =================
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: IMPACT IN NUMBERS
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OUR IMPACT IN NUMBERS',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFC5FE1E),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.8,
                    children: [
                      _buildNumberCard('10K+', 'Members Joined', Icons.people_alt_outlined),
                      _buildNumberCard('150+', 'Fitness Programs', Icons.emoji_events_outlined),
                      _buildNumberCard('98%', 'Member Satisfaction', Icons.thumb_up_alt_outlined),
                      _buildNumberCard('500K+', 'Workouts Completed', Icons.fitness_center),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            // Right Column: TESTIMONIALS
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'WHAT OUR MEMBERS SAY',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFC5FE1E),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'View All Reviews ->',
                        style: GoogleFonts.outfit(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTestimonialCard(
                    'Sarah Johnson',
                    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=100&auto=format&fit=crop',
                    'Strive Fitness changed my life! The trainers are amazing and the environment keeps me motivated every day.',
                  ),
                  const SizedBox(height: 12),
                  _buildTestimonialCard(
                    'Michael Brown',
                    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=100&auto=format&fit=crop',
                    'The personalized plan and nutrition coaching helped me achieve results I never thought possible.',
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 48),

        // ================= SECTION: BLOG INSIGHTS =================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FROM OUR BLOG',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFC5FE1E),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'Latest Fitness Tips & Insights',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: Row(
                children: [
                  Text('View All Articles',
                      style: GoogleFonts.outfit(
                          color: const Color(0xFFC5FE1E),
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward,
                      size: 14, color: Color(0xFFC5FE1E)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: [
            _buildBlogCard(
              'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=500&auto=format&fit=crop',
              'May 12, 2026 • Nutrition',
              '10 Superfoods to Fuel Your Workouts',
            ),
            _buildBlogCard(
              'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=500&auto=format&fit=crop',
              'May 08, 2026 • Workouts',
              'How to Build Strength Effectively',
            ),
            _buildBlogCard(
              'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=500&auto=format&fit=crop',
              'May 01, 2026 • Wellness',
              'The Power of Mindset in Fitness',
            ),
          ],
        ),

        const SizedBox(height: 48),

        // ================= SECTION: NEWSLETTER SUBSCRIBE =================
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          decoration: BoxDecoration(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF202020)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC5FE1E).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mail_outline,
                        color: Color(0xFFC5FE1E), size: 28),
                  ),
                  const SizedBox(width: 18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stay Motivated. Stay Updated.',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Subscribe to get the latest tips, offers and fitness updates.',
                        style: GoogleFonts.outfit(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 250,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0xFF2C2C2E)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC5FE1E),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                    ),
                    child: Text(
                      'Subscribe',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 64),

        // ================= FOOTER =================
        Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFF202020))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC5FE1E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.bolt,
                              color: Colors.black, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'STRIVE FITNESS',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Empowering you to build a stronger body, healthier mind, and better life.',
                      style: GoogleFonts.outfit(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: _buildFooterSection('QUICK LINKS', ['Home', 'About Us', 'Programs', 'Trainer', 'Pricing']),
              ),
              Expanded(
                flex: 2,
                child: _buildFooterSection('PROGRAMS', ['Strength Training', 'Yoga & Flexibility', 'Cardio & HIIT', 'Nutrition Coaching']),
              ),
              Expanded(
                flex: 2,
                child: _buildFooterSection('CONTACT US', ['123 Fitness Street', 'New York, NY 10001', '+1 (212) 555-7890', 'info@strivefitness.com']),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayStatTag(String number, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            number,
            style: GoogleFonts.outfit(
              color: const Color(0xFFC5FE1E),
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String desc) {
    return HoverEffectWidget(
      builder: (isHovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: const Color(0xFF101010),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHovered
                ? const Color(0xFFC5FE1E).withOpacity(0.5)
                : const Color(0xFF202020),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isHovered
                    ? const Color(0xFFC5FE1E)
                    : const Color(0xFF1E1E1E),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isHovered ? Colors.black : const Color(0xFFC5FE1E),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: GoogleFonts.outfit(
                      color: Colors.grey,
                      fontSize: 11,
                      height: 1.3,
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

  Widget _buildProgramCard(
      String imageUrl, String label, String desc, IconData icon) {
    return HoverEffectWidget(
      builder: (isHovered) => AnimatedScale(
        scale: isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isHovered ? const Color(0xFFC5FE1E) : const Color(0xFF202020)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(imageUrl, fit: BoxFit.cover),
                      Container(
                        color: Colors.black.withOpacity(0.2),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFC5FE1E),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: Colors.black, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.outfit(
                        color: isHovered ? const Color(0xFFC5FE1E) : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      desc,
                      style: GoogleFonts.outfit(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text('Learn More',
                            style: GoogleFonts.outfit(
                              color: isHovered ? const Color(0xFFC5FE1E) : Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            )),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_outlined,
                          size: 12,
                          color: isHovered ? const Color(0xFFC5FE1E) : Colors.white70,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberCard(String stat, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF202020)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stat,
                style: GoogleFonts.outfit(
                  color: const Color(0xFFC5FE1E),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Icon(icon, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(String name, String avatarUrl, String review) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF202020)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
                5, (index) => const Icon(Icons.star, color: Colors.amber, size: 16)),
          ),
          const SizedBox(height: 12),
          Text(
            '"$review"',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 13,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(avatarUrl),
                radius: 16,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Member',
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlogCard(String imageUrl, String date, String title) {
    return HoverEffectWidget(
      builder: (isHovered) => AnimatedScale(
        scale: isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered
                  ? const Color(0xFFC5FE1E).withOpacity(0.5)
                  : const Color(0xFF202020),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: GoogleFonts.outfit(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: isHovered ? const Color(0xFFC5FE1E) : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text('Read More',
                            style: GoogleFonts.outfit(
                                color: const Color(0xFFC5FE1E),
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward,
                            size: 12, color: Color(0xFFC5FE1E)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterSection(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 14),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                link,
                style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
              ),
            )),
      ],
    );
  }

  // --- 2. USER MANAGEMENT CONTENT ---
  Widget _buildUserManagementContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TITLE AND ADD USER BUTTON
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Pengguna Terdaftar (${_isLoadingStats ? "..." : _totalUsers})',
              style: GoogleFonts.outfit(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _showAddUserDialog,
              icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
              label: const Text('Tambah User Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC5FE1E),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // SEARCH AND FILTER ROW
        Row(
          children: [
            // Search Input
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF101010),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF202020)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        onChanged: (val) {
                          setState(() {
                            _userSearchQuery = val.toLowerCase();
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Cari Nama atau Email...',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
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
            // Filter Dropdown
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF101010),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF202020)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _userFilterRole,
                  dropdownColor: const Color(0xFF101010),
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                  icon: const Icon(Icons.filter_list, color: Color(0xFFC5FE1E)),
                  onChanged: (String? newVal) {
                    if (newVal != null) {
                      setState(() {
                        _userFilterRole = newVal;
                      });
                    }
                  },
                  items: [
                    DropdownMenuItem(value: 'all', child: Text('Tampilkan Semua', style: GoogleFonts.outfit())),
                    DropdownMenuItem(value: 'user', child: Text('User Biasa', style: GoogleFonts.outfit())),
                    DropdownMenuItem(value: 'pro', child: Text('User Premium (Pro)', style: GoogleFonts.outfit())),
                    DropdownMenuItem(value: 'admin', child: Text('Admin', style: GoogleFonts.outfit())),
                    DropdownMenuItem(value: 'trainer', child: Text('Trainer Only', style: GoogleFonts.outfit())),
                    DropdownMenuItem(value: 'gym', child: Text('Gym Mitra Only', style: GoogleFonts.outfit())),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // DATATABLE CONTAINER
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF202020)),
          ),
          child: FutureBuilder<List<RecordModel>>(
            future: pb.collection('users').getFullList(sort: '-created'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFFC5FE1E))),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text('Tidak ada pengguna terdaftar',
                        style: GoogleFonts.outfit(color: Colors.grey)),
                  ),
                );
              }

              // Filter in memory for instantaneous search/filter feel
              final allUsers = snapshot.data!;
              final filteredUsers = allUsers.where((u) {
                final name = u.getStringValue('name').toLowerCase();
                final email = u.getStringValue('email').toLowerCase();
                final matchesSearch = name.contains(_userSearchQuery) || email.contains(_userSearchQuery);

                if (!matchesSearch) return false;

                final role = u.getStringValue('role');
                final isTrainer = u.data['is_trainer'] == true;
                final isGym = u.data['is_gym'] == true;

                switch (_userFilterRole) {
                  case 'user':
                    return role == 'user' && !isTrainer && !isGym;
                  case 'pro':
                    return role == 'pro';
                  case 'admin':
                    return role == 'admin';
                  case 'trainer':
                    return isTrainer;
                  case 'gym':
                    return isGym;
                  case 'all':
                  default:
                    return true;
                }
              }).toList();

              if (filteredUsers.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text('Tidak ada pengguna yang cocok dengan kriteria',
                        style: GoogleFonts.outfit(color: Colors.grey)),
                  ),
                );
              }

              return DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFF181818)),
                columns: [
                  DataColumn(
                      label: Text('Nama / Email',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                  DataColumn(
                      label: Text('Tipe User',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                  DataColumn(
                      label: Text('Role Utama',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                  DataColumn(
                      label: Text('Status Mitra',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                  DataColumn(
                      label: Text('Aksi',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                ],
                rows: filteredUsers.map((u) {
                  final isTrainer = u.data['is_trainer'] == true;
                  final isGym = u.data['is_gym'] == true;
                  final role = u.getStringValue('role'); // user, pro, admin

                  // Premium Tag rendering
                  final isPremium = (role == 'pro');

                  return DataRow(
                    cells: [
                      // NAMA & EMAIL
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(u.getStringValue('name'),
                                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(u.getStringValue('email'),
                                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                      // TIPE USER
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPremium
                                ? const Color(0xFFFFD700).withOpacity(0.1) // Golden glow
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isPremium
                                  ? const Color(0xFFFFD700).withOpacity(0.3)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            isPremium ? 'PREMIUM (PRO)' : 'BIASA (FREE)',
                            style: GoogleFonts.outfit(
                              color: isPremium
                                  ? const Color(0xFFFFD700)
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      // ROLE UTAMA
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: role == 'admin'
                                ? Colors.redAccent.withOpacity(0.1)
                                : const Color(0xFFC5FE1E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            role.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: role == 'admin' ? Colors.redAccent : const Color(0xFFC5FE1E),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      // STATUS MITRA
                      DataCell(
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('Trainer', style: TextStyle(fontSize: 11)),
                              selected: isTrainer,
                              selectedColor: const Color(0xFFC5FE1E),
                              onSelected: (val) async {
                                await pb.collection('users').update(u.id, body: {'is_trainer': val});
                                _loadStats();
                              },
                            ),
                            const SizedBox(width: 6),
                            ChoiceChip(
                              label: const Text('Mitra Gym', style: TextStyle(fontSize: 11)),
                              selected: isGym,
                              selectedColor: const Color(0xFFC5FE1E),
                              onSelected: (val) async {
                                await pb.collection('users').update(u.id, body: {'is_gym': val});
                                _loadStats();
                              },
                            ),
                          ],
                        ),
                      ),
                      // ACTION CRUD WIDGETS
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 20),
                              onPressed: () => _showEditUserDialog(u),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: const Color(0xFF1E1E1E),
                                    title: const Text('Hapus Pengguna?',
                                        style: TextStyle(color: Colors.white)),
                                    content: Text(
                                        'Yakin ingin menghapus ${u.getStringValue('name')}?',
                                        style: const TextStyle(color: Colors.grey)),
                                    actions: [
                                      TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text('Batal')),
                                      TextButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text('Hapus',
                                              style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await pb.collection('users').delete(u.id);
                                  _loadStats();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
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
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Tambah Pengguna Baru',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  dropdownColor: const Color(0xFF1A1A1A),
                  decoration: const InputDecoration(
                    labelText: 'Role Utama / Tipe User',
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('User Biasa (Free)')),
                    DropdownMenuItem(value: 'pro', child: Text('User Premium (Pro)')),
                    DropdownMenuItem(value: 'admin', child: Text('Administrator')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedRole = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Status Trainer', style: TextStyle(color: Colors.white, fontSize: 14)),
                  value: isTrainer,
                  activeColor: const Color(0xFFC5FE1E),
                  onChanged: (val) {
                    setDialogState(() {
                      isTrainer = val;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Status Mitra Gym', style: TextStyle(color: Colors.white, fontSize: 14)),
                  value: isGym,
                  activeColor: const Color(0xFFC5FE1E),
                  onChanged: (val) {
                    setDialogState(() {
                      isGym = val;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            minimizedDialogButton(
              'Batal',
              () => Navigator.pop(ctx),
              Colors.grey,
            ),
            minimizedDialogButton(
              'Simpan',
              () async {
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
                      'verified': true, // Auto verify when admin creates them
                    });
                    Navigator.pop(ctx);
                    _loadStats();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pengguna baru berhasil dibuat')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal membuat pengguna: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Semua field wajib diisi')),
                  );
                }
              },
              const Color(0xFFC5FE1E),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(RecordModel u) {
    final nameCtrl = TextEditingController(text: u.getStringValue('name'));
    final emailCtrl = TextEditingController(text: u.getStringValue('email'));
    final passwordCtrl = TextEditingController(); // Empty to keep same
    String selectedRole = u.getStringValue('role');
    if (selectedRole != 'user' && selectedRole != 'pro' && selectedRole != 'admin') {
      selectedRole = 'user';
    }
    bool isTrainer = u.data['is_trainer'] == true;
    bool isGym = u.data['is_gym'] == true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Pengguna',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Password Baru (Kosongkan jika tak diubah)',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  dropdownColor: const Color(0xFF1A1A1A),
                  decoration: const InputDecoration(
                    labelText: 'Role Utama / Tipe User',
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('User Biasa (Free)')),
                    DropdownMenuItem(value: 'pro', child: Text('User Premium (Pro)')),
                    DropdownMenuItem(value: 'admin', child: Text('Administrator')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedRole = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Status Trainer', style: TextStyle(color: Colors.white, fontSize: 14)),
                  value: isTrainer,
                  activeColor: const Color(0xFFC5FE1E),
                  onChanged: (val) {
                    setDialogState(() {
                      isTrainer = val;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Status Mitra Gym', style: TextStyle(color: Colors.white, fontSize: 14)),
                  value: isGym,
                  activeColor: const Color(0xFFC5FE1E),
                  onChanged: (val) {
                    setDialogState(() {
                      isGym = val;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            minimizedDialogButton(
              'Batal',
              () => Navigator.pop(ctx),
              Colors.grey,
            ),
            minimizedDialogButton(
              'Simpan',
              () async {
                if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
                  try {
                    final Map<String, dynamic> updateData = {
                      'name': nameCtrl.text,
                      'email': emailCtrl.text,
                      'role': selectedRole,
                      'is_trainer': isTrainer,
                      'is_gym': isGym,
                    };
                    if (passwordCtrl.text.isNotEmpty) {
                      updateData['password'] = passwordCtrl.text;
                      updateData['passwordConfirm'] = passwordCtrl.text;
                    }
                    await pb.collection('users').update(u.id, body: updateData);
                    Navigator.pop(ctx);
                    _loadStats();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pengguna berhasil diperbarui')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal memperbarui pengguna: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama dan Email wajib diisi')),
                  );
                }
              },
              const Color(0xFFC5FE1E),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. MITRA/PROFESSIONAL VERIFICATION CONTENT ---
  Widget _buildMitraVerificationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Verifikasi & Permohonan Mitra',
          style: GoogleFonts.outfit(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMitraListCard('Trainers', 'trainers'),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildMitraListCard('Gym Mitra / Venues', 'gyms'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMitraListCard(String title, String collectionName) {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF202020)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: const Color(0xFFC5FE1E),
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<RecordModel>>(
              future: pb.collection(collectionName).getFullList(sort: '-created'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Color(0xFFC5FE1E)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('Belum ada data',
                          style: GoogleFonts.outfit(color: Colors.grey)));
                }
                final list = snapshot.data!;
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (ctx, index) {
                    final item = list[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified, color: Colors.blueAccent, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.getStringValue('name'),
                                    style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                Text(item.getStringValue('specialty').isNotEmpty
                                    ? item.getStringValue('specialty')
                                    : 'Lokasi: ${item.getStringValue('location')}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(
                                        color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent, size: 18),
                            onPressed: () async {
                              await pb.collection(collectionName).delete(item.id);
                              setState(() {});
                            },
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

  // --- 4. FOOD DATABASE MANAGEMENT CONTENT ---
  Widget _buildFoodsManagementContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Database Makanan Utama',
              style: GoogleFonts.outfit(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _showAddFoodDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Tambah Makanan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC5FE1E),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF202020)),
          ),
          child: FutureBuilder<List<RecordModel>>(
            future: pb.collection('foods').getFullList(sort: '-created'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                      child: CircularProgressIndicator(color: Color(0xFFC5FE1E))),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                      child: Text('Belum ada data makanan. Klik Tambah Makanan.',
                          style: GoogleFonts.outfit(color: Colors.grey))),
                );
              }
              final foods = snapshot.data!;
              return DataTable(
                headingRowColor:
                    WidgetStateProperty.all(const Color(0xFF181818)),
                columns: [
                  DataColumn(
                      label: Text('Nama Makanan',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                  DataColumn(
                      label: Text('Kalori (kcal)',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                  DataColumn(
                      label: Text('Protein (g)',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                  DataColumn(
                      label: Text('Karbohidrat (g)',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                  DataColumn(
                      label: Text('Lemak (g)',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                  DataColumn(
                      label: Text('Aksi',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                ],
                rows: foods.map((f) {
                  return DataRow(
                    cells: [
                      DataCell(Text(f.getStringValue('name'),
                          style: GoogleFonts.outfit(color: Colors.white70))),
                      DataCell(Text('${f.getIntValue('calories')}',
                          style: GoogleFonts.outfit(color: Colors.white70))),
                      DataCell(Text('${f.getIntValue('protein')}',
                          style: GoogleFonts.outfit(color: Colors.white70))),
                      DataCell(Text('${f.getIntValue('carbs')}',
                          style: GoogleFonts.outfit(color: Colors.white70))),
                      DataCell(Text('${f.getIntValue('fat')}',
                          style: GoogleFonts.outfit(color: Colors.white70))),
                      DataCell(IconButton(
                        icon: const Icon(Icons.delete_forever,
                            color: Colors.redAccent, size: 20),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF1E1E1E),
                              title: const Text('Hapus Makanan?',
                                  style: TextStyle(color: Colors.white)),
                              content: Text(
                                  'Yakin ingin menghapus ${f.getStringValue('name')}?',
                                  style: const TextStyle(color: Colors.grey)),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Batal')),
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Hapus',
                                        style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await pb.collection('foods').delete(f.id);
                            _loadStats();
                          }
                        },
                      )),
                    ],
                  );
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
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Tambah Makanan Baru',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nama Makanan',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: calCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Kalori (kcal)',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: protCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Protein (g)',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: carbCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Karbohidrat (g)',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: fatCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Lemak (g)',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
          ],
        ),
        actions: [
          minimizedDialogButton(
            'Batal',
            () => Navigator.pop(ctx),
            Colors.grey,
          ),
          minimizedDialogButton(
            'Simpan',
            () async {
              if (nameCtrl.text.isNotEmpty && calCtrl.text.isNotEmpty) {
                await pb.collection('foods').create(body: {
                  'name': nameCtrl.text,
                  'calories': int.tryParse(calCtrl.text) ?? 0,
                  'protein': int.tryParse(protCtrl.text) ?? 0,
                  'carbs': int.tryParse(carbCtrl.text) ?? 0,
                  'fat': int.tryParse(fatCtrl.text) ?? 0,
                });
                Navigator.pop(ctx);
                _loadStats();
              }
            },
            const Color(0xFFC5FE1E),
          ),
        ],
      ),
    );
  }

  Widget minimizedDialogButton(String text, VoidCallback onPressed, Color color) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold),
      ),
    );
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
