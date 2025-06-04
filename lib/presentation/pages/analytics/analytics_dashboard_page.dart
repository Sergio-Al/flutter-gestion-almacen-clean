import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/kpi_card_widget.dart';
import 'widgets/revenue_chart_canvas.dart';
import 'widgets/inventory_turnover_chart.dart';
import 'widgets/abc_analysis_chart.dart';
import 'inventory_reports_page.dart';
import 'sales_reports_page.dart';

class AnalyticsDashboardPage extends ConsumerStatefulWidget {
  const AnalyticsDashboardPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends ConsumerState<AnalyticsDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Análisis'),
        backgroundColor: theme.colorScheme.surfaceVariant,
        actions: [
          IconButton(
            onPressed: _showDateRangePicker,
            icon: const Icon(Icons.date_range),
            tooltip: 'Seleccionar Período',
          ),
          IconButton(
            onPressed: _exportReports,
            icon: const Icon(Icons.file_download),
            tooltip: 'Exportar Reportes',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Actualizar Datos'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Configuración'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard),
              text: 'Resumen General',
            ),
            Tab(
              icon: Icon(Icons.trending_up),
              text: 'Análisis de Ventas',
            ),
            Tab(
              icon: Icon(Icons.inventory),
              text: 'Análisis de Inventario',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildSalesAnalysisTab(),
          _buildInventoryAnalysisTab(),
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
          // Date Range Display
          _buildDateRangeHeader(),
          const SizedBox(height: 16),

          // KPI Cards Grid
          _buildKPIGrid(),
          const SizedBox(height: 24),

          // Revenue Chart
          _buildSectionHeader(
            'Evolución de Ingresos',
            'Tendencia de ingresos en el período seleccionado',
            onViewDetails: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reportes detallados en desarrollo...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: RevenueChartCanvas(
                  data: _getSampleRevenueData(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 24),

          // Recent Alerts
          _buildRecentAlerts(),
        ],
      ),
    );
  }

  Widget _buildSalesAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sales KPIs
          Row(
            children: [
              Expanded(
                child: KpiCardWidget(
                  title: 'Ventas del Mes',
                  value: '\$124,580',
                  subtitle: 'Últimos 30 días',
                  trendValue: 15.3,
                  isPositiveTrend: true,
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KpiCardWidget(
                  title: 'Órdenes Completadas',
                  value: '347',
                  subtitle: 'Este mes',
                  trendValue: 8.7,
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
                  subtitle: 'Por orden',
                  trendValue: 2.1,
                  isPositiveTrend: false,
                  icon: Icons.receipt,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KpiCardWidget(
                  title: 'Conversión',
                  value: '23.4%',
                  subtitle: 'Tasa de conversión',
                  trendValue: 5.2,
                  isPositiveTrend: true,
                  icon: Icons.percent,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Revenue Chart
          _buildSectionHeader(
            'Análisis de Ventas Detallado',
            'Desglose completo del rendimiento de ventas',
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 400,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: RevenueChartCanvas(
                  data: _getSampleRevenueData(),
                  title: 'Análisis de Ventas Detallado',
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SalesReportsPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.analytics),
                  label: const Text('Ver Reportes Detallados'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _exportSalesReport,
                  icon: const Icon(Icons.file_download),
                  label: const Text('Exportar Datos'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inventory KPIs
          Row(
            children: [
              Expanded(
                child: KpiCardWidget(
                  title: 'Valor Total Inventario',
                  value: '\$2.3M',
                  subtitle: 'Valor actual',
                  trendValue: 3.2,
                  isPositiveTrend: true,
                  icon: Icons.inventory_2,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KpiCardWidget(
                  title: 'Rotación Promedio',
                  value: '4.2x',
                  subtitle: 'Anual',
                  trendValue: 12.5,
                  isPositiveTrend: true,
                  icon: Icons.autorenew,
                  color: Colors.teal,
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
                  subtitle: 'Productos',
                  trendValue: 15.0,
                  isPositiveTrend: false,
                  icon: Icons.warning,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KpiCardWidget(
                  title: 'Días de Stock',
                  value: '45',
                  subtitle: 'Promedio',
                  trendValue: 8.3,
                  isPositiveTrend: false,
                  icon: Icons.schedule,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Inventory Turnover Chart
          _buildSectionHeader(
            'Rotación de Inventario',
            'Análisis de movimiento de productos por categoría',
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
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

          // ABC Analysis
          _buildSectionHeader(
            'Análisis ABC',
            'Clasificación de productos por importancia estratégica',
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
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

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reportes de inventario en desarrollo...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.assessment),
                  label: const Text('Reportes de Inventario'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _exportInventoryReport,
                  icon: const Icon(Icons.file_download),
                  label: const Text('Exportar Análisis'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.date_range, color: Colors.blue),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Período de Análisis',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_formatDate(_selectedDateRange.start)} - ${_formatDate(_selectedDateRange.end)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _showDateRangePicker,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Cambiar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPIGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: KpiCardWidget(
                title: 'Ingresos Totales',
                value: '\$245,380',
                subtitle: 'Últimos 30 días',
                trendValue: 12.5,
                isPositiveTrend: true,
                icon: Icons.attach_money,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: KpiCardWidget(
                title: 'Órdenes Procesadas',
                value: '1,247',
                subtitle: 'Este mes',
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
                title: 'Productos Vendidos',
                value: '8,934',
                subtitle: 'Unidades',
                trendValue: 15.7,
                isPositiveTrend: true,
                icon: Icons.inventory,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: KpiCardWidget(
                title: 'Margen Promedio',
                value: '23.4%',
                subtitle: 'Porcentaje',
                trendValue: 2.1,
                isPositiveTrend: false,
                icon: Icons.percent,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, {VoidCallback? onViewDetails}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (onViewDetails != null)
          TextButton.icon(
            onPressed: onViewDetails,
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text('Ver Detalles'),
          ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reportes de ventas en desarrollo...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.trending_up, size: 32, color: Colors.green),
                        SizedBox(height: 8),
                        Text(
                          'Reportes de Ventas',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const InventoryReportsPage(),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2, size: 32, color: Colors.blue),
                        SizedBox(height: 8),
                        Text(
                          'Reportes de Inventario',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentAlerts() {
    final alerts = [
      {
        'title': 'Stock Bajo',
        'message': '5 productos por debajo del nivel mínimo',
        'type': 'warning',
        'time': 'Hace 2 horas',
      },
      {
        'title': 'Meta de Ventas',
        'message': 'Se alcanzó el 95% de la meta mensual',
        'type': 'success',
        'time': 'Hace 4 horas',
      },
      {
        'title': 'Productos Vencidos',
        'message': '3 lotes próximos a vencer esta semana',
        'type': 'error',
        'time': 'Hace 1 día',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alertas Recientes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...alerts.map((alert) => Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getAlertColor(alert['type'] as String),
              child: Icon(
                _getAlertIcon(alert['type'] as String),
                color: Colors.white,
              ),
            ),
            title: Text(alert['title'] as String),
            subtitle: Text(alert['message'] as String),
            trailing: Text(
              alert['time'] as String,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () => _handleAlertTap(alert),
          ),
        )),
      ],
    );
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'warning':
        return Colors.orange;
      case 'success':
        return Colors.green;
      case 'error':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'warning':
        return Icons.warning;
      case 'success':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.blue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'refresh':
        _refreshData();
        break;
      case 'settings':
        _showSettingsDialog();
        break;
    }
  }

  void _refreshData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(strokeWidth: 2),
            SizedBox(width: 16),
            Text('Actualizando datos...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración de Analytics'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notificaciones'),
              trailing: Switch(value: true, onChanged: null),
            ),
            ListTile(
              leading: Icon(Icons.auto_graph),
              title: Text('Actualización Automática'),
              trailing: Switch(value: false, onChanged: null),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _exportReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportando reportes...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exportSalesReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportando reporte de ventas...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exportInventoryReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportando reporte de inventario...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleAlertTap(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alert['title'] as String),
        content: Text(alert['message'] as String),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle alert action
            },
            child: const Text('Ver Detalles'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Sample data methods for charts
  List<RevenueDataPoint> _getSampleRevenueData() {
    final now = DateTime.now();
    return List.generate(12, (index) {
      final date = DateTime(now.year, now.month - 11 + index);
      final baseValue = 15000 + (index * 2000);
      final variation = (index % 3) * 3000;
      return RevenueDataPoint(
        label: _getMonthName(date.month),
        value: (baseValue + variation).toDouble(),
        date: date,
      );
    });
  }

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
        turnover: 8.7,
        cogs: 280000,
        avgInventory: 32200,
      ),
      TurnoverDataPoint(
        category: 'Hogar',
        turnover: 6.3,
        cogs: 185000,
        avgInventory: 29400,
      ),
      TurnoverDataPoint(
        category: 'Deportes',
        turnover: 12.1,
        cogs: 320000,
        avgInventory: 26400,
      ),
      TurnoverDataPoint(
        category: 'Libros',
        turnover: 4.8,
        cogs: 95000,
        avgInventory: 19800,
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

  String _getMonthName(int month) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return months[month - 1];
  }
}
