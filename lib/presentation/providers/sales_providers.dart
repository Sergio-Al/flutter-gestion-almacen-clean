import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/sales_order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/usecases/sales/save_sales_order_usecase.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/errors/failures.dart';

// Sales Orders State Provider with mock data
final salesOrdersProvider = FutureProvider<List<SalesOrder>>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 500));
  
  // Return mock data for development
  return _getMockSalesOrders();
});

// Sales Order by ID Provider
final salesOrderByIdProvider = FutureProvider.family<SalesOrder?, String>((ref, orderId) async {
  final orders = await ref.watch(salesOrdersProvider.future);
  try {
    return orders.firstWhere((order) => order.id == orderId);
  } catch (e) {
    return null;
  }
});

// Order Items Provider
final orderItemsProvider = FutureProvider.family<List<OrderItem>, String>((ref, orderId) async {
  final order = await ref.watch(salesOrderByIdProvider(orderId).future);
  return order?.items ?? [];
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
  final orders = await ref.watch(salesOrdersProvider.future);
  return orders.where((order) => order.status == status).toList();
});

// Sales Orders by Date Range Provider
final salesOrdersByDateRangeProvider = FutureProvider.family<List<SalesOrder>, ({DateTime start, DateTime end})>((ref, dateRange) async {
  final orders = await ref.watch(salesOrdersProvider.future);
  return orders.where((order) => 
    order.date.isAfter(dateRange.start) && 
    order.date.isBefore(dateRange.end)
  ).toList();
});

// Mock data helper function
List<SalesOrder> _getMockSalesOrders() {
  final now = DateTime.now();
  
  return [
    SalesOrder(
      id: 'SO001',
      customerId: '1',
      customerName: 'Juan Pérez',
      date: now.subtract(const Duration(days: 1)),
      status: OrderStatus.pending,
      items: [
        OrderItem(
          id: 'OI001',
          orderId: 'SO001',
          productId: 'P001',
          productName: 'Laptop Dell Inspiron',
          productDescription: 'Laptop 15.6" 8GB RAM 256GB SSD',
          quantity: 2,
          unitPrice: 899.99,
        ),
        OrderItem(
          id: 'OI002',
          orderId: 'SO001',
          productId: 'P002',
          productName: 'Mouse Logitech',
          productDescription: 'Mouse inalámbrico ergonómico',
          quantity: 2,
          unitPrice: 29.99,
        ),
      ],
      total: 1859.96,
      notes: 'Entrega urgente solicitada',
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(hours: 2)),
    ),
    SalesOrder(
      id: 'SO002',
      customerId: '2',
      customerName: 'María González',
      date: now.subtract(const Duration(days: 2)),
      status: OrderStatus.confirmed,
      items: [
        OrderItem(
          id: 'OI003',
          orderId: 'SO002',
          productId: 'P003',
          productName: 'Teclado Mecánico',
          productDescription: 'Teclado mecánico RGB switches azules',
          quantity: 1,
          unitPrice: 129.99,
        ),
        OrderItem(
          id: 'OI004',
          orderId: 'SO002',
          productId: 'P004',
          productName: 'Monitor 24"',
          productDescription: 'Monitor LED 24" Full HD',
          quantity: 1,
          unitPrice: 199.99,
        ),
      ],
      total: 329.98,
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(hours: 6)),
    ),
    SalesOrder(
      id: 'SO003',
      customerId: '3',
      customerName: 'Carlos López',
      date: now.subtract(const Duration(days: 3)),
      status: OrderStatus.shipped,
      items: [
        OrderItem(
          id: 'OI005',
          orderId: 'SO003',
          productId: 'P005',
          productName: 'Smartphone Samsung',
          productDescription: 'Galaxy S23 128GB Negro',
          quantity: 1,
          unitPrice: 699.99,
        ),
      ],
      total: 699.99,
      notes: 'Cliente VIP - envío gratuito',
      createdAt: now.subtract(const Duration(days: 3)),
      updatedAt: now.subtract(const Duration(days: 1)),
    ),
    SalesOrder(
      id: 'SO004',
      customerId: '4',
      customerName: 'Ana Martínez',
      date: now.subtract(const Duration(days: 5)),
      status: OrderStatus.delivered,
      items: [
        OrderItem(
          id: 'OI006',
          orderId: 'SO004',
          productId: 'P006',
          productName: 'Tablet iPad',
          productDescription: 'iPad Air 64GB WiFi Space Gray',
          quantity: 1,
          unitPrice: 549.99,
        ),
        OrderItem(
          id: 'OI007',
          orderId: 'SO004',
          productId: 'P007',
          productName: 'Funda iPad',
          productDescription: 'Funda protectora con soporte',
          quantity: 1,
          unitPrice: 39.99,
        ),
      ],
      total: 589.98,
      createdAt: now.subtract(const Duration(days: 5)),
      updatedAt: now.subtract(const Duration(days: 2)),
    ),
    SalesOrder(
      id: 'SO005',
      customerId: '5',
      customerName: 'Roberto Silva',
      date: now.subtract(const Duration(days: 7)),
      status: OrderStatus.cancelled,
      items: [
        OrderItem(
          id: 'OI008',
          orderId: 'SO005',
          productId: 'P008',
          productName: 'Auriculares Sony',
          productDescription: 'Auriculares inalámbricos con cancelación de ruido',
          quantity: 1,
          unitPrice: 299.99,
        ),
      ],
      total: 299.99,
      notes: 'Cancelado por el cliente - producto agotado',
      createdAt: now.subtract(const Duration(days: 7)),
      updatedAt: now.subtract(const Duration(days: 6)),
    ),
  ];
}
