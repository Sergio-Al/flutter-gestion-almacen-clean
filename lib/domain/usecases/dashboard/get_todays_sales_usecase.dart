import '../../entities/sales_order.dart';
import '../../repositories/sales_repository.dart';

class GetTodaysSalesUseCase {
  final SalesRepository _repository;

  GetTodaysSalesUseCase(this._repository);

  Future<double> call() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    
    final todayOrders = await _repository.getSalesOrdersByDateRange(startOfDay, endOfDay);
    
    double total = 0.0;
    for (final order in todayOrders) {
      total += await order.totalAmount;
    }
    return total;
  }
}
