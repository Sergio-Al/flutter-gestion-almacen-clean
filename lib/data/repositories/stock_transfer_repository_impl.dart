import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/stock_transfer.dart';
import '../../domain/repositories/stock_transfer_repository.dart';
import '../datasources/stock_transfer_local_data_source.dart';
import '../models/stock_transfer_model.dart';

class StockTransferRepositoryImpl implements StockTransferRepository {
  final StockTransferLocalDataSource dataSource;

  StockTransferRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, StockTransfer>> createStockTransfer(Map<String, dynamic> transferData) async {
    try {
      final transfer = await dataSource.createTransfer(transferData);
      return Right(transfer);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StockTransfer>>> getAllTransfers() async {
    try {
      final transfers = await dataSource.getAllTransfers();
      return Right(transfers);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StockTransfer>>> getTransfersByStatus(String status) async {
    try {
      final transfers = await dataSource.getTransfersByStatus(status);
      return Right(transfers);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StockTransfer>> updateTransferStatus(String transferId, String newStatus) async {
    try {
      final transfer = await dataSource.updateTransferStatus(transferId, newStatus);
      return Right(transfer);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelTransfer(String transferId) async {
    try {
      await dataSource.cancelTransfer(transferId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
