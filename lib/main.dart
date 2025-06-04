import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/pages/auth/splash_page.dart';
import 'core/utils/database_debug_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Print database location for debugging (only in debug mode)
  assert(() {
    DatabaseDebugUtils.printDatabaseInfo();
    return true;
  }());
  
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Almacén',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
 