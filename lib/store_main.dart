import 'package:flutter/material.dart';
import 'catalog_store.dart';
import 'store/store_shell.dart';
import 'supabase_config.dart';
import 'theme.dart';

/// Separate entrypoint for the shop-side console. Built with:
///   flutter build web -t lib/store_main.dart
/// The customer app (lib/main.dart) is unaffected.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(const StoreApp());
  catalogStore.loadRemoteProducts();
}

class StoreApp extends StatelessWidget {
  const StoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Namma MahaRaja · Store Console',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: const StoreShell(),
    );
  }
}
