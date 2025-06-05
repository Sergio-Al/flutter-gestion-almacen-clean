import 'package:dartz/dartz.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';
import '../../core/errors/failures.dart';

class UpdateCustomerUseCase {
  final CustomerRepository repository;

  UpdateCustomerUseCase(this.repository);

  Future<Either<Failure, Customer>> call(Customer customer) {
    return repository.updateCustomer(customer);
  }
}
