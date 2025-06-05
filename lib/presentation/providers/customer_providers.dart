import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/repository_providers.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/get_customers_usecase.dart';
import '../../domain/usecases/create_customer_usecase.dart';
import '../../domain/usecases/update_customer_usecase.dart';
import '../../domain/usecases/delete_customer_usecase.dart';
import '../../domain/usecases/search_customers_usecase.dart';
import '../../core/errors/failures.dart';

final getCustomersUseCaseProvider = Provider<GetCustomersUseCase>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return GetCustomersUseCase(repository);
});

final customersProvider = FutureProvider<List<Customer>>((ref) async {
  final getCustomersUseCase = ref.watch(getCustomersUseCaseProvider);
  final result = await getCustomersUseCase();
  
  return result.fold(
    (failure) {
      if (failure is DatabaseFailure) {
        throw Exception('Database error: ${failure.message}');
      } else {
        throw Exception('Error loading customers: ${failure.message}');
      }
    },
    (customers) => customers,
  );
});

// Use cases providers
final createCustomerUseCaseProvider = Provider<CreateCustomerUseCase>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return CreateCustomerUseCase(repository);
});

final updateCustomerUseCaseProvider = Provider<UpdateCustomerUseCase>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return UpdateCustomerUseCase(repository);
});

final deleteCustomerUseCaseProvider = Provider<DeleteCustomerUseCase>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return DeleteCustomerUseCase(repository);
});

final searchCustomersUseCaseProvider = Provider<SearchCustomersUseCase>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return SearchCustomersUseCase(repository);
});

// Provider to get a specific customer by ID
final customerProvider = FutureProvider.family<Customer?, String>((ref, id) async {
  final repository = ref.watch(customerRepositoryProvider);
  final result = await repository.getCustomerById(id);
  
  return result.fold(
    (failure) => null,
    (customer) => customer,
  );
});

// Provider for customer search/filtering
final customerSearchProvider = FutureProvider.family<List<Customer>, String>((ref, query) async {
  if (query.isEmpty) {
    return ref.watch(customersProvider.future);
  }
  
  final searchUseCase = ref.watch(searchCustomersUseCaseProvider);
  final result = await searchUseCase(query);
  
  return result.fold(
    (failure) {
      throw Exception('Error searching customers: ${failure.message}');
    },
    (customers) => customers,
  );
});

// Provider for creating a new customer
final createCustomerProvider = FutureProvider.family<Customer, Customer>((ref, customer) async {
  final createUseCase = ref.watch(createCustomerUseCaseProvider);
  final result = await createUseCase(customer);
  
  return result.fold(
    (failure) {
      throw Exception('Error creating customer: ${failure.message}');
    },
    (newCustomer) {
      // Refresh the customers list
      ref.invalidate(customersProvider);
      return newCustomer;
    }
  );
});

// Provider for updating a customer
final updateCustomerProvider = FutureProvider.family<Customer, Customer>((ref, customer) async {
  final updateUseCase = ref.watch(updateCustomerUseCaseProvider);
  final result = await updateUseCase(customer);
  
  return result.fold(
    (failure) {
      throw Exception('Error updating customer: ${failure.message}');
    },
    (updatedCustomer) {
      // Refresh the customers list
      ref.invalidate(customersProvider);
      return updatedCustomer;
    }
  );
});

// Provider for deleting a customer
final deleteCustomerProvider = FutureProvider.family<bool, String>((ref, id) async {
  final deleteUseCase = ref.watch(deleteCustomerUseCaseProvider);
  final result = await deleteUseCase(id);
  
  return result.fold(
    (failure) {
      throw Exception('Error deleting customer: ${failure.message}');
    },
    (success) {
      // Refresh the customers list
      ref.invalidate(customersProvider);
      return success;
    }
  );
});
