import '../../entities/sales_order.dart';
import '../../repositories/sales_repository.dart';

class GetSalesPerformanceUseCase {
  final SalesRepository _repository;

  GetSalesPerformanceUseCase(this._repository);

  Future<({double totalAmount, double percentChange, List<({DateTime date, double amount})> dailyData})> call(int days) async {
    final today = DateTime.now();
    final startDate = today.subtract(Duration(days: days));
    
    // Obtener ventas en el rango de días
    final orders = await _repository.getSalesOrdersByDateRange(
      DateTime(startDate.year, startDate.month, startDate.day),
      DateTime(today.year, today.month, today.day, 23, 59, 59)
    );
    
    // Calcular el monto total
    final totalAmount = orders.fold(0.0, (sum, order) => sum + order.totalAmount);
    
    // Obtener ventas del periodo anterior para comparar
    final previousStartDate = startDate.subtract(Duration(days: days));
    final previousOrders = await _repository.getSalesOrdersByDateRange(
      DateTime(previousStartDate.year, previousStartDate.month, previousStartDate.day),
      DateTime(startDate.year, startDate.month, startDate.day).subtract(const Duration(seconds: 1))
    );
    
    final previousTotalAmount = previousOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
    
    // Calcular el porcentaje de cambio
    double percentChange = 0;
    if (previousTotalAmount > 0) {
      percentChange = ((totalAmount - previousTotalAmount) / previousTotalAmount) * 100;
    }
    
    // Crear datos diarios para el gráfico
    final dailyData = <({DateTime date, double amount})>[];
    
    // Crear un mapa para agrupar por día
    final Map<String, double> dailySales = {};
    
    // Inicializar todos los días con cero
    for (int i = 0; i < days; i++) {
      final date = today.subtract(Duration(days: days - i - 1));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      dailySales[dateKey] = 0;
    }
    
    // Rellenar con datos reales
    for (final order in orders) {
      final date = order.orderDate;
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      dailySales[dateKey] = (dailySales[dateKey] ?? 0) + order.totalAmount;
    }
    
    // Convertir el mapa a la lista final
    dailySales.forEach((dateKey, amount) {
      final parts = dateKey.split('-');
      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      dailyData.add((date: date, amount: amount));
    });
    
    // Ordenar por fecha
    dailyData.sort((a, b) => a.date.compareTo(b.date));
    
    return (
      totalAmount: totalAmount, 
      percentChange: percentChange, 
      dailyData: dailyData
    );
  }
}
