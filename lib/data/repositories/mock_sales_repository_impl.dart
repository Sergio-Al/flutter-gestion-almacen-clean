import '../../domain/repositories/sales_repository.dart';
import '../../domain/entities/sales_order.dart';
import '../../domain/entities/order_item.dart';
import '../../core/utils/mock_data.dart';
import 'package:uuid/uuid.dart';

/// Implementación simulada del repositorio de ventas para desarrollo
class MockSalesRepositoryImpl implements SalesRepository {
  final List<SalesOrder> _salesOrders;
  final List<OrderItem> _orderItems;
  final _uuid = const Uuid();

  // Datos históricos de ventas generados para pruebas
  final Map<String, double> _historicalSalesData = {};

  MockSalesRepositoryImpl(this._salesOrders, this._orderItems) {
    // Generar datos históricos de ventas para los últimos 30 días
    final now = DateTime.now();
    for (int i = 30; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Generar un valor aleatorio con variación para simular datos reales
      double baseValue = 5000;
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        baseValue *= 0.7; // Menos ventas en fines de semana
      }
      
      // Añadir oscilación aleatoria para simular datos reales
      final randomFactor = 0.8 + (DateTime.now().millisecondsSinceEpoch % 4000) / 10000;
      _historicalSalesData[dateKey] = baseValue * randomFactor;
    }
  }

  @override
  Future<List<SalesOrder>> getAllSalesOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_salesOrders);
  }

  @override
  Future<SalesOrder?> getSalesOrderById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _salesOrders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<OrderItem>> getOrderItems(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _orderItems.where((item) => item.orderId == orderId).toList();
  }

  @override
  Future<String> createSalesOrder(SalesOrder salesOrder, List<OrderItem> items) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _salesOrders.add(salesOrder);
    _orderItems.addAll(items);
    
    // Actualizar los datos históricos
    final dateKey = '${salesOrder.orderDate.year}-${salesOrder.orderDate.month.toString().padLeft(2, '0')}-${salesOrder.orderDate.day.toString().padLeft(2, '0')}';
    _historicalSalesData[dateKey] = (_historicalSalesData[dateKey] ?? 0) + salesOrder.totalAmount;
    
    return salesOrder.id;
  }

  @override
  Future<void> updateSalesOrder(SalesOrder salesOrder) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _salesOrders.indexWhere((o) => o.id == salesOrder.id);
    if (index >= 0) {
      _salesOrders[index] = salesOrder;
    } else {
      throw Exception('Orden no encontrada para actualización');
    }
  }

  @override
  Future<void> deleteSalesOrder(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Primero eliminamos los items asociados
    _orderItems.removeWhere((item) => item.orderId == id);
    
    // Luego eliminamos la orden
    final index = _salesOrders.indexWhere((o) => o.id == id);
    if (index >= 0) {
      _salesOrders.removeAt(index);
    } else {
      throw Exception('Orden no encontrada para eliminación');
    }
  }

  @override
  Future<List<SalesOrder>> getSalesOrdersByDateRange(DateTime start, DateTime end) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Si no hay datos reales para el rango completo, generamos datos simulados
    if (_salesOrders.isEmpty) {
      final simulatedOrders = <SalesOrder>[];
      
      // Iterar por cada día en el rango
      for (DateTime date = start; date.isBefore(end) || date.isAtSameMomentAs(end); date = date.add(const Duration(days: 1))) {
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        
        // Si tenemos datos históricos para esta fecha, crear una orden simulada
        if (_historicalSalesData.containsKey(dateKey)) {
          simulatedOrders.add(
            SalesOrder(
              id: _uuid.v4(),
              customerName: 'Cliente Simulado',
              orderDate: date,
              status: OrderStatus.completed,
              totalAmount: _historicalSalesData[dateKey]!,
            ),
          );
        }
      }
      
      return simulatedOrders;
    }
    
    return _salesOrders.where(
      (order) => 
        (order.orderDate.isAfter(start) || order.orderDate.isAtSameMomentAs(start)) && 
        (order.orderDate.isBefore(end) || order.orderDate.isAtSameMomentAs(end))
    ).toList();
  }

  @override
  Future<List<SalesOrder>> getSalesOrdersByStatus(OrderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _salesOrders.where((order) => order.status == status).toList();
  }
}
