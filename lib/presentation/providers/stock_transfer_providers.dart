import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/failures.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/stock_transfer_local_data_source.dart';
import '../../data/repositories/stock_transfer_repository_impl.dart';
import '../../domain/entities/stock_transfer.dart';
import '../../domain/repositories/stock_transfer_repository.dart';
import '../../domain/usecases/create_stock_transfer_usecase.dart';
import '../../domain/usecases/stock_transfer_usecases.dart';

// Dependencies
final stockTransferDataSourceProvider = Provider<StockTransferLocalDataSource>((ref) {
  final dbHelper = DatabaseHelper();
  return StockTransferLocalDataSource(dbHelper);
});

final stockTransferRepositoryProvider = Provider<StockTransferRepository>((ref) {
  final dataSource = ref.watch(stockTransferDataSourceProvider);
  return StockTransferRepositoryImpl(dataSource);
});

// Use Cases
final createStockTransferUseCaseProvider = Provider<CreateStockTransferUseCase>((ref) {
  final repository = ref.watch(stockTransferRepositoryProvider);
  return CreateStockTransferUseCase(repository);
});

final getAllTransfersUseCaseProvider = Provider<GetAllTransfersUseCase>((ref) {
  final repository = ref.watch(stockTransferRepositoryProvider);
  return GetAllTransfersUseCase(repository);
});

final getTransfersByStatusUseCaseProvider = Provider<GetTransfersByStatusUseCase>((ref) {
  final repository = ref.watch(stockTransferRepositoryProvider);
  return GetTransfersByStatusUseCase(repository);
});

final updateTransferStatusUseCaseProvider = Provider<UpdateTransferStatusUseCase>((ref) {
  final repository = ref.watch(stockTransferRepositoryProvider);
  return UpdateTransferStatusUseCase(repository);
});

final cancelTransferUseCaseProvider = Provider<CancelTransferUseCase>((ref) {
  final repository = ref.watch(stockTransferRepositoryProvider);
  return CancelTransferUseCase(repository);
});

// State providers
final stockTransfersProvider = FutureProvider<List<StockTransfer>>((ref) async {
  final useCase = ref.watch(getAllTransfersUseCaseProvider);
  final result = await useCase();
  
  return result.fold(
    (failure) => throw failure.message, 
    (transfers) => transfers
  );
});

final stockTransfersByStatusProvider = FutureProvider.family<List<StockTransfer>, String>((ref, status) async {
  final useCase = ref.watch(getTransfersByStatusUseCaseProvider);
  final result = await useCase(status);
  
  return result.fold(
    (failure) => throw failure.message, 
    (transfers) => transfers
  );
});

// Create transfer state notifier
class CreateTransferNotifier extends StateNotifier<AsyncValue<StockTransfer?>> {
  final CreateStockTransferUseCase _useCase;
  
  CreateTransferNotifier(this._useCase) : super(const AsyncValue.data(null));
  
  Future<AsyncValue<StockTransfer?>> createTransfer(Map<String, dynamic> transferData) async {
    state = const AsyncValue.loading();
    
    final result = await _useCase(transferData);
    
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current), 
      (transfer) => AsyncValue.data(transfer)
    );
    
    return state;
  }
  
  void reset() {
    state = const AsyncValue.data(null);
  }
}

final createTransferNotifierProvider = StateNotifierProvider<CreateTransferNotifier, AsyncValue<StockTransfer?>>((ref) {
  final useCase = ref.watch(createStockTransferUseCaseProvider);
  return CreateTransferNotifier(useCase);
});
