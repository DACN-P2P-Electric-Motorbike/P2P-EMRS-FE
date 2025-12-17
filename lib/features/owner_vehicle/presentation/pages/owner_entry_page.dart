import 'package:fe_capstone_project/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fe_capstone_project/features/auth/presentation/bloc/auth_state.dart';
import 'package:fe_capstone_project/features/owner_vehicle/presentation/pages/owner_dashboard_page.dart';
import 'package:fe_capstone_project/features/renter/presentation/pages/become_owner_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OwnerEntryPage extends StatelessWidget {
  const OwnerEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AuthAuthenticated) {
          final isOwner = state.user.isOwner || state.user.isAdmin;

          return isOwner ? const OwnerDashboardPage() : const BecomeOwnerPage();
        }

        return const Center(child: Text('Unauthorized'));
      },
    );
  }
}
