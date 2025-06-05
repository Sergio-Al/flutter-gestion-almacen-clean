import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/stock_transfer.dart';
import '../repositories/stock_transfer_repository.dart';

class GetAllTransfersUseCase {
  final StockTransferRepository repository;

  GetAllTransfersUseCase(this.repository);

  Future<Either<Failure, List<StockTransfer>>> call() async {
    return repository.getAllTransfers();
  }
}

class GetTransfersByStatusUseCase {
  final StockTransferRepository repository;

  GetTransfersByStatusUseCase(this.repository);

  Future<Either<Failure, List<StockTransfer>>> call(String status) async {
    if (status.isEmpty) {
      return Left(ValidationFailure(message: 'Status cannot be empty'));
    }
    
    return repository.getTransfersByStatus(status);
  }
}

class UpdateTransferStatusUseCase {
  final StockTransferRepository repository;

  UpdateTransferStatusUseCase(this.repository);

  Future<Either<Failure, StockTransfer>> call(String transferId, String newStatus) async {
    if (transferId.isEmpty) {
      return Left(ValidationFailure(message: 'Transfer ID cannot be empty'));
    }
    
    if (newStatus.isEmpty) {
      return Left(ValidationFailure(message: 'New status cannot be empty'));
    }
    
    // Validate status is one of the allowed values
    if (!['pending', 'completed', 'cancelled'].contains(newStatus)) {
      return Left(ValidationFailure(message: 'Invalid status value'));
    }
    
    return repository.updateTransferStatus(transferId, newStatus);
  }
}

class CancelTransferUseCase {
  final StockTransferRepository repository;

  CancelTransferUseCase(this.repository);

  Future<Either<Failure, void>> call(String transferId) async {
    if (transferId.isEmpty) {
      return Left(ValidationFailure(message: 'Transfer ID cannot be empty'));
    }
    
    return repository.cancelTransfer(transferId);
  }
}
