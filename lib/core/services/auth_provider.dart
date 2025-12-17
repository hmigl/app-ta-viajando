import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

part 'auth_provider.g.dart';

@riverpod
Stream<AuthState> authState(Ref ref) {
  final supabase = Supabase.instance.client;
  return supabase.auth.onAuthStateChange;
}

@riverpod
class Auth extends _$Auth {
  @override
  FutureOr<void> build() {}

  Future<void> signInWithGoogle() async {
    try {
      // Definimos a URL de retorno explicitamente
      final redirectUrl = kIsWeb 
          ? 'http://localhost:3000/' 
          : 'io.supabase.flutter://callback'; // (Opcional para mobile depois)

      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl, // <--- FORÇAMOS AQUI
      );
    } catch (e) {
      debugPrint('Error signing in with Google (Supabase): $e');
      rethrow;
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Error signing in with email and password: $e');
      rethrow;
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password, String fullName) async {
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
    } catch (e) {
      debugPrint('Error signing up: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
}