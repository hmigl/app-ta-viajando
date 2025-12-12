import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_viajando_app/core/services/supabase_provider.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  UserProfile({required this.id, required this.name, required this.email, this.avatarUrl});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['full_name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar_url'],
    );
  }
}

final userProfileProvider = FutureProvider<UserProfile>((ref) {
  return ref.watch(profileRepositoryProvider).getMyProfile();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseProvider));
});

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository(this._supabase);

  // Pega o perfil atual
  Future<UserProfile> getMyProfile() async {
    final userId = _supabase.auth.currentUser!.id;
    final data = await _supabase.from('profiles').select().eq('id', userId).single();
    return UserProfile.fromJson(data);
  }

  // Atualiza Foto
  Future<String> uploadAvatar(Uint8List bytes) async {
    final userId = _supabase.auth.currentUser!.id;
    final path = '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    await _supabase.storage.from('avatars').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
    );
    
    return _supabase.storage.from('avatars').getPublicUrl(path);
  }

  // Atualiza Dados (Nome, Foto) e Auth (Email, Senha)
  Future<void> updateProfile({
    required String name,
    String? avatarUrl,
    String? newPassword,
    String? newEmail,
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    // 1. Atualiza dados públicos (tabela profiles)
    final updates = {
      'full_name': name,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
    await _supabase.from('profiles').update(updates).eq('id', userId);

    // 2. Atualiza dados sensíveis de Auth (se fornecidos)
    final UserAttributes attributes = UserAttributes(
      email: newEmail,
      password: newPassword,
    );

    if (newEmail != null || newPassword != null) {
      await _supabase.auth.updateUser(attributes);
    }
  }

  // Pega amigos (pessoas que estão nas mesmas viagens que eu)
  Future<List<UserProfile>> getFriends() async {
    final userId = _supabase.auth.currentUser!.id;
    
    // 1. Descobrir IDs das minhas viagens
    final myTrips = await _supabase.from('trip_participants')
        .select('trip_id')
        .eq('user_id', userId);
    
    final tripIds = (myTrips as List).map((e) => e['trip_id']).toList();

    if (tripIds.isEmpty) return [];

    // 2. Pegar perfis de quem está nessas viagens (excluindo eu mesmo)
    final response = await _supabase.from('trip_participants')
        .select('profiles(id, full_name, email, avatar_url)')
        .inFilter('trip_id', tripIds)
        .neq('user_id', userId); // Não quero eu mesmo na lista

    // Filtrar duplicados (mesmo amigo em várias viagens)
    final uniqueFriends = <String, UserProfile>{};
    for (var item in response) {
      final profileData = item['profiles'];
      if (profileData != null) {
        final profile = UserProfile.fromJson(profileData);
        uniqueFriends[profile.id] = profile;
      }
    }

    return uniqueFriends.values.toList();
  }
}