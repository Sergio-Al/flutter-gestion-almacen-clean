import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/report_filter_widget.dart';
import 'widgets/inventory_turnover_chart.dart';
import 'widgets/abc_analysis_chart.dart';
import 'widgets/kpi_card_widget.dart';

class InventoryReportsPage extends ConsumerStatefulWidget {
  const InventoryReportsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<InventoryReportsPage> createState() => _InventoryReportsPageState();
}

class _InventoryReportsPageState extends ConsumerState<InventoryReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  String _selectedWarehouse = 'all';
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
      selectedWarehouses: _selectedWarehouse == 'all' ? <String>{} : {_selectedWarehouse},
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
        title: const Text('Reportes de Inventario'),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        actions: [
          IconButton(
            onPressed: _exportReport,
            icon: const Icon(Icons.file_download),
            tooltip: 'Exportar Reporte',
          ),
          IconButton(
            onPressed: _generateAlert,
            icon: const Icon(Icons.notification_add),
            tooltip: 'Configurar Alertas',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard),
              text: 'Resumen General',
            ),
            Tab(
              icon: Icon(Icons.autorenew),
              text: 'Rotación',
            ),
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Análisis ABC',
            ),
            Tab(
              icon: Icon(Icons.warning),
              text: 'Alertas y Riesgos',
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
                _selectedWarehouse = newOptions.selectedWarehouses.isEmpty ? 'all' : newOptions.selectedWarehouses.first;
                _selectedCategory = newOptions.selectedCategories.isEmpty ? 'all' : newOptions.selectedCategories.first;
              });
            },
            showWarehouses: true,
            showCategories: true,
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTurnoverTab(),
                _buildAbcAnalysisTab(),
                _buildAlertsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics
          _buildSectionTitle('Métricas Clave del Inventario'),
          const SizedBox(height: 16),
          _buildInventoryMetricsGrid(),
          const SizedBox(height: 24),

          // Inventory Value Chart
          _buildSectionTitle('Evolución del Valor del Inventario'),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildInventoryValueChart(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Stock Status Distribution
          _buildSectionTitle('Distribución del Estado del Stock'),
          const SizedBox(height: 16),
          _buildStockStatusDistribution(),
          const SizedBox(height: 24),

          // Top Moving Products
          _buildSectionTitle('Productos con Mayor Movimiento'),
          const SizedBox(height: 16),
          _buildTopMovingProductsList(),
        ],
      ),
    );
  }

  Widget _buildTurnoverTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Turnover Metrics
          _buildSectionTitle('Métricas de Rotación'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: KpiCardWidget(
                  title: 'Rotación Promedio',
                  value: '4.2x',
                  subtitle: 'Veces por año',
                  trendValue: 12.5,
                  isPositiveTrend: true,
                  icon: Icons.autorenew,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KpiCardWidget(
                  title: 'Días de Inventario',
                  value: '87',
                  subtitle: 'Días promedio',
                  trendValue: 8.3,
                  isPositiveTrend: false,
                  icon: Icons.schedule,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Turnover Chart
          _buildSectionTitle('Análisis de Rotación por Categoría'),
          const SizedBox(height: 16),
          SizedBox(
            height: 350,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: InventoryTurnoverChart(
                  data: _getSampleTurnoverData(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Slow Moving Products
          _buildSectionTitle('Productos de Rotación Lenta'),
          const SizedBox(height: 16),
          _buildSlowMovingProductsList(),
          const SizedBox(height: 24),

          // Fast Moving Products
          _buildSectionTitle('Productos de Rotación Rápida'),
          const SizedBox(height: 16),
          _buildFastMovingProductsList(),
        ],
      ),
    );
  }

  Widget _buildAbcAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ABC Overview
          _buildSectionTitle('Resumen del Análisis ABC'),
          const SizedBox(height: 16),
          _buildAbcOverviewCards(),
          const SizedBox(height: 24),

          // ABC Chart
          _buildSectionTitle('Distribución ABC'),
          const SizedBox(height: 16),
          SizedBox(
            height: 350,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AbcAnalysisChart(
                  data: _getSampleAbcData(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ABC Categories Detail
          _buildSectionTitle('Detalle por Categoría ABC'),
          const SizedBox(height: 16),
          _buildAbcCategoriesDetail(),
          const SizedBox(height: 24),

          // Recommendations
          _buildSectionTitle('Recomendaciones Estratégicas'),
          const SizedBox(height: 16),
          _buildStrategicRecommendations(),
        ],
      ),
    );
  }

  Widget _buildAlertsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alert Summary
          _buildSectionTitle('Resumen de Alertas'),
          const SizedBox(height: 16),
          _buildAlertSummaryCards(),
          const SizedBox(height: 24),

          // Critical Alerts
          _buildSectionTitle('Alertas Críticas'),
          const SizedBox(height: 16),
          _buildCriticalAlertsList(),
          const SizedBox(height: 24),

          // Low Stock Alerts
          _buildSectionTitle('Alertas de Stock Bajo'),
          const SizedBox(height: 16),
          _buildLowStockAlertsList(),
          const SizedBox(height: 24),

          // Expiry Alerts
          _buildSectionTitle('Alertas de Vencimiento'),
          const SizedBox(height: 16),
          _buildExpiryAlertsList(),
          const SizedBox(height: 24),

          // Overstock Alerts
          _buildSectionTitle('Alertas de Sobrestock'),
          const SizedBox(height: 16),
          _buildOverstockAlertsList(),
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

  Widget _buildInventoryMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: KpiCardWidget(
                title: 'Valor Total',
                value: '\$2.3M',
                subtitle: 'Valor actual',
                trendValue: 5.2,
                isPositiveTrend: true,
                icon: Icons.account_balance_wallet,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: KpiCardWidget(
                title: 'Productos Activos',
                value: '1,847',
                subtitle: 'Total productos',
                trendValue: 3.1,
                isPositiveTrend: true,
                icon: Icons.inventory_2,
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
                title: 'Stock Crítico',
                value: '23',
                subtitle: 'Productos críticos',
                trendValue: 15.0,
                isPositiveTrend: false,
                icon: Icons.warning,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: KpiCardWidget(
                title: 'Rotación Media',
                value: '4.2x',
                subtitle: 'Veces por año',
                trendValue: 8.7,
                isPositiveTrend: true,
                icon: Icons.autorenew,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInventoryValueChart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Gráfico de Valor del Inventario'),
          Text('(Evolución temporal del valor total)'),
        ],
      ),
    );
  }

  Widget _buildStockStatusDistribution() {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.green.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 32),
                  SizedBox(height: 8),
                  Text(
                    'Stock Normal',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text('1,524 productos'),
                  Text('82.5%'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            color: Colors.orange.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 32),
                  SizedBox(height: 8),
                  Text(
                    'Stock Bajo',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text('267 productos'),
                  Text('14.5%'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            color: Colors.red.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.error, color: Colors.red, size: 32),
                  SizedBox(height: 8),
                  Text(
                    'Sin Stock',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text('56 productos'),
                  Text('3.0%'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopMovingProductsList() {
    final products = [
      {'name': 'Producto Premium A', 'movement': '1,245', 'value': '\$45,230'},
      {'name': 'Producto Estándar B', 'movement': '987', 'value': '\$32,180'},
      {'name': 'Producto Especial C', 'movement': '856', 'value': '\$28,450'},
      {'name': 'Producto Regular D', 'movement': '743', 'value': '\$18,720'},
      {'name': 'Producto Básico E', 'movement': '682', 'value': '\$15,890'},
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
            subtitle: Text('${product['movement']} unidades movidas'),
            trailing: Text(
              product['value'] as String,
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

  Widget _buildSlowMovingProductsList() {
    final products = [
      {'name': 'Producto Estacional X', 'days': '145', 'stock': '234'},
      {'name': 'Producto Descontinuado Y', 'days': '167', 'stock': '89'},
      {'name': 'Producto Especializado Z', 'days': '123', 'stock': '156'},
    ];

    return Card(
      child: Column(
        children: products.map((product) => ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.orange,
            child: Icon(Icons.schedule, color: Colors.white),
          ),
          title: Text(product['name'] as String),
          subtitle: Text('${product['days']} días sin movimiento'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Stock: ${product['stock']}'),
              const Text(
                'Acción Requerida',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildFastMovingProductsList() {
    final products = [
      {'name': 'Producto Popular A', 'turnover': '12.3x', 'trend': 'up'},
      {'name': 'Producto Tendencia B', 'turnover': '9.8x', 'trend': 'up'},
      {'name': 'Producto Demandado C', 'turnover': '8.5x', 'trend': 'stable'},
    ];

    return Card(
      child: Column(
        children: products.map((product) => ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(Icons.speed, color: Colors.white),
          ),
          title: Text(product['name'] as String),
          subtitle: Text('Rotación: ${product['turnover']}'),
          trailing: Icon(
            product['trend'] == 'up' 
                ? Icons.trending_up 
                : Icons.trending_flat,
            color: product['trend'] == 'up' 
                ? Colors.green 
                : Colors.blue,
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildAbcOverviewCards() {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.green.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Categoría A',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('15% productos'),
                  Text('80% valor'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Categoría B',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('25% productos'),
                  Text('15% valor'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            color: Colors.orange.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Categoría C',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('60% productos'),
                  Text('5% valor'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAbcCategoriesDetail() {
    return Card(
      child: Column(
        children: [
          _buildAbcCategoryTile('A', 'Alta Prioridad', 'Control estricto, revisión semanal', Colors.green),
          _buildAbcCategoryTile('B', 'Prioridad Media', 'Control moderado, revisión mensual', Colors.blue),
          _buildAbcCategoryTile('C', 'Baja Prioridad', 'Control básico, revisión trimestral', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildAbcCategoryTile(String category, String priority, String control, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: Text(
          category,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(priority),
      subtitle: Text(control),
    );
  }

  Widget _buildStrategicRecommendations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecommendationItem(
              Icons.star,
              'Productos Categoría A',
              'Mantener stock de seguridad alto y monitoreo constante',
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildRecommendationItem(
              Icons.balance,
              'Productos Categoría B',
              'Optimizar niveles de reorden y frecuencia de revisión',
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildRecommendationItem(
              Icons.compress,
              'Productos Categoría C',
              'Considerar reducir inventario y simplificar gestión',
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(IconData icon, String title, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                description,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlertSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: KpiCardWidget(
            title: 'Alertas Críticas',
            value: '12',
            subtitle: 'Requieren acción',
            trendValue: 25.0,
            isPositiveTrend: false,
            icon: Icons.error,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: KpiCardWidget(
            title: 'Alertas Moderadas',
            value: '34',
            subtitle: 'En monitoreo',
            trendValue: 8.3,
            isPositiveTrend: true,
            icon: Icons.warning,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildCriticalAlertsList() {
    final alerts = [
      {
        'title': 'Stock Agotado',
        'product': 'Producto Premium A',
        'action': 'Reorden Urgente',
        'priority': 'Crítica'
      },
      {
        'title': 'Vencimiento Inmediato',
        'product': 'Lote #12345',
        'action': 'Liquidar Inmediatamente',
        'priority': 'Crítica'
      },
    ];

    return Card(
      child: Column(
        children: alerts.map((alert) => ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.red,
            child: Icon(Icons.error, color: Colors.white),
          ),
          title: Text(alert['title'] as String),
          subtitle: Text(alert['product'] as String),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                alert['priority'] as String,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                alert['action'] as String,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildLowStockAlertsList() {
    final alerts = [
      {'product': 'Producto B', 'current': '15', 'min': '50'},
      {'product': 'Producto C', 'current': '8', 'min': '25'},
      {'product': 'Producto D', 'current': '23', 'min': '75'},
    ];

    return Card(
      child: Column(
        children: alerts.map((alert) => ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.orange,
            child: Icon(Icons.inventory, color: Colors.white),
          ),
          title: Text(alert['product'] as String),
          subtitle: Text('Stock actual: ${alert['current']} unidades'),
          trailing: Text(
            'Mín: ${alert['min']}',
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildExpiryAlertsList() {
    final alerts = [
      {'product': 'Lote #12346', 'days': '3', 'quantity': '150'},
      {'product': 'Lote #12347', 'days': '7', 'quantity': '89'},
      {'product': 'Lote #12348', 'days': '14', 'quantity': '234'},
    ];

    return Card(
      child: Column(
        children: alerts.map((alert) => ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.red,
            child: Icon(Icons.schedule, color: Colors.white),
          ),
          title: Text(alert['product'] as String),
          subtitle: Text('Vence en ${alert['days']} días'),
          trailing: Text(
            '${alert['quantity']} unidades',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildOverstockAlertsList() {
    final alerts = [
      {'product': 'Producto E', 'current': '850', 'max': '500'},
      {'product': 'Producto F', 'current': '650', 'max': '400'},
    ];

    return Card(
      child: Column(
        children: alerts.map((alert) => ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.trending_up, color: Colors.white),
          ),
          title: Text(alert['product'] as String),
          subtitle: Text('Stock actual: ${alert['current']} unidades'),
          trailing: Text(
            'Máx: ${alert['max']}',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        )).toList(),
      ),
    );
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportando reporte de inventario...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _generateAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurar Alertas'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.inventory),
              title: Text('Alertas de Stock Bajo'),
              trailing: Switch(value: true, onChanged: null),
            ),
            ListTile(
              leading: Icon(Icons.schedule),
              title: Text('Alertas de Vencimiento'),
              trailing: Switch(value: true, onChanged: null),
            ),
            ListTile(
              leading: Icon(Icons.trending_up),
              title: Text('Alertas de Sobrestock'),
              trailing: Switch(value: false, onChanged: null),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Sample data methods
  List<TurnoverDataPoint> _getSampleTurnoverData() {
    return [
      TurnoverDataPoint(
        category: 'Electrónicos',
        turnover: 15.2,
        cogs: 450000,
        avgInventory: 29600,
      ),
      TurnoverDataPoint(
        category: 'Ropa',
        turnover: 8.5,
        cogs: 280000,
        avgInventory: 32900,
      ),
      TurnoverDataPoint(
        category: 'Hogar',
        turnover: 6.3,
        cogs: 180000,
        avgInventory: 28600,
      ),
      TurnoverDataPoint(
        category: 'Deportes',
        turnover: 12.8,
        cogs: 320000,
        avgInventory: 25000,
      ),
    ];
  }

  List<AbcDataPoint> _getSampleAbcData() {
    return [
      AbcDataPoint(
        category: AbcCategory.A,
        itemCount: 45,
        value: 750000,
        valuePercentage: 78.5,
        itemPercentage: 15.0,
      ),
      AbcDataPoint(
        category: AbcCategory.B,
        itemCount: 85,
        value: 150000,
        valuePercentage: 15.7,
        itemPercentage: 28.3,
      ),
      AbcDataPoint(
        category: AbcCategory.C,
        itemCount: 170,
        value: 55000,
        valuePercentage: 5.8,
        itemPercentage: 56.7,
      ),
    ];
  }
}
