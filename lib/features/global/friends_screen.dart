import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ta_viajando_app/features/auth/data/profile_repository.dart';

final friendsProvider = FutureProvider<List<UserProfile>>((ref) {
  return ref.watch(profileRepositoryProvider).getFriends();
});

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Amigos de Viagem')),
      body: friendsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
        data: (friends) {
          if (friends.isEmpty) {
            return const Center(child: Text('Você ainda não tem conexões de viagem.'));
          }
          return ListView.builder(
            itemCount: friends.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final friend = friends[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: friend.avatarUrl != null ? NetworkImage(friend.avatarUrl!) : null,
                    child: friend.avatarUrl == null ? Text(friend.name[0].toUpperCase()) : null,
                  ),
                  title: Text(friend.name),
                  subtitle: Text(friend.email),
                ),
              );
            },
          );
        },
      ),
    );
  }
}