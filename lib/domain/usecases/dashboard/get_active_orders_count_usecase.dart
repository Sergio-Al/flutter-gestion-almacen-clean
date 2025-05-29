import '../../entities/sales_order.dart';
import '../../repositories/sales_repository.dart';

class GetActiveOrdersCountUseCase {
  final SalesRepository _repository;

  GetActiveOrdersCountUseCase(this._repository);

  Future<int> call() async {
    final pendingOrders = await _repository.getSalesOrdersByStatus(OrderStatus.pending);
    final processingOrders = await _repository.getSalesOrdersByStatus(OrderStatus.processing);
    
    return pendingOrders.length + processingOrders.length;
  }
}
