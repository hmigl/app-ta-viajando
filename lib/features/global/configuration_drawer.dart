import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ta_viajando_app/core/services/auth_provider.dart';
import 'package:ta_viajando_app/core/services/theme_provider.dart';
import 'package:ta_viajando_app/features/auth/data/profile_repository.dart'; 
import 'package:ta_viajando_app/features/global/friends_screen.dart';
import 'package:ta_viajando_app/features/global/profile_screen.dart';

class ConfigurationDrawer extends ConsumerWidget {
  const ConfigurationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Aqui o Menu fica "escutando" o perfil
    final profileAsync = ref.watch(userProfileProvider);

    return Drawer(
      child: Column(
        children: [
          // O Header agora é dinâmico
          profileAsync.when(
            data: (profile) => UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor == Colors.grey[900] 
                    ? Colors.grey[800] 
                    : Colors.blue.shade800,
              ),
              accountName: Text(profile.name.isNotEmpty ? profile.name : "Viajante"),
              accountEmail: Text(profile.email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: profile.avatarUrl != null 
                    ? NetworkImage(profile.avatarUrl!) 
                    : null,
                child: profile.avatarUrl == null 
                    ? Text(profile.name.isNotEmpty ? profile.name[0].toUpperCase() : "V", 
                           style: const TextStyle(fontSize: 24, color: Colors.grey))
                    : null,
              ),
            ),
            // Enquanto carrega (loading), mostra um skeleton ou dados vazios
            loading: () => const UserAccountsDrawerHeader(
              accountName: Text("Carregando..."),
              accountEmail: Text("..."),
              currentAccountPicture: CircleAvatar(child: CircularProgressIndicator()),
            ),
            // Se der erro
            error: (_, __) => const UserAccountsDrawerHeader(
              accountName: Text("Viajante"),
              accountEmail: Text("Erro ao carregar perfil"),
              currentAccountPicture: CircleAvatar(child: Icon(Icons.error)),
            ),
          ),
          
          // --- ITENS DO MENU (Mantém igual) ---
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Meu Perfil'),
            onTap: () {
              Navigator.pop(context); 
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Meus Amigos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FriendsScreen()));
            },
          ),
          const Divider(),

          ListTile(
            leading: ref.watch(appThemeProvider).when(
                  data: (isDark) => isDark ? const Icon(Icons.light_mode) : const Icon(Icons.dark_mode),
                  loading: () => const Icon(Icons.brightness_6),
                  error: (_, __) => const Icon(Icons.brightness_6),
                ),
            title: const Text('Alternar Tema'),
            onTap: () => ref.read(appThemeProvider.notifier).toggleTheme(),
          ),

          const Spacer(),
          
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () async {
               // Dica: Limpar o cache do perfil ao sair para não mostrar dados do usuário anterior num próximo login
               ref.invalidate(userProfileProvider);
               await ref.read(authProvider.notifier).signOut();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}