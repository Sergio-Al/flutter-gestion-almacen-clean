import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../auth/login_page.dart';
import 'widgets/stats_card_widget.dart';
import 'widgets/quick_actions_widget.dart';
import 'widgets/sales_chart_widget.dart';
import 'widgets/recent_activities_widget.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - Gestión de Almacén'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context, ref);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 8),
                    Text(currentUser?.name ?? 'Usuario'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
            icon: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Text(
                currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout based on screen width
          if (constraints.maxWidth > 1200) {
            return _buildDesktopLayout();
          } else if (constraints.maxWidth > 800) {
            return _buildTabletLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const StatsCardWidget(),
          const SizedBox(height: 20),
          const QuickActionsWidget(),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                const Expanded(
                  child: SalesChartWidget(),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: RecentActivitiesWidget(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const StatsCardWidget(),
          const SizedBox(height: 20),
          const QuickActionsWidget(),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                const Expanded(
                  child: SalesChartWidget(),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: RecentActivitiesWidget(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const StatsCardWidget(),
          const SizedBox(height: 20),
          const QuickActionsWidget(),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: const SalesChartWidget(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 400,
            child: const RecentActivitiesWidget(),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
