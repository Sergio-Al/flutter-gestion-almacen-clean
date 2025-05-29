import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '/domain/entities/product.dart';
import '/domain/entities/warehouse.dart';
import '/domain/entities/stock_batch.dart';
import '/domain/entities/sales_order.dart';
import '/domain/entities/order_item.dart';

/// Este archivo proporciona datos simulados para el desarrollo
/// Úsalo solo en el entorno de desarrollo

const uuid = Uuid();

// Datos simulados de productos
final mockProductsProvider = Provider<List<Product>>((ref) {
  return [
    Product(
      id: 'prod-1',
      sku: 'SKU001',
      name: 'Smartphone X11',
      description: 'Smartphone de última generación con pantalla AMOLED',
      categoryId: 'cat-electronics',
      unitPrice: 699.99,
      costPrice: 450.0,
      reorderPoint: 5,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Product(
      id: 'prod-2',
      sku: 'SKU002',
      name: 'Laptop Pro',
      description: 'Laptop para profesionales con procesador de última generación',
      categoryId: 'cat-electronics',
      unitPrice: 1299.99,
      costPrice: 950.0,
      reorderPoint: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    // Añadir más productos simulados
  ];
});

// Datos simulados de almacenes
final mockWarehousesProvider = Provider<List<Warehouse>>((ref) {
  return [
    Warehouse(
      id: 'warehouse-main',
      name: 'Almacén Central',
      location: 'Madrid',
      capacity: 1000,
      managerName: 'Juan Pérez',
      contactInfo: 'juan@example.com',
    ),
    Warehouse(
      id: 'warehouse-north',
      name: 'Almacén Norte',
      location: 'Barcelona',
      capacity: 800,
      managerName: 'Ana López',
      contactInfo: 'ana@example.com',
    ),
    // Añadir más almacenes simulados
  ];
});

// Datos simulados de lotes de stock
final mockStockBatchesProvider = Provider<List<StockBatch>>((ref) {
  return [
    StockBatch(
      id: 'batch-1',
      productId: 'prod-1',
      warehouseId: 'warehouse-main',
      quantity: 50,
      batchNumber: 'B001',
      expiryDate: DateTime.now().add(const Duration(days: 365)),
      receivedDate: DateTime.now().subtract(const Duration(days: 30)),
      supplierId: 'supplier-1',
    ),
    StockBatch(
      id: 'batch-2',
      productId: 'prod-2',
      warehouseId: 'warehouse-main',
      quantity: 20,
      batchNumber: 'B002',
      expiryDate: DateTime.now().add(const Duration(days: 730)),
      receivedDate: DateTime.now().subtract(const Duration(days: 15)),
      supplierId: 'supplier-2',
    ),
    // Añadir más lotes simulados
  ];
});

// Datos simulados de órdenes
final mockSalesOrdersProvider = Provider<List<SalesOrder>>((ref) {
  return [
    SalesOrder(
      id: 'order-1',
      customerName: 'Cliente Corporativo',
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
      status: OrderStatus.completed,
      totalAmount: 2099.98,
    ),
    SalesOrder(
      id: 'order-2',
      customerName: 'Retail Shop',
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      status: OrderStatus.pending,
      totalAmount: 4599.95,
    ),
    SalesOrder(
      id: 'order-3',
      customerName: 'Distribuidor Regional',
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
      status: OrderStatus.processing,
      totalAmount: 8799.90,
    ),
    // Añadir más órdenes simuladas
  ];
});

// Datos simulados de ítems de órdenes
final mockOrderItemsProvider = Provider<List<OrderItem>>((ref) {
  return [
    OrderItem(
      id: 'item-1',
      orderId: 'order-1',
      productId: 'prod-1',
      quantity: 3,
      unitPrice: 699.99,
      batchId: 'batch-1',
    ),
    OrderItem(
      id: 'item-2',
      orderId: 'order-2',
      productId: 'prod-1',
      quantity: 4,
      unitPrice: 699.99,
      batchId: 'batch-1',
    ),
    OrderItem(
      id: 'item-3',
      orderId: 'order-2',
      productId: 'prod-2',
      quantity: 1,
      unitPrice: 1299.99,
      batchId: 'batch-2',
    ),
    OrderItem(
      id: 'item-4',
      orderId: 'order-3',
      productId: 'prod-2',
      quantity: 5,
      unitPrice: 1299.99,
      batchId: 'batch-2',
    ),
    // Añadir más ítems simulados
  ];
});
