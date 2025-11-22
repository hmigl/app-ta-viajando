import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ta_viajando_app/core/services/auth_provider.dart';
import 'package:ta_viajando_app/core/services/theme_provider.dart';

class ConfigurationDrawer extends ConsumerWidget {
  const ConfigurationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        children: [
          SizedBox(
            height: 160,
            child: DrawerHeader(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: ref
                        .watch(appThemeProvider)
                        .when(
                          data: (isDarkMode) => isDarkMode
                              ? const Icon(Icons.dark_mode)
                              : const Icon(Icons.light_mode),
                          loading: () => const Icon(Icons.light_mode),
                          error: (_, __) => const Icon(Icons.light_mode),
                        ),
                    onPressed: () {
                      ref.read(appThemeProvider.notifier).toggleTheme();
                    },
                  ),
                  IconButton(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).signOut();
                    },
                    icon: Icon(Icons.logout),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
