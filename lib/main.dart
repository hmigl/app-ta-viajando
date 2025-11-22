import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ta_viajando_app/my_app.dart';
import 'core/services/supabase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const authenticationEnabled = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Function.apply(Supabase.initialize, [], supabaseOptions);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}



