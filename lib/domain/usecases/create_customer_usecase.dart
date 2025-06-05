import 'package:dartz/dartz.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';
import '../../core/errors/failures.dart';

class CreateCustomerUseCase {
  final CustomerRepository repository;

  CreateCustomerUseCase(this.repository);

  Future<Either<Failure, Customer>> call(Customer customer) {
    return repository.createCustomer(customer);
  }
}
