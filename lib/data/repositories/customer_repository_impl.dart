import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_local_data_source.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerLocalDataSource localDataSource;

  CustomerRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Customer>>> getCustomers() async {
    try {
      final customers = await localDataSource.getCustomers();
      return Right(customers);
    } on LocalDatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Customer>> getCustomerById(String id) async {
    try {
      final customer = await localDataSource.getCustomerById(id);
      return Right(customer);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on LocalDatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Customer>> createCustomer(Customer customer) async {
    try {
      final customerModel = CustomerModel.fromCustomer(customer);
      final createdCustomer = await localDataSource.createCustomer(customerModel);
      return Right(createdCustomer);
    } on LocalDatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Customer>> updateCustomer(Customer customer) async {
    try {
      final customerModel = CustomerModel.fromCustomer(customer);
      final updatedCustomer = await localDataSource.updateCustomer(customerModel);
      return Right(updatedCustomer);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on LocalDatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCustomer(String id) async {
    try {
      final result = await localDataSource.deleteCustomer(id);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on LocalDatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Customer>>> searchCustomers(String query) async {
    try {
      final customers = await localDataSource.searchCustomers(query);
      return Right(customers);
    } on LocalDatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
