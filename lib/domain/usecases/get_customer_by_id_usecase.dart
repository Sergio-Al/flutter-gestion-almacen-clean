import 'package:dartz/dartz.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';
import '../../core/errors/failures.dart';

class GetCustomerByIdUseCase {
  final CustomerRepository repository;

  GetCustomerByIdUseCase(this.repository);

  Future<Either<Failure, Customer>> call(String id) {
    return repository.getCustomerById(id);
  }
}
