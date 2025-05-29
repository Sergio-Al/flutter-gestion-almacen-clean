import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_almacen_stock/presentation/pages/dashboard/dashboard_page.dart';
import 'package:gestion_almacen_stock/presentation/pages/products/create_product_page.dart';
import 'package:gestion_almacen_stock/presentation/pages/products/products_list_page.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Almacén',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardPage(),
        '/products': (context) => ProductsListPage(),  // Haremos este widget después
        '/products/create': (context) => CreateProductPage(),
      },
    );
  }
}
