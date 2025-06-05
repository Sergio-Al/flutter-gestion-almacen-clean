import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/stock_transfer.dart';
import '../repositories/stock_transfer_repository.dart';

class CreateStockTransferUseCase {
  final StockTransferRepository repository;

  CreateStockTransferUseCase(this.repository);

  Future<Either<Failure, StockTransfer>> call(Map<String, dynamic> transferData) async {
    // Perform validation before calling the repository
    if (transferData['quantity'] == null || transferData['quantity'] <= 0) {
      return Left(ValidationFailure(message: 'Quantity must be greater than zero'));
    }

    if (transferData['productId'] == null || transferData['productId'].isEmpty) {
      return Left(ValidationFailure(message: 'Product ID is required'));
    }

    if (transferData['fromWarehouseId'] == null || transferData['fromWarehouseId'].isEmpty) {
      return Left(ValidationFailure(message: 'Source warehouse is required'));
    }

    if (transferData['toWarehouseId'] == null || transferData['toWarehouseId'].isEmpty) {
      return Left(ValidationFailure(message: 'Destination warehouse is required'));
    }

    if (transferData['reason'] == null || transferData['reason'].isEmpty) {
      return Left(ValidationFailure(message: 'Reason for transfer is required'));
    }

    return repository.createStockTransfer(transferData);
  }
}
