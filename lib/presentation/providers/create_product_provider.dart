import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_almacen_stock/domain/usecases/product/create_product_usecase.dart';
import '../../core/providers/usecase_providers.dart';

// Estado para la creación de productos
class CreateProductState {
  final bool isLoading;
  final String? error;
  final bool success;

  CreateProductState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  CreateProductState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return CreateProductState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

// Notifier para manejar la creación de productos
class CreateProductNotifier extends StateNotifier<CreateProductState> {
  final CreateProductUseCase _createProductUseCase;

  CreateProductNotifier(this._createProductUseCase) : super(CreateProductState());

  Future<void> createProduct({
    required String sku,
    required String name,
    required String description,
    required String categoryId,
    required double unitPrice,
    required double costPrice,
    required int reorderPoint,
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);

    try {
      await _createProductUseCase(
        sku: sku,
        name: name,
        description: description,
        categoryId: categoryId,
        unitPrice: unitPrice,
        costPrice: costPrice,
        reorderPoint: reorderPoint,
      );

      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Provider para el notifier
final createProductProvider = StateNotifierProvider<CreateProductNotifier, CreateProductState>((ref) {
  final useCase = ref.watch(createProductUseCaseProvider);
  return CreateProductNotifier(useCase);
});
