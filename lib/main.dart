import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pocketbase/pocketbase.dart';
import 'core/theme/theme.dart';
import 'injection.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/meals/presentation/bloc/meals_bloc.dart';
import 'features/professional/presentation/bloc/professional_bloc.dart';
import 'features/home/presentation/bloc/weight_bloc.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/auth/presentation/pages/welcome_page.dart';
import 'features/auth/presentation/pages/complete_profile_page.dart';
import 'features/admin/presentation/pages/admin_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await di.init();

  runApp(const FitMotionApp());
}

class FitMotionApp extends StatelessWidget {
  const FitMotionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (_) => di.sl<MealsBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<ProfessionalBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<WeightBloc>(),
        ),
      ],
      child: const FitMotionAppView(),
    );
  }
}

class FitMotionAppView extends StatefulWidget {
  const FitMotionAppView({super.key});

  @override
  State<FitMotionAppView> createState() => _FitMotionAppViewState();
}

class _FitMotionAppViewState extends State<FitMotionAppView> with WidgetsBindingObserver {
  Timer? _heartbeatTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startHeartbeat();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sendHeartbeat();
      _startHeartbeat();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _heartbeatTimer?.cancel();
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _sendHeartbeat();
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _sendHeartbeat();
    });
  }

  void _sendHeartbeat() async {
    try {
      final pb = di.sl<PocketBase>();
      final userId = pb.authStore.model?.id;
      if (userId != null) {
        await pb.collection('users').update(userId, body: {});
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitMotion',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routes: {
        '/home': (context) => const HomePage(),
        '/complete-profile': (context) => const CompleteProfilePage(),
        '/admin': (context) => const AdminDashboardPage(),
      },
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            // Jika data fisik belum diisi, arahkan ke CompleteProfilePage
            final user = state.user;
            if (user != null && user.role == 'admin') {
              return const AdminDashboardPage();
            }
            if (user != null && (user.role == 'pro' || user.isTrainer || user.isGym)) {
              return const HomePage();
            }
            if (user != null && (user.age == 0 || user.height == 0)) {
              return const CompleteProfilePage();
            }
            return const HomePage();
          }
          return const WelcomePage();
        },
      ),
    );
  }
}
