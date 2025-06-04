import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/report_filter_widget.dart';
import 'widgets/revenue_chart_canvas.dart';
import 'widgets/kpi_card_widget.dart';

class SalesReportsPage extends ConsumerStatefulWidget {
  const SalesReportsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SalesReportsPage> createState() => _SalesReportsPageState();
}

class _SalesReportsPageState extends ConsumerState<SalesReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  String _selectedCategory = 'all';
  late ReportFilterOptions _filterOptions;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _filterOptions = ReportFilterOptions(
      startDate: _selectedDateRange.start,
      endDate: _selectedDateRange.end,
      selectedCategories: _selectedCategory == 'all' ? <String>{} : {_selectedCategory},
      selectedWarehouses: <String>{},
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de Ventas'),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        actions: [
          IconButton(
            onPressed: _exportReport,
            icon: const Icon(Icons.file_download),
            tooltip: 'Exportar Reporte',
          ),
          IconButton(
            onPressed: _shareReport,
            icon: const Icon(Icons.share),
            tooltip: 'Compartir Reporte',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Resumen Ejecutivo',
            ),
            Tab(
              icon: Icon(Icons.trending_up),
              text: 'Tendencias',
            ),
            Tab(
              icon: Icon(Icons.category),
              text: 'Por Categoría',
            ),
            Tab(
              icon: Icon(Icons.person),
              text: 'Por Cliente',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filters
          ReportFilterWidget(
            options: _filterOptions,
            onFilterChanged: (newOptions) {
              setState(() {
                _filterOptions = newOptions;
                _selectedDateRange = DateTimeRange(
                  start: newOptions.startDate,
                  end: newOptions.endDate,
                );
              });
            },
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildExecutiveSummaryTab(),
                _buildTrendsTab(),
                _buildCategoryTab(),
                _buildCustomerTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics
          _buildSectionTitle('Métricas Clave'),
          const SizedBox(height: 16),
          _buildKeyMetricsGrid(),
          const SizedBox(height: 24),

          // Revenue Chart
          _buildSectionTitle('Evolución de Ingresos'),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),            child: RevenueChartCanvas(
              data: _getSampleRevenueData(),
            ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Performance Summary
          _buildSectionTitle('Resumen de Rendimiento'),
          const SizedBox(height: 16),
          _buildPerformanceSummary(),
          const SizedBox(height: 24),

          // Top Products
          _buildSectionTitle('Productos Más Vendidos'),
          const SizedBox(height: 16),
          _buildTopProductsList(),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trend Indicators
          _buildSectionTitle('Indicadores de Tendencia'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: KpiCardWidget(
                  title: 'Crecimiento Mensual',
                  value: '+12.5%',
                  subtitle: 'vs. mes anterior',
                  trendValue: 3.2,
                  isPositiveTrend: true,
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KpiCardWidget(
                  title: 'Estacionalidad',
                  value: 'Alta',
                  subtitle: 'patrón detectado',
                  trendValue: 0,
                  isPositiveTrend: true,
                  icon: Icons.wb_sunny,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Detailed Trends Chart
          _buildSectionTitle('Análisis de Tendencias'),
          const SizedBox(height: 16),
          SizedBox(
            height: 400,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: RevenueChartCanvas(
                  data: _getSampleRevenueData(),
                  title: 'Análisis de Tendencias',
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Seasonal Analysis
          _buildSectionTitle('Análisis Estacional'),
          const SizedBox(height: 16),
          _buildSeasonalAnalysis(),
        ],
      ),
    );
  }

  Widget _buildCategoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Performance
          _buildSectionTitle('Rendimiento por Categoría'),
          const SizedBox(height: 16),
          _buildCategoryPerformanceList(),
          const SizedBox(height: 24),

          // Category Distribution Chart
          _buildSectionTitle('Distribución de Ventas'),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildCategoryDistributionChart(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Growth by Category
          _buildSectionTitle('Crecimiento por Categoría'),
          const SizedBox(height: 16),
          _buildCategoryGrowthChart(),
        ],
      ),
    );
  }

  Widget _buildCustomerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Metrics
          _buildSectionTitle('Métricas de Clientes'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: KpiCardWidget(
                  title: 'Clientes Activos',
                  value: '1,247',
                  subtitle: 'clientes este mes',
                  trendValue: 8.3,
                  isPositiveTrend: true,
                  icon: Icons.people,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KpiCardWidget(
                  title: 'Clientes Nuevos',
                  value: '89',
                  subtitle: 'registros nuevos',
                  trendValue: 15.7,
                  isPositiveTrend: true,
                  icon: Icons.person_add,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Top Customers
          _buildSectionTitle('Principales Clientes'),
          const SizedBox(height: 16),
          _buildTopCustomersList(),
          const SizedBox(height: 24),

          // Customer Retention
          _buildSectionTitle('Retención de Clientes'),
          const SizedBox(height: 16),
          _buildCustomerRetentionChart(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildKeyMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: KpiCardWidget(
                title: 'Ingresos Totales',
                value: '\$124,580',
                subtitle: 'ingresos del período',
                trendValue: 12.5,
                isPositiveTrend: true,
                icon: Icons.attach_money,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: KpiCardWidget(
                title: 'Órdenes',
                value: '347',
                subtitle: 'órdenes procesadas',
                trendValue: 8.3,
                isPositiveTrend: true,
                icon: Icons.shopping_cart,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: KpiCardWidget(
                title: 'Ticket Promedio',
                value: '\$359',
                subtitle: 'valor promedio',
                trendValue: 2.1,
                isPositiveTrend: false,
                icon: Icons.receipt,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: KpiCardWidget(
                title: 'Margen Bruto',
                value: '23.4%',
                subtitle: 'margen del período',
                trendValue: 1.8,
                isPositiveTrend: true,
                icon: Icons.percent,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparación con Período Anterior',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildComparisonRow('Ingresos', '\$124,580', '\$110,245', 12.5),
            _buildComparisonRow('Órdenes', '347', '320', 8.4),
            _buildComparisonRow('Productos Vendidos', '1,234', '1,089', 13.3),
            _buildComparisonRow('Nuevos Clientes', '89', '76', 17.1),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(String metric, String current, String previous, double change) {
    final isPositive = change > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(metric),
          ),
          Expanded(
            child: Text(
              current,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              previous,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${change.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsList() {
    final products = [
      {'name': 'Producto A', 'sales': '\$12,450', 'units': '245'},
      {'name': 'Producto B', 'sales': '\$9,320', 'units': '186'},
      {'name': 'Producto C', 'sales': '\$8,750', 'units': '175'},
      {'name': 'Producto D', 'sales': '\$7,890', 'units': '158'},
      {'name': 'Producto E', 'sales': '\$6,420', 'units': '128'},
    ];

    return Card(
      child: Column(
        children: products.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text('${index + 1}'),
            ),
            title: Text(product['name'] as String),
            subtitle: Text('${product['units']} unidades vendidas'),
            trailing: Text(
              product['sales'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSeasonalAnalysis() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patrones Estacionales Identificados',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.wb_sunny, color: Colors.orange),
              title: Text('Temporada Alta'),
              subtitle: Text('Noviembre - Enero: +35% en ventas'),
            ),
            const ListTile(
              leading: Icon(Icons.trending_down, color: Colors.blue),
              title: Text('Temporada Baja'),
              subtitle: Text('Febrero - Abril: -15% en ventas'),
            ),
            const ListTile(
              leading: Icon(Icons.auto_graph, color: Colors.green),
              title: Text('Estabilidad'),
              subtitle: Text('Mayo - Octubre: Ventas estables'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPerformanceList() {
    final categories = [
      {'name': 'Electrónicos', 'sales': '\$45,230', 'growth': 15.3, 'margin': 28.5},
      {'name': 'Ropa', 'sales': '\$32,180', 'growth': 8.7, 'margin': 35.2},
      {'name': 'Hogar', 'sales': '\$28,450', 'growth': -3.2, 'margin': 22.1},
      {'name': 'Deportes', 'sales': '\$18,720', 'growth': 22.1, 'margin': 18.9},
    ];

    return Card(
      child: Column(
        children: categories.map((category) {
          final growth = category['growth'] as double;
          final isPositive = growth > 0;
          
          return ListTile(
            title: Text(category['name'] as String),
            subtitle: Text('Margen: ${category['margin']}%'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  category['sales'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      color: isPositive ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    Text(
                      '${growth.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryDistributionChart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Gráfico de Distribución por Categoría'),
          Text('(Implementación del gráfico de pastel)'),
        ],
      ),
    );
  }

  Widget _buildCategoryGrowthChart() {
    return SizedBox(
      height: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('Gráfico de Crecimiento por Categoría'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopCustomersList() {
    final customers = [
      {'name': 'Cliente Premium A', 'sales': '\$24,500', 'orders': '45'},
      {'name': 'Corporativo B', 'sales': '\$18,700', 'orders': '32'},
      {'name': 'Cliente VIP C', 'sales': '\$15,200', 'orders': '28'},
      {'name': 'Empresa D', 'sales': '\$12,800', 'orders': '24'},
      {'name': 'Cliente E', 'sales': '\$9,500', 'orders': '19'},
    ];

    return Card(
      child: Column(
        children: customers.asMap().entries.map((entry) {
          final index = entry.key;
          final customer = entry.value;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text('${index + 1}'),
            ),
            title: Text(customer['name'] as String),
            subtitle: Text('${customer['orders']} órdenes'),
            trailing: Text(
              customer['sales'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomerRetentionChart() {
    return SizedBox(
      height: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('Gráfico de Retención de Clientes'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportando reporte de ventas...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compartiendo reporte...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  List<RevenueDataPoint> _getSampleRevenueData() {
    final now = DateTime.now();
    return List.generate(12, (index) {
      final date = DateTime(now.year, now.month - 11 + index);
      final value = 80000 + (index * 8000) + (index % 3 * 15000);
      return RevenueDataPoint(
        label: _getMonthName(date.month),
        value: value.toDouble(),
        date: date,
      );
    });
  }

  String _getMonthName(int month) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return months[month - 1];
  }
}
