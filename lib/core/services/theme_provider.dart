import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

@riverpod
class AppTheme extends _$AppTheme {
  @override
  FutureOr<bool> build() async {
    try{
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isDarkMode') ?? false;
    }catch(e){
      return false;
    }

  }

  Future<void> toggleTheme() async {
    state = AsyncValue.data(!state.requireValue);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', state.requireValue);
  }
}

