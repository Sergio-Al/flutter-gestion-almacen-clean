import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/customer.dart';

// Mock data provider - replace with actual data source
final customersProvider = FutureProvider<List<Customer>>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 500));
  
  // Return mock data
  return [
    Customer(
      id: '1',
      name: 'Juan Pérez',
      email: 'juan.perez@email.com',
      phone: '+1-555-0101',
      address: 'Av. Principal 123, Ciudad',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Customer(
      id: '2',
      name: 'María González',
      email: 'maria.gonzalez@email.com',
      phone: '+1-555-0102',
      address: 'Calle Secundaria 456, Ciudad',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Customer(
      id: '3',
      name: 'Carlos López',
      email: 'carlos.lopez@email.com',
      phone: '+1-555-0103',
      address: 'Plaza Central 789, Ciudad',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Customer(
      id: '4',
      name: 'Ana Martínez',
      email: 'ana.martinez@email.com',
      phone: '+1-555-0104',
      address: 'Zona Industrial 321, Ciudad',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    Customer(
      id: '5',
      name: 'Roberto Silva',
      email: 'roberto.silva@email.com',
      phone: '+1-555-0105',
      address: 'Barrio Norte 654, Ciudad',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];
});

// Provider to get a specific customer by ID
final customerProvider = FutureProvider.family<Customer?, String>((ref, id) async {
  final customers = await ref.watch(customersProvider.future);
  try {
    return customers.firstWhere((customer) => customer.id == id);
  } catch (e) {
    return null;
  }
});

// Provider for customer search/filtering
final customerSearchProvider = Provider.family<AsyncValue<List<Customer>>, String>((ref, query) {
  return ref.watch(customersProvider).whenData((customers) {
    if (query.isEmpty) return customers;
    
    return customers.where((customer) {
      return customer.name.toLowerCase().contains(query.toLowerCase()) ||
             customer.email.toLowerCase().contains(query.toLowerCase()) ||
             customer.phone.contains(query);
    }).toList();
  });
});
