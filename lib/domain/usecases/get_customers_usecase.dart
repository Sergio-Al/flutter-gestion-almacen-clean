import 'package:dartz/dartz.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';
import '../../core/errors/failures.dart';

class GetCustomersUseCase {
  final CustomerRepository repository;

  GetCustomersUseCase(this.repository);

  Future<Either<Failure, List<Customer>>> call() {
    return repository.getCustomers();
  }
}
