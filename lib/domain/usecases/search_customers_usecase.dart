import 'package:dartz/dartz.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';
import '../../core/errors/failures.dart';

class SearchCustomersUseCase {
  final CustomerRepository repository;

  SearchCustomersUseCase(this.repository);

  Future<Either<Failure, List<Customer>>> call(String query) {
    return repository.searchCustomers(query);
  }
}
