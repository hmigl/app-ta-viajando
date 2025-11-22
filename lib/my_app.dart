import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ta_viajando_app/core/services/theme_provider.dart';
import 'package:ta_viajando_app/features/auth/authentication_wrapper.dart';
import 'package:ta_viajando_app/features/home/home_view.dart';

const authenticationEnabled = true;

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        brightness: Brightness.light,
        primaryColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
            systemNavigationBarDividerColor: Colors.transparent,
          ),
        ),
        drawerTheme: const DrawerThemeData(backgroundColor: Colors.white),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        primaryColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.grey[900],
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarDividerColor: Colors.transparent,
          ),
        ),
        cardTheme: CardThemeData(color: Colors.grey[900]),
        drawerTheme: DrawerThemeData(backgroundColor: Colors.grey[900]),
      ),
      themeMode: ref
          .watch(appThemeProvider)
          .when(
            data: (isDarkMode) => isDarkMode ? ThemeMode.dark : ThemeMode.light,
            loading: () => ThemeMode.system,
            error: (error, stackTrace) {
              return ThemeMode.system;
            },
          ),
      home: authenticationEnabled ? AuthenticationWrapper() : HomeView(),
    );
  }
}
