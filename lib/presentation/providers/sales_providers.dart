import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/sales_order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/usecases/sales/save_sales_order_usecase.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/errors/failures.dart';

// Sales Orders Provider - obtiene datos reales del repositorio con sus items
final salesOrdersProvider = FutureProvider<List<SalesOrder>>((ref) async {
  final salesRepository = ref.watch(salesRepositoryProvider);
  
  try {
    // Obtener todas las órdenes
    final orders = await salesRepository.getAllSalesOrders();
    final result = <SalesOrder>[];
    
    // Para cada orden, cargar sus items correspondientes
    for (final order in orders) {
      final items = await salesRepository.getOrderItems(order.id);
      result.add(order.copyWith(items: items));
    }
    
    return result;
  } catch (e) {
    print('Error al cargar pedidos: ${e.toString()}');
    throw e;
  }
});

// Sales Order by ID Provider
final salesOrderByIdProvider = FutureProvider.family<SalesOrder?, String>((ref, orderId) async {
  final salesRepository = ref.watch(salesRepositoryProvider);
  try {
    // Obtenemos el pedido y sus items
    final order = await salesRepository.getSalesOrderById(orderId);
    if (order == null) return null;
    
    // Obtenemos los items asociados
    final items = await salesRepository.getOrderItems(orderId);
    
    // Retornamos una copia del pedido con los items cargados
    return order.copyWith(items: items);
  } catch (e) {
    print('Error al cargar el pedido: ${e.toString()}');
    return null;
  }
});

// Order Items Provider
final orderItemsProvider = FutureProvider.family<List<OrderItem>, String>((ref, orderId) async {
  final salesRepository = ref.watch(salesRepositoryProvider);
  try {
    return await salesRepository.getOrderItems(orderId);
  } catch (e) {
    print('Error al cargar los items del pedido: ${e.toString()}');
    return [];
  }
});

// Proveedor para el caso de uso SaveSalesOrder
final saveSalesOrderUseCaseProvider = Provider<SaveSalesOrderUseCase>((ref) {
  final salesRepository = ref.watch(salesRepositoryProvider);
  final stockRepository = ref.watch(stockRepositoryProvider);
  return SaveSalesOrderUseCase(salesRepository, stockRepository);
});

// Define un estado para la operación de guardar pedido
class SaveSalesOrderState {
  final bool isLoading;
  final String? orderId;
  final Failure? failure;

  SaveSalesOrderState({
    this.isLoading = false,
    this.orderId,
    this.failure,
  });

  bool get isSuccess => !isLoading && orderId != null && failure == null;
  bool get isError => !isLoading && failure != null;

  SaveSalesOrderState copyWith({
    bool? isLoading,
    String? orderId,
    Failure? failure,
  }) {
    return SaveSalesOrderState(
      isLoading: isLoading ?? this.isLoading,
      orderId: orderId ?? this.orderId,
      failure: failure,
    );
  }
}

// Proveedor de estado para la operación de guardar pedido
final saveSalesOrderStateProvider = StateProvider<SaveSalesOrderState>((ref) {
  return SaveSalesOrderState();
});

// Proveedor para guardar un pedido (usando un StateNotifierProvider)
final saveSalesOrderControllerProvider = StateNotifierProvider<SaveSalesOrderNotifier, void>((ref) {
  final saveUseCase = ref.watch(saveSalesOrderUseCaseProvider);
  return SaveSalesOrderNotifier(ref, saveUseCase);
});

class SaveSalesOrderNotifier extends StateNotifier<void> {
  final Ref _ref;
  final SaveSalesOrderUseCase _saveUseCase;

  SaveSalesOrderNotifier(this._ref, this._saveUseCase) : super(null);

  Future<void> saveSalesOrder(SaveOrderParams params) async {
    // Establecer estado de carga
    _ref.read(saveSalesOrderStateProvider.notifier).state = 
        SaveSalesOrderState(isLoading: true);
    
    // Ejecutar caso de uso
    final result = await _saveUseCase(
      customerId: params.customerId,
      customerName: params.customerName,
      items: params.items,
      notes: params.notes,
    );
    
    // Procesar resultado
    result.fold(
      (failure) {
        // En caso de error
        _ref.read(saveSalesOrderStateProvider.notifier).state = 
            SaveSalesOrderState(isLoading: false, failure: failure);
      }, 
      (orderId) {
        // En caso de éxito
        _ref.read(saveSalesOrderStateProvider.notifier).state = 
            SaveSalesOrderState(isLoading: false, orderId: orderId);
        
        // Invalidar la cache de pedidos cuando se guarda uno nuevo
        _ref.invalidate(salesOrdersProvider);
      }
    );
  }
  
  // Método para reiniciar el estado
  void resetState() {
    _ref.read(saveSalesOrderStateProvider.notifier).state = SaveSalesOrderState();
  }
}

// Clase para pasar parámetros al proveedor de guardado
class SaveOrderParams {
  final String customerId;
  final String customerName;
  final List<OrderItemInput> items;
  final String? notes;

  SaveOrderParams({
    required this.customerId,
    required this.customerName,
    required this.items,
    this.notes,
  });
}

// Sales Orders by Status Provider
final salesOrdersByStatusProvider = FutureProvider.family<List<SalesOrder>, OrderStatus>((ref, status) async {
  final salesRepository = ref.watch(salesRepositoryProvider);
  try {
    return await salesRepository.getSalesOrdersByStatus(status);
  } catch (e) {
    print('Error al cargar pedidos por estado: ${e.toString()}');
    return [];
  }
});

// Sales Orders by Date Range Provider
final salesOrdersByDateRangeProvider = FutureProvider.family<List<SalesOrder>, ({DateTime start, DateTime end})>((ref, dateRange) async {
  final salesRepository = ref.watch(salesRepositoryProvider);
  try {
    return await salesRepository.getSalesOrdersByDateRange(dateRange.start, dateRange.end);
  } catch (e) {
    print('Error al cargar pedidos por rango de fechas: ${e.toString()}');
    return [];
  }
});

// Los providers de consulta ahora usan directamente el repositorio, 
// eliminando la necesidad de datos de prueba.
