import 'package:dartz/dartz.dart';
import '../repositories/customer_repository.dart';
import '../../core/errors/failures.dart';

class DeleteCustomerUseCase {
  final CustomerRepository repository;

  DeleteCustomerUseCase(this.repository);

  Future<Either<Failure, bool>> call(String id) {
    return repository.deleteCustomer(id);
  }
}
