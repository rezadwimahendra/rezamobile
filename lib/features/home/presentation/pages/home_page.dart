import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'user_dashboard_page.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../../../injection.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Mendapatkan instance pb dari DI
        final pb = sl<PocketBase>();
        final user = pb.authStore.model;

        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Unauthorized')),
          );
        }

        final userName = user.getStringValue('name').isNotEmpty ? user.getStringValue('name') : 'Kawan';
        final userRole = user.getStringValue('role').isNotEmpty ? user.getStringValue('role') : 'users';

        return UserDashboardPage(userName: userName, userRole: userRole);
      },
    );
  }
}
