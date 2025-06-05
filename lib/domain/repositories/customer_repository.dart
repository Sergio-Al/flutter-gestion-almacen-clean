import 'package:dartz/dartz.dart';
import '../entities/customer.dart';
import '../../core/errors/failures.dart';

abstract class CustomerRepository {
  /// Get all customers
  Future<Either<Failure, List<Customer>>> getCustomers();
  
  /// Get a customer by ID
  Future<Either<Failure, Customer>> getCustomerById(String id);
  
  /// Create a new customer
  Future<Either<Failure, Customer>> createCustomer(Customer customer);
  
  /// Update an existing customer
  Future<Either<Failure, Customer>> updateCustomer(Customer customer);
  
  /// Delete a customer
  Future<Either<Failure, bool>> deleteCustomer(String id);
  
  /// Search customers by query (name, email, phone)
  Future<Either<Failure, List<Customer>>> searchCustomers(String query);
}
