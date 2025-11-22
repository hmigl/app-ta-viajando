import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_viajando_app/core/services/auth_provider.dart';
import 'package:ta_viajando_app/features/auth/authentication_view.dart';
import 'package:ta_viajando_app/features/home/home_view.dart';

class AuthenticationWrapper extends ConsumerWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      data: (AuthState state) {
        return state.session == null ? const AuthenticationView() : const HomeView();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, __) {
        return Scaffold(body: Center(child: Text('Error: $error')));
      },
    );
  }
}