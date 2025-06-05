import '../entities/stock_transfer.dart';
import '../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class StockTransferRepository {
  Future<Either<Failure, StockTransfer>> createStockTransfer(Map<String, dynamic> transferData);
  Future<Either<Failure, List<StockTransfer>>> getAllTransfers();
  Future<Either<Failure, List<StockTransfer>>> getTransfersByStatus(String status);
  Future<Either<Failure, StockTransfer>> updateTransferStatus(String transferId, String newStatus);
  Future<Either<Failure, void>> cancelTransfer(String transferId);
}
